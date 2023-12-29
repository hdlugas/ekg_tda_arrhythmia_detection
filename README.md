# Electrocardiogram arrhythmia detection with novel signal processing and persistent homology-derived predictors
This repository contains scripts related to the manuscript "Electrocardiogram arrhythmia detection with novel signal processing and persistent homology-derived predictors" submitted to the Journal "Data Science Methods, Infrastructure, and Applications". The abstract of the manuscript is shown below.
<br>
<br>
Many approaches to computer-aided electrocardiogram (ECG) arrhythmia detection have been performed, several of which combine persistent homology and machine learning. We present a novel ECG signal processing pipeline and method of constructing predictor variables for use in statistical models. Specifically, we introduce an isoelectric baseline to yield non-trivial topological features corresponding to the P, Q, S, and T-waves (if they exist) and utilize the $N$-most persistent 1-dimensional homological features and their corresponding area-minimal cycle representatives to construct predictor variables derived from the persistent homology of the ECG signal. The binary classification of (1) Atrial Fibrillation vs. Non-Atrial Fibrillation, (2) Arrhythmia vs. Normal Sinus Rhythm, and (3) Arrhythmias with Morphological Changes vs. Sinus Rhythm with Bradycardia and Tachycardia Treated as Non-Arrhythmia was performed using Logistic Regression, Linear Discriminant Analysis, Quadratic Discriminant Analysis, Naive Bayes, Random Forest, Gradient Boosted Decision Tree, K-Nearest Neighbors, and Support Vector Machine with a linear, radial, and polynomial kernel Models with stratified 5-fold cross validation. The Gradient Boosted Decision Tree Model attained the best results with a mean F1-score and mean Accuracy of $(0.9677,0.946)$, $(0.839,0.946)$, and $(0.943,0.921)$ across the five folds for binary classifications of (1), (2), and (3), respectively.

Descriptions of files:

cycles.py: contains functions to compute the time-coordinate and amplitude coordinate of the centroid of a given 1-cycle.

get_signal_info.py: processes raw ECG signal by normalizing its amplitude to be confined to [0,1], introduces isoelectric baseline, and computes and saves persistent homology-derived statistics such as birth radii, death radii, persistence, and centroid coordinates of optimal representative cycles.

fig_vietoris_rips_example.py: creates figure of toy example shown below
<br> 
<img src="https://github.com/hdlugas/ekg_tda_arrhythmia_detection/assets/73852653/77d18e87-2d0e-4f90-a54f-cd3341a3683d" width="500" height="400">

fig_pers_diagram_example.py: creates figure of toy example shown below
<br> 
<img src="https://github.com/hdlugas/ekg_tda_arrhythmia_detection/assets/73852653/1b733b0f-b852-4680-a5c3-7b27b5fbac05" width="400" height="500">

get_ml_input_all.py: creates dataframe with each row corresponding to an ECG signal and with column representing predictor variables for use in statistical models

models/: this directory contains a script for each type of statistical model used in each of the three binary classifications
<br> 
<img src="https://github.com/hdlugas/ekg_tda_arrhythmia_detection/assets/73852653/211637e6-b929-4db1-9e01-4f21af61bcc0" width="500" height="400">
<br> 
<img src="https://github.com/hdlugas/ekg_tda_arrhythmia_detection/assets/73852653/f5a2ae9a-44da-4844-bbad-79a06d987ce9" width="500" height="400">
<br> 
<img src="https://github.com/hdlugas/ekg_tda_arrhythmia_detection/assets/73852653/c5cd0c89-70d3-4ce6-8c0e-77e7d2487562" width="500" height="400">


