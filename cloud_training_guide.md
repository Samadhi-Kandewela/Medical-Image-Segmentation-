# Cloud Training Guide

Since you do not have a local GPU, you must use a cloud platform to train your models.

## Option A: Google Colab (Recommended for Ease of Use)
**Pros**: Connects directly to Google Drive.
**Cons**: Session disconnects after ~12 hours (or earlier).

### Steps:
1.  **Prepare Data**:
    *   **IMPORTANT**: Zip your `dataset` folder into `dataset.zip`.
    *   Upload `dataset.zip` and your entire `src` folder to your **Google Drive** inside a `Research` folder.
    *   Structure:
        *   `My Drive/Research/dataset.zip`
        *   `My Drive/Research/src/` ...
2.  **Open Notebook**:
    *   Open `training_notebook.ipynb` in Colab (https://colab.research.google.com).
    *   Or upload it manually.
    *   **IMPORTANT**: Go to `Runtime` -> `Change runtime type` -> Select **T4 GPU** (or any available GPU).
3.  **Run**:
    *   Run the first cell to mount Drive.
    *   The notebook will `cd` into `/content/drive/MyDrive/Research`.
    *   Run the training cells.
    *   Checkpoints will be saved to your Drive (`Research/checkpoints/`), so you won't lose them if Colab disconnects.

## Option B: Kaggle Kernels (Recommended for Stability & Speed)
**Pros**: Faster GPUs (often P100), 30+ hours/week free, stable.
**Cons**: Need to create a "Dataset" first.

### Steps:
1.  **Create Dataset**:
    *   Go to Kaggle -> Datasets -> New Dataset.
    *   Upload your `Research` folder (zip it first). Name it `arcade-latency-research`.
2.  **Create Notebook**:
    *   Go to Kaggle -> Code -> New Notebook.
    *   **ENABLE GPU**: In the right sidebar, check "Accelerator" -> Select "GPU P100".
    *   On the right sidebar, click **Add Input** -> Search for your dataset `arcade-latency-research` -> Add.
3.  **Setup Paths**:
    *   Kaggle mounts data at `/kaggle/input/arcade-latency-research/`.
    *   You might need to copy `src` to `/kaggle/working/` to run it.
    *   Copy src: `!cp -r /kaggle/input/arcade-latency-research/Research/src /kaggle/working/`
4.  **Run**:
    *   Run training commands.
    *   Output files (checkpoints) in `/kaggle/working/` can be downloaded after the run.

## Recommended Command for Training
To train the best model (MobileUNet) for latency-aware application:
```bash
python src/train.py --model mobileunet --epochs 50 --batch-size 16 --scale 0.5
```
If `batch-size 16` causes Out of Memory (OOM), reduce to 8.
