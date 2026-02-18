import segmentation_models_pytorch as smp

import argparse
import logging
import os
import sys
import torch
import torch.nn as nn
import torch.nn.functional as F
from torch import optim
from torch.utils.data import DataLoader, random_split
from tqdm import tqdm
# from torchvision import models # DeepLab Not needed anymore

from dataset import SegmentationDataset
from model_lightweight import MobileUNetv3

# Knowledge Distillation Loss
class DistillationLoss(nn.Module):
    def __init__(self, alpha=0.5, temperature=3.0):
        super(DistillationLoss, self).__init__()
        self.alpha = alpha
        self.temperature = temperature
        self.bce = nn.BCEWithLogitsLoss()
        self.kl_div = nn.KLDivLoss(reduction='batchmean')

    def forward(self, student_logits, teacher_logits, targets):
        # 1. Standard Loss (Student vs Ground Truth)
        student_loss = self.bce(student_logits, targets)

        # 2. Distillation Loss (Student vs Teacher)
        # Soften probabilities with temperature
        student_soft = F.log_softmax(student_logits / self.temperature, dim=1)
        teacher_soft = F.softmax(teacher_logits / self.temperature, dim=1)
        
        # Expand to 2 channels for KL
        student_2ch = torch.cat([-student_logits, student_logits], dim=1) # (B, 2, H, W)
        teacher_2ch = torch.cat([-teacher_logits, teacher_logits], dim=1)
        
        student_soft = F.log_softmax(student_2ch / self.temperature, dim=1)
        teacher_soft = F.softmax(teacher_2ch / self.temperature, dim=1)

        distillation_loss = self.kl_div(student_soft, teacher_soft) * (self.temperature ** 2)

        return self.alpha * student_loss + (1 - self.alpha) * distillation_loss

def train_distillation(teacher_path, data_dir, epochs=50, batch_size=8, lr=1e-4, save_cp=True, dir_checkpoint='checkpoints/student_distilled/'):
    device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
    
    # 1. Load Data
    dataset = SegmentationDataset(data_dir, split='train')
    n_val = int(len(dataset) * 0.1)
    n_train = len(dataset) - n_val
    train_set, val_set = random_split(dataset, [n_train, n_val], generator=torch.Generator().manual_seed(0))
    train_loader = DataLoader(train_set, batch_size=batch_size, shuffle=True, num_workers=2, pin_memory=True)
    val_loader = DataLoader(val_set, batch_size=batch_size, shuffle=False, num_workers=2, pin_memory=True, drop_last=True)

    # 2. Load Teacher (SegFormer-B4)
    logging.info(f"Loading Teacher (SegFormer) from {teacher_path}...")
    teacher = smp.Segformer(
        encoder_name="mit_b4",
        encoder_weights=None, # Loading custom weights anyway
        in_channels=3,
        classes=1,
    )
    teacher.load_state_dict(torch.load(teacher_path, map_location=device))
    teacher.to(device)
    teacher.eval()
    for param in teacher.parameters():
        param.requires_grad = False

    # 3. Load Student (MobileUNetv3)
    logging.info("Initializing Student (MobileUNetv3)...")
    student = MobileUNetv3(n_classes=1)
    student.to(device)

    # 4. Setup Training
    optimizer = optim.Adam(student.parameters(), lr=lr)
    criterion = DistillationLoss(alpha=0.5, temperature=4.0)

    logging.info(f"Starting Distillation: Epochs={epochs}, Batch={batch_size}, LR={lr}")

    for epoch in range(epochs):
        student.train()
        epoch_loss = 0
        with tqdm(total=n_train, desc=f'Epoch {epoch + 1}/{epochs}', unit='img') as pbar:
            for batch in train_loader:
                imgs, masks = batch
                imgs = imgs.to(device, dtype=torch.float32)
                masks = masks.to(device, dtype=torch.float32)
                masks = masks.unsqueeze(1) # (B, H, W) -> (B, 1, H, W)

                # Teacher inference (No Grad)
                with torch.no_grad():
                    # SegFormer returns tensor directly, not dict
                    teacher_out = teacher(imgs)
                
                # Student inference
                student_out = student(imgs)

                # Calculate Loss
                loss = criterion(student_out, teacher_out, masks)
                
                optimizer.zero_grad()
                loss.backward()
                optimizer.step()

                epoch_loss += loss.item()
                pbar.set_postfix(**{'loss': loss.item()})
                pbar.update(imgs.shape[0])

        # Validation
        val_score = evaluate(student, val_loader, device)
        logging.info(f'Validation Dice: {val_score}')
        
        if save_cp:
            os.makedirs(dir_checkpoint, exist_ok=True)
            torch.save(student.state_dict(), dir_checkpoint + f'student_epoch{epoch + 1}.pth')

def evaluate(net, dataloader, device):
    net.eval()
    dice_score = 0
    n_val = len(dataloader)
    with torch.no_grad():
        for batch in dataloader:
            image, mask_true = batch
            image = image.to(device)
            mask_true = mask_true.to(device)
            mask_true = mask_true.unsqueeze(1) # (B, H, W) -> (B, 1, H, W)
            output = torch.sigmoid(net(image))
            output = (output > 0.5).float()
            intersection = (output * mask_true).sum()
            union = output.sum() + mask_true.sum()
            dice = (2. * intersection + 1e-6) / (union + 1e-6)
            dice_score += dice.item()
    return dice_score / n_val

if __name__ == '__main__':
    logging.basicConfig(level=logging.INFO, format='%(levelname)s: %(message)s')
    parser = argparse.ArgumentParser()
    parser.add_argument('--teacher', type=str, required=True, help='Path to trained teacher .pth')
    parser.add_argument('--epochs', type=int, default=50)
    parser.add_argument('--batch-size', type=int, default=8)
    parser.add_argument('--lr', type=float, default=1e-4)
    parser.add_argument('--data-dir', type=str, default='dataset', help='Path to dataset root')
    args = parser.parse_args()
    
    try:
        train_distillation(args.teacher, data_dir=args.data_dir, epochs=args.epochs, batch_size=args.batch_size, lr=args.lr)
    except KeyboardInterrupt:
        sys.exit(0)
