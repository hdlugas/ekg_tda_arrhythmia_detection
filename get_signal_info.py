import numpy as np
import pandas as pd
import os
import csv
import homcloud.interface as hc
import math
import sys
from cycles import *

path_raw = '/wsu/home/fy/fy73/fy7392/ekg/data/ECGDataDenoised/'
path_processed = '/wsu/home/fy/fy73/fy7392/ekg/afib2/processed_data/'
file_names = os.listdir(path_raw)

diagnostics = pd.read_csv('/wsu/home/fy/fy73/fy7392/ekg/data/diagnostics.csv')

idx = int(sys.argv[1])

file_name = file_names[idx]

file_name_raw = str(file_name[0:26])
rhythm = diagnostics['Rhythm'][np.where(diagnostics['FileName'] == file_name_raw)[0][0]]
if rhythm == 'AFIB':
    new_dir = path_processed + 'afib/' + file_name_raw + '/'
if rhythm == 'SR':
    new_dir = path_processed + 'sr/' + file_name_raw + '/'
if rhythm == 'AF':
    new_dir = path_processed + 'af/' + file_name_raw + '/'
if rhythm == 'AT':
    new_dir = path_processed + 'at/' + file_name_raw + '/'
if rhythm == 'AVNRT':
    new_dir = path_processed + 'avnrt/' + file_name_raw + '/'
if rhythm == 'AVRT':
    new_dir = path_processed + 'avrt/' + file_name_raw + '/'
if rhythm == 'SA':
    new_dir = path_processed + 'sa/' + file_name_raw + '/'
if rhythm == 'SAAWR':
    new_dir = path_processed + 'saawr/' + file_name_raw + '/'
if rhythm == 'SB':
    new_dir = path_processed + 'sb/' + file_name_raw + '/'
if rhythm == 'SR':
    new_dir = path_processed + 'sr/' + file_name_raw + '/'
if rhythm == 'ST':
    new_dir = path_processed + 'st/' + file_name_raw + '/'
if rhythm == 'SVT':
    new_dir = path_processed + 'svt/' + file_name_raw + '/'


if os.path.exists(new_dir) == False:
    os.mkdir(new_dir)

#import raw Lead II ECG signal
amplitudes_raw = np.genfromtxt(path_raw + file_name, delimiter=',')[:,1]

#include isoelectric baseline
diff = np.max(amplitudes_raw) - np.min(amplitudes_raw)
if diff == 0:
    sys.exit()
amplitudes_raw = (amplitudes_raw - np.min(amplitudes_raw)) / diff
baseline = np.median(amplitudes_raw)
amplitudes = np.zeros(2*len(amplitudes_raw))
amplitudes[::1] = baseline
amplitudes[::2] = amplitudes_raw
ekg = np.array([np.linspace(0,10,len(amplitudes)), amplitudes])

#compute persistent homology
output = hc.PDList.from_alpha_filtration(ekg.T, no_squared=True, save_boundary_map=True, save_phtrees=True, save_to="pointcloud.pdgm")
pd1 = hc.PDList("pointcloud.pdgm").dth_diagram(1)
persist = np.asarray(pd1.deaths-pd1.births)
births = np.asarray(pd1.births)
deaths = np.asarray(pd1.deaths)

#get the centroid coordinates of the minimal-area representative cycles
cycle_centroid_xcs, cycle_centroid_ycs, bps = get_vol_opt_cycle_centroid_coords(persist, pd1)

#save persistent homology output
csv_filename = os.path.join(new_dir, 'persistence.csv')
with open(csv_filename, 'w') as csvfile:
    csvwriter = csv.writer(csvfile)
    fields = ['persist', 'births', 'deaths', 'centroid_xc', 'centroid_yc']
    csvwriter.writerow(fields) 
    for i in range(0, len(persist)):
        row = [persist[i], births[i], deaths[i], cycle_centroid_xcs[i], cycle_centroid_ycs[i]]
        csvwriter.writerow(row)
    

#save the representative cycles
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




