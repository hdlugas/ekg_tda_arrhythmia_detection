# Electrocardiogram arrhythmia detection with novel signal processing and persistent homology-derived predictors

Descriptions of files:

cycles.py: contains functions to compute the time-coordinate and amplitude coordinate of the centroid of a given 1-cycle.

get_signal_info.py: processes raw ECG signal by normalizing its amplitude to be confined to [0,1], introduces isoelectric baseline, and computes and saves persistent homology-derived statistics such as birth radii, death radii, persistence, and centroid coordinates of optimal representative cycles.

fig_vietoris_rips_example.py: creates figure of toy example
<br> 
<img src="https://github.com/hdlugas/ekg_tda_arrhythmia_detection/assets/73852653/77d18e87-2d0e-4f90-a54f-cd3341a3683d" width="500" height="400">

fig_pers_diagram_example.py: creates figure of toy example
<br> 
<img src="https://github.com/hdlugas/ekg_tda_arrhythmia_detection/assets/73852653/1b733b0f-b852-4680-a5c3-7b27b5fbac05" width="150" height="280">

get_ml_input_all.py: creates dataframe with each row corresponding to an ECG signal and with column representing predictor variables for use in statistical models

models/: this directory contains a script for each type of statistical model used in each of the three binary classifications
<br> 
<img src="https://github.com/hdlugas/ekg_tda_arrhythmia_detection/assets/73852653/211637e6-b929-4db1-9e01-4f21af61bcc0" width="500" height="400">
<br> 
<img src="https://github.com/hdlugas/ekg_tda_arrhythmia_detection/assets/73852653/f5a2ae9a-44da-4844-bbad-79a06d987ce9" width="500" height="400">
<br> 
<img src="https://github.com/hdlugas/ekg_tda_arrhythmia_detection/assets/73852653/c5cd0c89-70d3-4ce6-8c0e-77e7d2487562" width="500" height="400">


