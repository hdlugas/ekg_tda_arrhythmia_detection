import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from ecg_detectors import Detectors
import PersistenceImages.persistence_images as pimg
import os
import scipy.stats
import matplotlib.pyplot as plt


#import rhythm labels for each EKG signal
diagnostics = pd.read_csv('/home/hunter/ekg/afib/data/diagnostics.csv')
unique, counts = np.unique(diagnostics['Rhythm'], return_counts=True)
#print(np.asarray((unique, counts)).T)

fname = diagnostics['FileName'][np.where(diagnostics['Rhythm'] == 'SR')[0][3]]
path = '/home/hunter/ekg/ECGDataDenoised/' + fname + '.csv'
amplitudes = np.genfromtxt(path, delimiter=',')[:,1]
times = np.linspace(0,10,len(amplitudes))


fig, axs = plt.subplots(3,1)

plt.subplot(3,1,1)
plt.scatter(times, amplitudes, s=0.5, c='black')
plt.xlim(0,10)
plt.ylim(-100,1100)
plt.xticks((0,2,4,6,8,10), fontsize=9)
plt.yticks((0,500,1000), fontsize=9)
#plt.xlabel('Time (seconds)', fontsize=9)
plt.ylabel('Amplitude (mV)', fontsize=9)
plt.title('Raw ECG Signal with Normal Sinus Rhythm', fontsize=12)


diff = np.max(amplitudes) - np.min(amplitudes)
amplitudes = (amplitudes - np.min(amplitudes)) / diff
plt.subplot(3,1,2)
plt.scatter(times, amplitudes, s=0.5, c='black')
plt.xlim(0,10)
plt.ylim(-0.1,1.1)
plt.xticks((0,2,4,6,8,10), fontsize=9)
plt.yticks((0,0.5,1), fontsize=9)
#plt.xlabel('Time (seconds)', fontsize=9)
plt.ylabel('Normalized\n Amplitude', fontsize=9)
plt.title('Normalized Signal', fontsize=12)



baseline = np.median(amplitudes)
amplitudes_tmp = np.zeros(2*len(amplitudes))
amplitudes_tmp[::1] = baseline
amplitudes_tmp[::2] = amplitudes
times_tmp = np.linspace(0,10,len(amplitudes_tmp))
sf = 500
detectors = Detectors(sf)
r_peak_idxs = np.asarray(detectors.wqrs_detector(amplitudes))
plt.subplot(3,1,3)
plt.scatter(times_tmp, amplitudes_tmp, s=0.5, c='black')
plt.scatter(times_tmp[r_peak_idxs*2], amplitudes_tmp[r_peak_idxs*2], s=10, c='red', label='R-waves')
plt.xlim(0,10)
plt.ylim(-0.1,1.1)
plt.xticks((0,2,4,6,8,10), fontsize=9)
plt.yticks((0,0.5,1), fontsize=9)
plt.xlabel('Time (seconds)', fontsize=9)
plt.ylabel('Normalized\n Amplitude', fontsize=9)
plt.title('Normalized Signal with Isoelectric Baseline', fontsize=12)
plt.legend(loc='center left', fontsize=8)



'''
#idxs = np.where(np.linspace(0,len(amplitudes_tmp),len(amplitudes_tmp)
idxs = np.where(np.linspace(0, (len(amplitudes_tmp)-1),len(amplitudes_tmp)) <= np.max(r_peak_idxs)*2)[0]
times2 = times_tmp[idxs]
amplitudes2 = amplitudes_tmp[idxs]
plt.subplot(4,1,4)
plt.scatter(times2, amplitudes2, s=0.5, c='black')
plt.scatter(times_tmp[r_peak_idxs*2], amplitudes_tmp[r_peak_idxs*2], s=10, c='red', label='R-waves')
plt.xlim(0,10)
plt.ylim(-0.1,1.1)
plt.xticks((0,2,4,6,8,10), fontsize=9)
plt.yticks((0,0.5,1), fontsize=9)
plt.xlabel('Time (seconds)', fontsize=9)
plt.ylabel('Normalized\n Amplitude', fontsize=9)
plt.title('Trimmed Normalized Signal with Isoelectric Baseline', fontsize=12)
plt.legend(loc='center left', fontsize=6)
'''


plt.subplots_adjust(hspace=0.8)
#plt.show()
plt.savefig('/home/hunter/ekg/afib2/figures/processing_pipeline_example.eps', format='eps', dpi=1200)



