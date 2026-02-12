# Medical Image Segmentation Research: Latency-Aware Framework

This project implements a high-performance deep learning framework for real-time angiography segmentation. It includes a **State-of-the-Art SegFormer Teacher** model and a **Lightweight MobileUNet Student** model.

## 🚀 Quick Start (For Collaborators)

If you are running this on a new machine (e.g., a friend's GPU laptop), follow these steps carefully.

### 1. Requirements
*   **Python 3.8+**
*   **NVIDIA GPU** (RTX 3060 or better recommended for SegFormer)
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
1.  **Download** the dataset (ARCADE or similar).
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

### 4. Running the Training (The "Heavy" Job)
To train the **SegFormer-B4 Teacher** (Best Accuracy):

```bash
python src/train_teacher_transformer.py --epochs 30 --batch-size 4 --data-dir dataset
```
*   **Note**: If you get "Out of Memory" (OOM) errors, reduce `--batch-size` to `2`.
*   **Checkpoints**: The model will be saved to `checkpoints/teacher_transformer/teacher_transformer_best.pth`.

### 5. Running the Demo (Visualize Results)
Once you have a trained model (or checkpoint), you can run the interactive demo:

```bash
streamlit run src/demo_app.py
```

## Repository Structure
*   `src/train_teacher_transformer.py`: Training script for SOTA SegFormer.
*   `src/model_lightweight.py`: Definitions for MobileUNet-v3 (Student).
*   `src/train_distillation.py`: Script to distill knowledge from Teacher to Student.
*   `src/benchmark.py`: Tools to measure latency and FPS.
