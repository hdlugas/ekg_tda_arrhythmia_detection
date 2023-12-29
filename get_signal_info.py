
import numpy as np
import pandas as pd
import os
import csv
import math
import homcloud.interface as hc
#from ecgdetectors import Detectors
from numpy.random.mtrand import normal
from matplotlib.backends.backend_pdf import PdfPages
from scipy import signal
from processing import *
from cycles import *
from intervals import *

path_raw = '/home/hunter/ekg/ECGDataDenoised/'
path_processed = '/home/hunter/ekg/afib2/processed_data_all/'
file_names = os.listdir(path_raw)

diagnostics = pd.read_csv('/home/hunter/ekg/afib/data/diagnostics.csv')

unclassified_signals = pd.read_csv('/home/hunter/ekg/afib2/scripts/unclassified_file_names.csv')
unclassified_signals = np.array(unclassified_signals.iloc[:,0])

file_name_vec = []

for i in range(28,len(unclassified_signals)):
    file_name = unclassified_signals[i] + '.csv'
    file_name_raw = str(file_name[0:26])

    print('\niteration #', i)
    print(file_name)

    new_dir = path_processed + file_name_raw + '/'
    os.mkdir(new_dir)

    amplitudes_raw = np.genfromtxt(path_raw + file_name, delimiter=',')[:,1]

    diff = np.max(amplitudes_raw) - np.min(amplitudes_raw)
    if diff == 0:
        amplitudes_raw = amplitudes_raw + 10
        diff = np.max(amplitudes_raw) - np.min(amplitudes_raw)
        print('###### Division by 0 ######')

    amplitudes_raw = (amplitudes_raw - np.min(amplitudes_raw)) / diff
    baseline = np.median(amplitudes_raw)
    amplitudes = np.zeros(2*len(amplitudes_raw))
    amplitudes[::1] = baseline
    amplitudes[::2] = amplitudes_raw

    ekg = np.array([np.linspace(0,10,len(amplitudes)), amplitudes])

    output = hc.PDList.from_alpha_filtration(ekg.T, no_squared=True, save_boundary_map=True, save_phtrees=True, save_to="pointcloud.pdgm")
    pd1 = hc.PDList("pointcloud.pdgm").dth_diagram(1)

    persist = np.asarray(pd1.deaths-pd1.births)
    births = np.asarray(pd1.births)
    deaths = np.asarray(pd1.deaths)
    
    cycle_centroid_xcs, cycle_centroid_ycs, bps = get_vol_opt_cycle_centroid_coords(persist, pd1)

    csv_filename = os.path.join(new_dir, 'persistence.csv')
    with open(csv_filename, 'w') as csvfile:
        csvwriter = csv.writer(csvfile)
        fields = ['persist', 'births', 'deaths', 'centroid_xc', 'centroid_yc']
        csvwriter.writerow(fields) 
        for i in range(0, len(persist)):
            row = [persist[i], births[i], deaths[i], cycle_centroid_xcs[i], cycle_centroid_ycs[i]]
            csvwriter.writerow(row)
    
    bps_output = []
    for cycle in bps:
        for coords in cycle:
            bps_output.append(coords[0])
            bps_output.append(coords[1])
        bps_output.append(-999)

    csv_filename = os.path.join(new_dir, 'bps.csv')
    with open(csv_filename, 'w') as csvfile:
        csvwriter=csv.writer(csvfile)
        csvwriter.writerow(bps_output)



