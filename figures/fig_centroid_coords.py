import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from ecg_detectors import Detectors
import homcloud.interface as hc
import os
import scipy.stats
import matplotlib.pyplot as plt

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


#import rhythm labels for each EKG signal
diagnostics = pd.read_csv('/home/hunter/ekg/afib/data/diagnostics.csv')

fname = diagnostics['FileName'][np.where(diagnostics['Rhythm'] == 'SR')[0][3]]
path = '/home/hunter/ekg/ECGDataDenoised/' + fname + '.csv'
amplitudes = np.genfromtxt(path, delimiter=',')[:,1]
times = np.linspace(0,10,len(amplitudes))
diff = np.max(amplitudes) - np.min(amplitudes)
amplitudes = (amplitudes - np.min(amplitudes)) / diff

baseline = np.median(amplitudes)
amplitudes_tmp = np.zeros(2*len(amplitudes))
amplitudes_tmp[::1] = baseline
amplitudes_tmp[::2] = amplitudes
times_tmp = np.linspace(0,10,len(amplitudes_tmp))
sf = 500
detectors = Detectors(sf)
r_peak_idxs = np.asarray(detectors.wqrs_detector(amplitudes))
r_peak_xcs = np.divide(r_peak_idxs, 1000)
ekg_baseline = np.transpose(np.array([times_tmp, amplitudes_tmp]))




ekg_baseline_trimmed = ekg_baseline[2000:3100,:]
output=hc.PDList.from_alpha_filtration(ekg_baseline_trimmed,no_squared=True,save_boundary_map=True,save_phtrees=True,save_to="pointcloud.pdgm")
pd1=hc.PDList("pointcloud.pdgm").dth_diagram(1)
persist=np.asarray(pd1.deaths-pd1.births)
births=np.asarray(pd1.births)
deaths=np.asarray(pd1.deaths)
idxs = []
for i in range(0,len(births)):
    if births[i] < 0.008 and deaths[i] > 0.02:
        idxs.append(i)
bps = []
for i in range(0,len(persist)):
    pair = hc.Pair(pd1,i)
    opt_vol = pair.optimal_volume()
    bps.append(np.asarray(opt_vol.boundary_points()))

#print(np.mean(bps[idxs[1]][:,0]))
#print(np.mean(bps[idxs[1]][:,1]))
#print(np.mean(bps[idxs[2]][:,0]))
#print(np.mean(bps[idxs[2]][:,1]))

#t_xc = 2.43
t_xc = 2.45
#t_yc = 0.11
t_yc = 0.14
p_xc = 2.85

fig, axs = plt.subplots(3,1)

plt.subplot(3,1,2)
plt.scatter(ekg_baseline_trimmed[:,0], ekg_baseline_trimmed[:,1], color='black', s=1)
plt.scatter(times_tmp[r_peak_idxs[[3,4]]*2], amplitudes_tmp[r_peak_idxs[[3,4]]*2], color='red', s=1, label='R-waves')
plt.scatter(bps[idxs[1]][:,0], bps[idxs[1]][:,1], s=1, c='green', label='P-wave')
plt.scatter(bps[idxs[2]][:,0], bps[idxs[2]][:,1], s=1, c='darkorange', label='T-wave')

plt.plot([t_xc,times_tmp[r_peak_idxs[4]*2]],[0.76,0.76],color='dimgray',linewidth=1.5)
plt.plot([times_tmp[r_peak_idxs[4]*2],times_tmp[r_peak_idxs[4]*2]],[0.71,0.81],color='dimgray',linewidth=1.5)
plt.plot([t_xc,t_xc],[0.71,0.81],color='dimgray',linewidth=1.5)
plt.annotate('T-wave Effective Time-Coordinate:', xy=[2.5,0.93], fontsize=7)
plt.annotate('3 - 2.43 = 0.57', xy=[2.6,0.8], fontsize=7)

plt.plot([p_xc,times_tmp[r_peak_idxs[4]*2]],[0.22,0.22],color='dimgray',linewidth=1.5)
plt.plot([times_tmp[r_peak_idxs[4]*2],times_tmp[r_peak_idxs[4]*2]],[0.17,0.27],color='dimgray',linewidth=1.5)
plt.plot([p_xc,p_xc],[0.17,0.27],color='dimgray',linewidth=1.5)
plt.annotate('P-wave Effective Time-Coordinate:', xy=[2.6,0.45], fontsize=7)
plt.annotate('3 - 2.85 = 0.15', xy=[2.8,0.31], fontsize=7)
plt.xlim(2,3.1)
plt.ylim(0,1.05)
plt.xticks([2,2.2,2.4,2.6,2.8,3,3.1], fontsize=7)
plt.yticks([0,0.5,1], fontsize=7)
plt.ylabel('Amplitude', fontsize=7)
plt.title('B) Gray Region: Effective Centroid Time-Coordinates', fontsize=10)
plt.legend(loc='center left', markerscale=4, fontsize=8)
plt.scatter(times_tmp[r_peak_idxs[[3,4]]*2], amplitudes_tmp[r_peak_idxs[[3,4]]*2], color='red', s=13, label='R-waves')




