import os
import json
import cv2
import numpy as np
import torch
from torch.utils.data import Dataset
from torchvision import transforms

class SegmentationDataset(Dataset):
    def __init__(self, root_dir, dataset_type='syntax', split='train', image_size=(512, 512), transform=None):
        self.root_dir = root_dir
        self.dataset_type = dataset_type
        self.split = split
        self.image_size = image_size
        self.transform = transform
        
        self.images_dir = os.path.join(root_dir, dataset_type, split, 'images')
        self.json_path = os.path.join(root_dir, dataset_type, split, 'annotations', f'{split}.json')
        
        with open(self.json_path, 'r') as f:
            self.data = json.load(f)
            
        self.image_info = {img['id']: img for img in self.data['images']}
        self.annotations = {}
        for ann in self.data['annotations']:
            img_id = ann['image_id']
            if img_id not in self.annotations:
                self.annotations[img_id] = []
            self.annotations[img_id].append(ann)
            
        self.image_ids = list(self.image_info.keys())
        
    def __len__(self):
        return len(self.image_ids)
    
    def __getitem__(self, idx):
        img_id = self.image_ids[idx]
        img_data = self.image_info[img_id]
        
        # Load Image
        img_path = os.path.join(self.images_dir, img_data['file_name'])
        image = cv2.imread(img_path)
        if image is None:
            # Handle missing image gracefully or raise error
            raise FileNotFoundError(f"Image not found: {img_path}")
            
        image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)

        # Apply CLAHE (Contrast Limited Adaptive Histogram Equalization)
        # This enhances local contrast, making vessels pop out from background.
        # We work on the L channel of LAB color space to preserve color info (if any).
        lab = cv2.cvtColor(image, cv2.COLOR_RGB2LAB)
        l, a, b = cv2.split(lab)
        clahe = cv2.createCLAHE(clipLimit=2.0, tileGridSize=(8,8))
        cl = clahe.apply(l)
        limg = cv2.merge((cl,a,b))
        image = cv2.cvtColor(limg, cv2.COLOR_LAB2RGB)
        
        # Create Mask
        mask = np.zeros((img_data['height'], img_data['width']), dtype=np.uint8)
        if img_id in self.annotations:
            for ann in self.annotations[img_id]:
                for seg in ann['segmentation']:
                    poly = np.array(seg).reshape((-1, 2)).astype(np.int32)
                    cv2.fillPoly(mask, [poly], 1) # Binary mask (1 for foreground)
                    
        # Resize
        if self.image_size:
            image = cv2.resize(image, self.image_size)
            mask = cv2.resize(mask, self.image_size, interpolation=cv2.INTER_NEAREST)
            
        # Transform to Tensor
        image = image.astype(np.float32) / 255.0
        image = torch.from_numpy(image).permute(2, 0, 1) # C, H, W
        
        mask = torch.from_numpy(mask).long() # H, W
        
        return image, mask

if __name__ == '__main__':
    # Test the dataset
    dataset = SegmentationDataset('e:/Research/dataset', split='train')
    img, mask = dataset[0]
    print(f"Image shape: {img.shape}, Mask shape: {mask.shape}")
    print(f"Unique mask values: {torch.unique(mask)}")
