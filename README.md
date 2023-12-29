# Electrocardiogram arrhythmia detection with novel signal processing and persistent homology-derived predictors

Descriptions of files:

cycles.py: contains functions to compute the time-coordinate and amplitude coordinate of the centroid of a given 1-cycle.

get_signal_info.py: processes raw ECG signal by normalizing its amplitude to be confined to [0,1], introduces isoelectric baseline, and computes and saves persistent homology-derived statistics such as birth radii, death radii, persistence, and centroid coordinates of optimal representative cycles.

fig_vietoris_rips_example.py: creates figure of toy example

fig_pers_diagram_example.py: creates figure of toy example

get_ml_input_all.py: creates dataframe with each row corresponding to an ECG signal and with column representing predictor variables for use in statistical models