plt.subplot(3,1,3)
plt.scatter(ekg_baseline_trimmed[:,0], ekg_baseline_trimmed[:,1], color='black', s=1)
plt.scatter(times_tmp[r_peak_idxs[[3,4]]*2], amplitudes_tmp[r_peak_idxs[[3,4]]*2], color='red', s=1, label='R-waves')
plt.scatter(bps[idxs[1]][:,0], bps[idxs[1]][:,1], s=1, c='green', label='P-wave')
plt.scatter(bps[idxs[2]][:,0], bps[idxs[2]][:,1], s=1, c='darkorange', label='T-wave')

plt.plot([2.33,2.33],[baseline,1],color='dimgray',linewidth=1.5)
plt.plot([2.32,2.34],[baseline,baseline],color='dimgray',linewidth=1.5)
plt.plot([2.32,2.34],[1,1],color='dimgray',linewidth=1.5)
plt.plot([t_xc,t_xc],[t_yc,baseline],color='dimgray',linewidth=1.5)
plt.plot([t_xc-0.01,t_xc+0.01],[t_yc,t_yc],color='dimgray',linewidth=1.5)
plt.plot([t_xc-0.01,t_xc+0.01],[baseline,baseline],color='dimgray',linewidth=1.5)
plt.annotate('A - baseline = 0.08', xy=[2.51,0.1], fontsize=7)
plt.annotate('1 - baseline = 0.94', xy=[2.34,0.55], fontsize=7)
plt.annotate('T-wave Effective Amplitude-Coordinate:', xy=[2.5,0.9], fontsize=7)
plt.annotate('0.08 / 0.94 = 0.09', xy=[2.615,0.73], fontsize=7)

plt.xlim(2,3.1)
plt.ylim(-0.05,1.1)
plt.xticks([2,2.2,2.4,2.6,2.8,3,3.1], fontsize=7)
plt.yticks([0,0.5,1], fontsize=7)
plt.xlabel('Time (seconds)', fontsize=7)
plt.ylabel('Amplitude', fontsize=7)
plt.title('C) Gray Region: Effective Centroid Amplitude-Coordinate of T-wave', fontsize=10)
plt.legend(loc='center left', markerscale=4, fontsize=8)
plt.scatter(times_tmp[r_peak_idxs[[3,4]]*2], amplitudes_tmp[r_peak_idxs[[3,4]]*2], color='red', s=13, label='R-waves')






plt.subplot(3,1,1)
plt.scatter(ekg_baseline[:,0], ekg_baseline[:,1], color='black', s=1)
plt.scatter(times_tmp[r_peak_idxs*2], amplitudes_tmp[r_peak_idxs*2], color='red', s=1, label='R-waves')
plt.scatter(bps[idxs[1]][:,0], bps[idxs[1]][:,1], s=1, c='green', label='P-wave')
plt.scatter(bps[idxs[2]][:,0], bps[idxs[2]][:,1], s=1, c='darkorange', label='T-wave')
plt.plot([2,2],[-0.05,1.05],color='gray',linewidth=2)
plt.plot([2,3.1],[1.05,1.05],color='gray',linewidth=2)
plt.plot([3.1,3.1],[-0.05,1.05],color='gray',linewidth=2)
plt.plot([2,3.1],[-0.05,-0.05],color='gray',linewidth=2)
plt.xlim(0,10)
plt.ylim(-0.1,1.1)
plt.xticks([0,2,4,6,8,10], fontsize=7)
plt.yticks([0,0.5,1], fontsize=7)
plt.title('A) Processed ECG Signal', fontsize=10)
plt.ylabel('Amplitude', fontsize=7)
plt.legend(loc='center right', markerscale=4, fontsize=8)
plt.scatter(times_tmp[r_peak_idxs*2], amplitudes_tmp[r_peak_idxs*2], color='red', s=13, label='R-waves')



#plt.subplots_adjust(wspace=0.5, hspace=0.8)
plt.subplots_adjust(hspace=0.8)
#plt.show()
plt.savefig('/home/hunter/ekg/afib2/figures/centroid_coords_example.eps', format='eps', dpi=1200)




