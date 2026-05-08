import os
import tensorflow as tf
from tensorflow.keras import layers, models
from tensorflow.keras.preprocessing.image import ImageDataGenerator

# ==========================================
# CONFIGURATION
# ==========================================
# Change this path to where your dataset folder is located
DATASET_DIR = "dataset" 
MODEL_SAVE_PATH = "models/maize_cnn_model.h5"

IMAGE_SIZE = (224, 224)
BATCH_SIZE = 32
EPOCHS = 15
NUM_CLASSES = 4

# ==========================================
# 1. LOAD AND PRE-PROCESS DATA
# ==========================================
def load_data():
    print("Loading and pre-processing dataset...")
    
    # We use ImageDataGenerator for data augmentation (helps prevent overfitting)
    # and to split our dataset into Training (80%) and Validation (20%)
    datagen = ImageDataGenerator(
        rescale=1./255,             # Normalize pixel values
        rotation_range=20,          # Randomly rotate images
        width_shift_range=0.2,
        height_shift_range=0.2,
        horizontal_flip=True,       # Randomly flip images
        validation_split=0.2        # 20% of data for validation
    )

    # Load Training Data
    train_generator = datagen.flow_from_directory(
        DATASET_DIR,
        target_size=IMAGE_SIZE,
        batch_size=BATCH_SIZE,
        class_mode='categorical',
        subset='training'
    )

    # Load Validation Data
    validation_generator = datagen.flow_from_directory(
        DATASET_DIR,
        target_size=IMAGE_SIZE,
        batch_size=BATCH_SIZE,
        class_mode='categorical',
        subset='validation'
    )
    
    # Print the class mapping to make sure it matches what the frontend expects
    print("\nClass Mapping:")
    print(train_generator.class_indices)
    
    return train_generator, validation_generator

# ==========================================
# 2. BUILD CNN ARCHITECTURE
# ==========================================
def build_model():
    print("\nBuilding CNN Model...")
    model = models.Sequential([
        # 1st Convolutional Block
        layers.Conv2D(32, (3, 3), activation='relu', input_shape=(224, 224, 3)),
        layers.MaxPooling2D(2, 2),
        
        # 2nd Convolutional Block
        layers.Conv2D(64, (3, 3), activation='relu'),
        layers.MaxPooling2D(2, 2),
        
        # 3rd Convolutional Block
        layers.Conv2D(128, (3, 3), activation='relu'),
        layers.MaxPooling2D(2, 2),
        
        # Flatten and Dense Layers (ANN part)
        layers.Flatten(),
        layers.Dense(512, activation='relu'),
        layers.Dropout(0.5), # Helps prevent overfitting
        layers.Dense(NUM_CLASSES, activation='softmax') # Output layer
    ])

    model.compile(
        optimizer='adam',
        loss='categorical_crossentropy',
        metrics=['accuracy']
    )
    
    model.summary()
    return model

# ==========================================
# 3. TRAIN AND SAVE MODEL
# ==========================================
def train():
    # Ensure the models directory exists
    os.makedirs(os.path.dirname(MODEL_SAVE_PATH), exist_ok=True)
    
    if not os.path.exists(DATASET_DIR):
        print(f"ERROR: Dataset directory '{DATASET_DIR}' not found.")
        print("Please create a 'dataset' folder and organize your images into subfolders for each disease.")
        return

    train_gen, val_gen = load_data()
    model = build_model()

    print("\nStarting training...")
    history = model.fit(
        train_gen,
        epochs=EPOCHS,
        validation_data=val_gen
    )
    
    print(f"\nTraining complete. Saving model to {MODEL_SAVE_PATH}...")
    model.save(MODEL_SAVE_PATH)
    print("Model saved successfully!")

if __name__ == "__main__":
    train()
