import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from ecg_detectors import Detectors
import PersistenceImages.persistence_images as pimg
import os
import scipy.stats
import matplotlib.pyplot as plt
import sys
from cycles import *
from intervals import *

def get_ekg(path):
    amplitudes_raw = np.genfromtxt(path, delimiter=',')[:,1]
    diff = np.max(amplitudes_raw) - np.min(amplitudes_raw)
    if diff == 0:
        amplitudes_raw = amplitudes_raw + 1
        diff = np.max(amplitudes_raw) - np.min(amplitudes_raw)
    amplitudes_raw = (amplitudes_raw - np.min(amplitudes_raw)) / diff
    baseline = np.median(amplitudes_raw)
    amplitudes = np.zeros(2*len(amplitudes_raw))
    amplitudes[::1] = baseline
    amplitudes[::2] = amplitudes_raw
    ekg = np.array([np.linspace(0,10,len(amplitudes)), amplitudes])
    return baseline, ekg



def get_effective_centroid_xcs(ekg, cycle_xcs, r_peak_xcs):
    #get the horizontal distance between each cycle centroid and its subsequent R-wave
    #note that r_peak_idxs is passed in in ascending order
    xcs = []
    #print(f'length of cycle_xcs: {len(cycle_xcs)}')
    #print(f'length of r_peak_xcs: {len(r_peak_xcs)}')
    for i in range(0, len(cycle_xcs)):
        exit = False
        j = 1
        while exit == False:
            #print(f'i={i}')
            #print(f'j={j}')
            if cycle_xcs[i] <= r_peak_xcs[j]:
                xcs.append(r_peak_xcs[j] - cycle_xcs[i])
                exit = True
            j = j + 1
    return xcs 


def get_rr_int_avg(r_peak_xcs):
    if len(r_peak_xcs) > 1:
        rr_ints = []
        for i in range(1,len(r_peak_xcs)):
            rr_ints.append(r_peak_xcs[i] - r_peak_xcs[i-1])
    else:
        rr_ints = 0
    return np.mean(rr_ints), np.std(rr_ints)


#import rhythm labels for each EKG signal
diagnostics = pd.read_csv('/home/hunter/ekg/afib/data/diagnostics.csv')
unique, counts = np.unique(diagnostics['Rhythm'], return_counts=True)
#print(np.asarray((unique, counts)).T)

#sampling frequency
sf = 500

#pass the sampling frequency to the constructor for R-wave peak detection object
detectors = Detectors(sf)

path_raw = '/home/hunter/ekg/afib/data/ECGDataDenoised/'

processed_data_path = '/home/hunter/ekg/afib2/processed_data_all/'
dirs = os.listdir(processed_data_path)


#ns = [5,6,7,8]
#ns = [9,10,11,12,13]
#ns = [14,15,16,17]
#ns = [18,19,20]
#ns = [21,22]
ns = [23,24,25,26,27,28,29,30]

