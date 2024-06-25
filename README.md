# Electrocardiogram arrhythmia detection with novel signal processing and persistent homology-derived predictors
This repository contains scripts related to the manuscript "[Electrocardiogram arrhythmia detection with novel signal processing and persistent homology-derived predictors](https://content.iospress.com/articles/data-science/ds240061)" published in the journal "Data Science Methods, Infrastructure, and Applications" in June of 2024. The abstract of the manuscript is shown below.

<br>

Many approaches to computer-aided electrocardiogram (ECG) arrhythmia detection have been performed, several of which combine persistent homology and machine learning. We present a novel ECG signal processing pipeline and method of constructing predictor variables for use in statistical models. Specifically, we introduce an isoelectric baseline to yield non-trivial topological features corresponding to the P, Q, S, and T-waves (if they exist) and utilize the $N$-most persistent 1-dimensional homological features and their corresponding area-minimal cycle representatives to construct predictor variables derived from the persistent homology of the ECG signal. The binary classification of (1) Atrial Fibrillation vs. Non-Atrial Fibrillation, (2) Arrhythmia vs. Normal Sinus Rhythm, and (3) Arrhythmias with Morphological Changes vs. Sinus Rhythm with Bradycardia and Tachycardia Treated as Non-Arrhythmia was performed using Logistic Regression, Linear Discriminant Analysis, Quadratic Discriminant Analysis, Naive Bayes, Random Forest, Gradient Boosted Decision Tree, K-Nearest Neighbors, and Support Vector Machine with a linear, radial, and polynomial kernel Models with stratified 5-fold cross validation. The Gradient Boosted Decision Tree Model attained the best results with a mean F1-score and mean Accuracy of $(0.967,0.946)$, $(0.839,0.946)$, and $(0.943,0.921)$ across the five folds for binary classifications of (1), (2), and (3), respectively.

<br>

## Descriptions of directories:

### processing: contains the following three scripts to obtain input for the statistical models from the raw ECG data

* cycles.py: contains functions to compute the time-coordinate and amplitude coordinate of the centroid of a given 1-cycle.

* get_signal_info.py: processes raw ECG signal by normalizing its amplitude to be confined to [0,1], introduces isoelectric baseline, and computes and saves persistent homology-derived statistics such as birth radii, death radii, persistence, and centroid coordinates of optimal representative cycles.

* get_ml_input_all.py: creates dataframe with each row corresponding to an ECG signal and with column representing predictor variables for use in statistical models

### models: contains a script for each type of statistical model used in each of the three binary classification tasks

### figures: contains scripts used to produce all figures and tables in manuscript

## Citation
H. Dlugas, Electrocardiogram arrhythmia detection with novel signal processing and persistent homology-derived predictors, Data Science, 1 Jan. 2024, 1-25, doi:10.3233/DS-240061, url:[https://datasciencehub.net/system/files/ds-paper-790.pdf](https://content.iospress.com/articles/data-science/ds240061)
