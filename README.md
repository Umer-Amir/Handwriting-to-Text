# Handwriting-to-Text (Work in Progress)

This project implements a handwriting recognition system using MATLAB. The system performs preprocessing, segmentation, and feature extraction on handwritten characters and uses a k-Nearest Neighbors (kNN) classifier to recognize characters. The model is trained on the A-Z Handwritten Alphabets dataset. This was developed as a Final Project for a Digital Image Processing course.

---

## Features

* **Image Preprocessing**: Includes grayscale conversion, noise removal, and binarization.
* **Line and Character Segmentation**: Divides the handwritten text into individual lines and characters.
* **Feature Extraction**: Extracts relevant features from characters using Pixel Intensities and Histogram of Oriented Gradients (HOG).
* **Character Recognition**: Utilizes a kNN Classifier for accurate character prediction.

---

## Dataset

The model is trained using the A-Z Handwritten Alphabets Dataset available on Kaggle in CSV format:
[https://www.kaggle.com/datasets/sachinpatel21/az-handwritten-alphabets-in-csv-format](https://www.kaggle.com/datasets/sachinpatel21/az-handwritten-alphabets-in-csv-format)

Each row of the dataset contains a 28x28 pixel image of a handwritten letter (A-Z) along with the corresponding label.

---

## Installation

1. **Clone the repository**:

```
git clone https://github.com/your-username/handwriting-recognition-system.git
cd handwriting-recognition-system
```

2. **Download the dataset**:
   Download `A_Z_Handwritten_Data.csv` from Kaggle and place it in the project directory.

3. **Run the MATLAB script**:
   Open `handwriting_to_text.m` in MATLAB.
   Ensure the dataset is loaded.
   Run the script to start the recognition system.

---

## Usage

* **Preprocessing**:
  The system processes an input image of handwritten text by converting it to grayscale, removing noise, binarizing, and segmenting the text into individual characters.

* **Feature Extraction**:
  Features are extracted from each segmented character using pixel intensities and Histogram of Oriented Gradients (HOG).

* **Training the Classifier**:
  A k-Nearest Neighbors (kNN) classifier is trained using the provided dataset.

* **Prediction**:
  The classifier predicts the characters in the input image based on the extracted features.

---

## Project Structure

```
handwriting-recognition-system/
├── README.md                  # Project overview
├── handwriting_to_text.m      # Main script for preprocessing, segmentation, and prediction
├── extractCharacterFeatures.m # Function for feature extraction
├── A_Z_Handwritten_Data.csv   # Dataset (download separately)
└── train_data.mat             # Optional: Pre-saved training data (if applicable)
```

---

## Example

To recognize characters from a new handwritten image:

1. Add your handwritten image (e.g., `handwriting.png`) to the project directory.
2. Update the image path in `handwriting_to_text.m`.
3. Run the script to view the predicted characters in the MATLAB console.

---

## Future Work

* Improve the accuracy using advanced classifiers (e.g., SVM, Neural Networks).
* Implement data augmentation for better generalization.
* Add support for digit recognition.

---

## License

This project is licensed under the MIT License. See the LICENSE file for more details.

---