for n in ns:
    print(f'\n\n###### n = {n} #######')
    names = []
    for i in range(0,n):
        names.append('persist' + str(i+1))
    for i in range(0,n):
        names.append('birth' + str(i+1))
    for i in range(0,n):
        names.append('death' + str(i+1))
    for i in range(0,n):
        names.append('centroid_xc' + str(i+1))
    for i in range(0,n):
        names.append('centroid_yc' + str(i+1))
    for i in range(0,n):
        names.append('entropy' + str(i+1))

    names = np.hstack([names, ['mean_persist', 'sd_persist', 'mean_births', 
                                'sd_births', 'mean_deaths', 'sd_deaths',
                                'mean_centroid_xs', 'sd_centroid_xs', 
                                'mean_centroid_ys', 'sd_centroid_ys',
                                'n_r_waves', 'mean_rr_int', 'sd_rr_int',
                                'n_cycles', 'rhythm', 'file_name']])



    #for i in range(0, 3):
    for i in range(0, len(dirs)):
        feature_vec = []
        file_name = dirs[i]
        path = processed_data_path + file_name + '/'
        current_dir = os.listdir(path)
        if i%100 == 0:
            print(f'Iteration: {i}')

        rhythm = diagnostics['Rhythm'][np.where(diagnostics['FileName'] == file_name)[0]]

        ekg_path = path_raw + dirs[i] + '.csv'
        baseline, ekg = get_ekg(ekg_path)

        ekg = np.transpose(ekg)

        #amplitudes_raw = np.genfromtxt(ekg_path, delimiter=',', dtype=float)[:,1]
        r_peak_idxs = np.asarray(detectors.wqrs_detector(ekg[:,1]))
        r_peak_xcs = np.divide(r_peak_idxs, 1000)
        rr_int_avg, rr_int_sd = get_rr_int_avg(r_peak_xcs)

        #plt.scatter(ekg[:,0], ekg[:,1], color='blue')
        #plt.scatter(ekg[r_peak_idxs,0], ekg[r_peak_idxs,1], color='red')


        #persists = pd.read_csv(path + current_dir[np.where(current_dir == 'persistence.csv')[0]])
        persists = pd.read_csv(path + '/persistence.csv')

        '''
        bps_tmp = np.genfromtxt(path + file_name + '/bps.csv', delimiter=',', dtype=float)
        cycle = []
        bps = []
        for j in range(0,len(bps_tmp)):
            if j%2 == 0 and bps_tmp[j] != -999:
                x = bps_tmp[j]
            if j%2 == 1:
                y = bps_tmp[j]
            if j%2 == 0 and bps_tmp[j] != -999 and j != 0:
                cycle.append([x,y])
            if bps_tmp[j] == -999:
                bps.append(np.array(cycle))
                cycle = []
        '''
                

        yc_thresh_tmp = 0.5
        yc_thresh = baseline + (1 - baseline) * yc_thresh_tmp
        persists_tmp = persists[persists['centroid_yc'] < yc_thresh] 
        while persists_tmp.shape[0] < n:
            yc_thresh_tmp = yc_thresh_tmp + 0.1
            yc_thresh = baseline + (1 - baseline) * yc_thresh_tmp
            persists_tmp = persists[persists['centroid_yc'] < yc_thresh] 

        persists = persists_tmp
        persists = persists[persists['centroid_xc'] <= r_peak_xcs[(len(r_peak_xcs)-1)]]

        idxs = np.argpartition(persists['persist'], -n)[-n:].to_numpy()

        pers = persists['persist'].iloc[idxs]
        births = persists['births'].iloc[idxs]
        deaths = persists['deaths'].iloc[idxs]
        centroid_xcs = get_effective_centroid_xcs(ekg, persists['centroid_xc'].iloc[idxs].to_numpy(), r_peak_xcs)
        centroid_ycs = np.divide(persists['centroid_yc'].iloc[idxs] - baseline, (1 - baseline))
        
        processed_df = pd.DataFrame({'persist':pers, 'birth':births, 'death':deaths, 
                                     'centroid_xc':centroid_xcs, 'centroid_yc':centroid_ycs})


        ents = []
        for k in range(0, processed_df.shape[0]):
            vec_tmp = processed_df[['persist', 'birth', 'death', 'centroid_xc', 'centroid_yc']].iloc[k]
            vec_tmp = vec_tmp / np.sum(vec_tmp)
            ents.append(scipy.stats.entropy(vec_tmp))
        
        processed_df['entropy'] = ents
        processed_df.replace([-np.inf], 0, inplace=True)
        processed_df = processed_df.reset_index(drop=True)

        '''
        intervals = get_intervals_and_H1wave_idxs(ekg, r_peak_xcs, rr_int_avg, persists['persist'].to_numpy(), 
                persists['births'].to_numpy(), persists['centroid_xc'].to_numpy(), persists['centroid_yc'].to_numpy(), bps)
        '''

        obs_vec = np.hstack([processed_df['persist'],
                                processed_df['birth'],
                                processed_df['death'],
                                processed_df['centroid_xc'],
                                processed_df['centroid_yc'],
                                processed_df['entropy'],
                                np.mean(pers),
                                np.std(pers),
                                np.mean(births),
                                np.std(births),
                                np.mean(deaths),
                                np.std(deaths),
                                np.mean(centroid_xcs),
                                np.std(centroid_xcs),
                                np.mean(centroid_ycs),
                                np.std(centroid_ycs),
                                len(r_peak_idxs),
                                rr_int_avg,
                                rr_int_sd,
                                persists.shape[0],
                                rhythm,
                                file_name])

        if i == 0:
            mat = obs_vec
        if i >= 1:
            mat = np.vstack([mat, obs_vec])

    df = pd.DataFrame(mat, columns=names)
    df.to_csv(f'/home/hunter/ekg/afib2/ml_input_all/input' + str(n) + '.csv', index=False)





