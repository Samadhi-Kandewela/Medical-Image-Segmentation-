# Medical Image Segmentation Research: Latency-Aware Framework

This project implements a high-performance deep learning framework for real-time angiography segmentation. It includes a **State-of-the-Art SegFormer Teacher** model and a **Lightweight MobileUNet Student** model.

### 1. Requirements
*   Python 3.8+
*   NVIDIA GPU (RTX 3060 or better recommended for SegFormer)
*   CUDA Toolkit installed

### 2. Setup Environment
Open a terminal in the project folder and run:

```bash
# Create a virtual environment (Recommended)
python -m venv venv
# Windows:
.\venv\Scripts\activate
# Linux/Mac:
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt
```

### 3. Dataset Setup
1.  **Download** the dataset.
2.  **Extract** it into a folder named `dataset` in the project root.
3.  Structure should look like this:
    ```
    Research/
    ├── dataset/
    │   ├── syntax/
    │   └── stenosis/
    ├── src/
    ├── checkpoints/
    ├── requirements.txt
    └── ...
    ```

### 4. Running the Training 
To train the **SegFormer-B4 Teacher** :

```bash
python src/train_teacher_transformer.py --epochs 30 --batch-size 4 --data-dir dataset
```
*   **Note**: If you get "Out of Memory" (OOM) errors, reduce `--batch-size` to `2`.
*   **Checkpoints**: The model will be saved to `checkpoints/teacher_transformer/teacher_transformer_best.pth`.

```

**### 5. Running the Student Training (Knowledge Distillation)**
After the Teacher is trained (or if you have the `checkpoints/teacher_transformer/teacher_transformer_best.pth` file), you can train the **Student (MobileUNet-v3)**:

```bash
python src/train_distillation.py --teacher checkpoints/teacher_transformer/teacher_transformer_best.pth --epochs 50 --batch-size 8 --data-dir dataset
```
*   **Result**: This creates the fast, lightweight model in `checkpoints/student_distilled/`.

## Repository Structure
*   `src/train_teacher_transformer.py`: Training script for SOTA SegFormer.
*   `src/model_lightweight.py`: Definitions for MobileUNet-v3 (Student).
*   `src/train_distillation.py`: Script to distill knowledge from Teacher to Student.
*   `src/desktop_app.py`: **PyQt5 Real-Time Segmentation Viewer** (Desktop GUI).
*   `src/benchmark.py`: Tools to measure latency and FPS.

### 6. Running the Desktop App (Real-Time Viewer)

The desktop app is a native PyQt5 application that streams video and shows real-time segmentation overlays.

**Install dependencies:**
```bash
pip install -r requirements.txt
```

**Run the app:**
```bash
python src/desktop_app.py
```

**How to use:**
1. Click **📂 Open Video** to select an angiogram video file (`.mp4`, `.avi`, `.mov`).
2. Click **🧠 Load Model** to select your trained model (`.onnx` or `.pth`).
3. Adjust the **Threshold** slider to control segmentation sensitivity (default: 0.50).
4. Choose an **Overlay Color** (Green, Red, Blue, Yellow).
5. Click **▶ Play** to start real-time streaming and segmentation.
6. Use **⏸ Pause** and **⏹ Stop** to control playback.

**UI Features:**
- **Dual Panels**: Original video frame on the left, AI segmentation overlay on the right.
- **Real-Time Metrics**: Live FPS and Latency (ms) displayed below the panels.
- **Dark Theme**: Professional dark interface.
- **Supports ONNX & PyTorch**: Use `.onnx` models for maximum speed or `.pth` checkpoints directly.
