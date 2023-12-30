# Electrocardiogram arrhythmia detection with novel signal processing and persistent homology-derived predictors
This repository contains scripts related to the manuscript "Electrocardiogram arrhythmia detection with novel signal processing and persistent homology-derived predictors" submitted to the Journal "Data Science Methods, Infrastructure, and Applications". The abstract of the manuscript is shown below.

<br>

Many approaches to computer-aided electrocardiogram (ECG) arrhythmia detection have been performed, several of which combine persistent homology and machine learning. We present a novel ECG signal processing pipeline and method of constructing predictor variables for use in statistical models. Specifically, we introduce an isoelectric baseline to yield non-trivial topological features corresponding to the P, Q, S, and T-waves (if they exist) and utilize the $N$-most persistent 1-dimensional homological features and their corresponding area-minimal cycle representatives to construct predictor variables derived from the persistent homology of the ECG signal. The binary classification of (1) Atrial Fibrillation vs. Non-Atrial Fibrillation, (2) Arrhythmia vs. Normal Sinus Rhythm, and (3) Arrhythmias with Morphological Changes vs. Sinus Rhythm with Bradycardia and Tachycardia Treated as Non-Arrhythmia was performed using Logistic Regression, Linear Discriminant Analysis, Quadratic Discriminant Analysis, Naive Bayes, Random Forest, Gradient Boosted Decision Tree, K-Nearest Neighbors, and Support Vector Machine with a linear, radial, and polynomial kernel Models with stratified 5-fold cross validation. The Gradient Boosted Decision Tree Model attained the best results with a mean F1-score and mean Accuracy of $(0.9677,0.946)$, $(0.839,0.946)$, and $(0.943,0.921)$ across the five folds for binary classifications of (1), (2), and (3), respectively.

<br>

Descriptions of files:

cycles.py: contains functions to compute the time-coordinate and amplitude coordinate of the centroid of a given 1-cycle.

get_signal_info.py: processes raw ECG signal by normalizing its amplitude to be confined to [0,1], introduces isoelectric baseline, and computes and saves persistent homology-derived statistics such as birth radii, death radii, persistence, and centroid coordinates of optimal representative cycles.

get_ml_input_all.py: creates dataframe with each row corresponding to an ECG signal and with column representing predictor variables for use in statistical models

models/: this directory contains a script for each type of statistical model used in each of the three binary classifications

flowchart.tex: the LaTeX code used to produce the flowchart below
<br>
<img src="https://github.com/hdlugas/ekg_tda_arrhythmia_detection/assets/73852653/8a671f40-32e0-418e-98ab-c8e79917071d" width="300" height="600">

<br>
<br>
<br>

fig_vietoris_rips_example.py: creates figure of toy example shown below
<br> 
<img src="https://github.com/hdlugas/ekg_tda_arrhythmia_detection/assets/73852653/77d18e87-2d0e-4f90-a54f-cd3341a3683d" width="800" height="600">

<br>
<br>
<br>

fig_pers_diagram_example.py: creates figure of toy example shown below
<br> 
<img src="https://github.com/hdlugas/ekg_tda_arrhythmia_detection/assets/73852653/1b733b0f-b852-4680-a5c3-7b27b5fbac05" width="600" height="800">

<br>
<br>
<br>

create_figures.R: generates tables of binary classification outcomes and ROC curves shown below

<br> 

<img src="https://github.com/hdlugas/ekg_tda_arrhythmia_detection/assets/73852653/73b18baa-2dc0-4c87-9854-9ba31fe38390" width="700" height="400">

<br>

<img src="https://github.com/hdlugas/ekg_tda_arrhythmia_detection/assets/73852653/211637e6-b929-4db1-9e01-4f21af61bcc0" width="500" height="400">

<br>
<br>
<br>
<br>
<br>

<img src="https://github.com/hdlugas/ekg_tda_arrhythmia_detection/assets/73852653/4d0234d1-de0f-4860-840b-dd97bebae0dc" width="500" height="400">

<br> 
<br>
<br>
<br>
<br>

<img src="https://github.com/hdlugas/ekg_tda_arrhythmia_detection/assets/73852653/56c80ebb-e508-42d8-af78-6f27c734d33f" width="700" height="400">

<br> 

<img src="https://github.com/hdlugas/ekg_tda_arrhythmia_detection/assets/73852653/c5cd0c89-70d3-4ce6-8c0e-77e7d2487562" width="500" height="400">


