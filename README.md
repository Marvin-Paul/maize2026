# Maize Leaf Disease Identification System

A functional web-based prototype for diagnosing maize leaf diseases to support a research project at Kampala International University.

## Setup Instructions

### 1. Prerequisites

- **Python:** Download and install Python 3.9+ from [python.org](https://www.python.org/downloads/) or the Microsoft Store. Ensure you select "Add Python to PATH" during installation.

### 2. Install Dependencies

Open your terminal and run the following command in the project directory:

```bash
pip install -r requirements.txt
```

### 3. Training the AI Model

Currently, the application runs in a _simulation mode_ to test the interface. To train the actual Convolutional Neural Network (CNN):

1. Create a folder named `dataset` in the root of the project.
2. Inside `dataset`, create folders for each of your classes exactly matching these names:
   - `Healthy Leaves`
   - `Maize Gray Leaf Spot`
   - `Maize Lethal Necrosis Disease`
   - `Maize Streak Virus`
3. Place your raw images into their respective folders.
4. Run the training script:
   ```bash
   python train_model.py
   ```
   This will train the CNN using TensorFlow/Keras and automatically save the resulting model to `models/maize_cnn_model.h5`.

### 4. Running the Web Application

Once dependencies are installed (and optionally, your model is trained), run the Flask server:

```bash
python app.py
```

The application will automatically detect your trained model in the `models/` directory and use it. If the model hasn't been built yet, it will seamlessly fall back to the mock simulation so you can still test the UI.

- **Diagnostic Tool (Farmer UI):** `http://localhost:5000`
- **Performance Dashboard:** `http://localhost:5000/dashboard`
