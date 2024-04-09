import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from ecg_detectors import Detectors
import PersistenceImages.persistence_images as pimg
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

#import rhythm labels for each EKG signal
diagnostics = pd.read_csv('/home/hunter/ekg/afib/data/diagnostics.csv')
unique, counts = np.unique(diagnostics['Rhythm'], return_counts=True)
#print(np.asarray((unique, counts)).T)

fname_sr = diagnostics['FileName'][np.where(diagnostics['Rhythm'] == 'SR')[0][3]]
fname_af = diagnostics['FileName'][np.where(diagnostics['Rhythm'] == 'AFIB')[0][3]]
path_sr = '/home/hunter/ekg/ECGDataDenoised/' + fname_sr + '.csv'
path_af = '/home/hunter/ekg/ECGDataDenoised/' + fname_af + '.csv'
amplitudes_sr = np.genfromtxt(path_sr, delimiter=',')[:,1]
amplitudes_af = np.genfromtxt(path_af, delimiter=',')[:,1]
times_sr = np.linspace(0,10,len(amplitudes_sr))
times_af = np.linspace(0,10,len(amplitudes_af))
diff_sr = np.max(amplitudes_sr) - np.min(amplitudes_sr)
diff_af = np.max(amplitudes_af) - np.min(amplitudes_af)
amplitudes_sr = (amplitudes_sr - np.min(amplitudes_sr)) / diff_sr
amplitudes_af = (amplitudes_af - np.min(amplitudes_af)) / diff_af
ekg_sr_wo_baseline = np.transpose(np.array([times_sr, amplitudes_sr]))
ekg_af_wo_baseline = np.transpose(np.array([times_af, amplitudes_af]))

baseline_sr = np.median(amplitudes_sr)
baseline_af = np.median(amplitudes_af)
amplitudes_tmp_sr = np.zeros(2*len(amplitudes_sr))
amplitudes_tmp_af = np.zeros(2*len(amplitudes_af))
amplitudes_tmp_sr[::1] = baseline_sr
amplitudes_tmp_af[::1] = baseline_af
amplitudes_tmp_sr[::2] = amplitudes_sr
amplitudes_tmp_af[::2] = amplitudes_af
times_tmp_sr = np.linspace(0,10,len(amplitudes_tmp_sr))
times_tmp_af = np.linspace(0,10,len(amplitudes_tmp_af))
sf = 500
detectors = Detectors(sf)
r_peak_idxs_sr = np.asarray(detectors.wqrs_detector(amplitudes_sr))
r_peak_idxs_af = np.asarray(detectors.wqrs_detector(amplitudes_af))
r_peak_xcs_sr = np.divide(r_peak_idxs_sr, 1000)
r_peak_xcs_af = np.divide(r_peak_idxs_af, 1000)
idxs_sr = np.where(np.linspace(0, (len(amplitudes_tmp_sr)-1),len(amplitudes_tmp_sr)) <= np.max(r_peak_idxs_sr)*2)[0]
idxs_af = np.where(np.linspace(0, (len(amplitudes_tmp_af)-1),len(amplitudes_tmp_af)) <= np.max(r_peak_idxs_af)*2)[0]
times2_sr = times_tmp_sr[idxs_sr]
times2_af = times_tmp_af[idxs_af]
amplitudes2_sr = amplitudes_tmp_sr[idxs_sr]
amplitudes2_af = amplitudes_tmp_af[idxs_af]
ekg_sr_baseline = np.transpose(np.array([times2_sr, amplitudes2_sr]))
ekg_af_baseline = np.transpose(np.array([times2_af, amplitudes2_af]))



fig, axs = plt.subplots(4,2)

plt.subplot(4,2,1)
plt.scatter(ekg_sr_wo_baseline[:,0], ekg_sr_wo_baseline[:,1], s=0.0001, c='black')
plt.xlim(0,np.max(ekg_sr_wo_baseline[:,0]))
plt.ylim(-0.1,1.1)
plt.xticks((0,2,4,6,8,10), fontsize=7)
plt.yticks((0,0.5,1), fontsize=7)
#plt.xlabel('Time (seconds)', fontsize=7)
plt.ylabel('Amplitude', fontsize=7)
plt.title('A) Normal Sinus Rhythm without Baseline', fontsize=8)


plt.subplot(4,2,5)
plt.scatter(ekg_af_wo_baseline[:,0], ekg_af_wo_baseline[:,1], s=0.0001, c='black')
plt.xlim(0,np.max(ekg_af_wo_baseline[:,0]))
plt.ylim(-0.1,1.1)
plt.xticks((0,2,4,6,8,10), fontsize=7)
plt.yticks((0,0.5,1), fontsize=7)
#plt.xlabel('Time (seconds)', fontsize=7)
plt.ylabel('Amplitude', fontsize=7)
plt.title('E) Atrial Fibrillation with Baseline', fontsize=8)


plt.subplot(4,2,7)
plt.scatter(ekg_af_baseline[:,0], ekg_af_baseline[:,1], s=0.0001, c='black')
plt.xlim(0,np.max(ekg_af_baseline[:,0]))
plt.ylim(-0.1,1.1)
plt.xticks((0,2,4,6,8,10), fontsize=7)
plt.yticks((0,0.5,1), fontsize=7)
plt.xlabel('Time (seconds)', fontsize=7)
plt.ylabel('Amplitude', fontsize=7)
plt.title('G) Atrial Fibrillation with Baseline', fontsize=8)




output=hc.PDList.from_alpha_filtration(ekg_sr_wo_baseline,no_squared=True,save_boundary_map=True,save_phtrees=True,save_to="pointcloud.pdgm")
pd1=hc.PDList("pointcloud.pdgm").dth_diagram(1)
births=np.asarray(pd1.births)
deaths=np.asarray(pd1.deaths)
x=np.linspace(0,np.amax(births),100)

plt.subplot(4,2,2)
plt.plot(x,x,color='gray',label='y=x line', linestyle='dashed', linewidth=0.7)
plt.scatter(births,deaths,color='darkblue',label='H1 features', s=0.7)
plt.ylabel('Death Radius', fontsize=7)
plt.xlim(0,0.1)
plt.ylim(0,0.1)
plt.xticks([0,0.05,0.1], fontsize=7)
plt.yticks([0,0.05,0.1], fontsize=7)
plt.legend(loc='lower right', markerscale=2, fontsize=5)
plt.title('B) PD: Normal Sinus Rhythm without Baseline', fontsize=8)




output=hc.PDList.from_alpha_filtration(ekg_sr_baseline,no_squared=True,save_boundary_map=True,save_phtrees=True,save_to="pointcloud.pdgm")
pd1=hc.PDList("pointcloud.pdgm").dth_diagram(1)
persist=np.asarray(pd1.deaths-pd1.births)
births=np.asarray(pd1.births)
deaths=np.asarray(pd1.deaths)
x=np.linspace(0,np.amax(births),100)
idxs = []
for i in range(0,len(births)):
    if births[i] < 0.008 and deaths[i] > 0.02:
        idxs.append(i)

bps = []
for i in range(0,len(persist)):
    pair = hc.Pair(pd1,i)
    opt_vol = pair.optimal_volume()
    bps.append(np.asarray(opt_vol.boundary_points()))

plt.subplot(4,2,4)
plt.plot(x,x,color='gray',label='y=x line', linestyle='dashed', linewidth=0.7)
plt.scatter(births,deaths,color='darkblue',label='Non-P,S,T-wave H1 features', s=0.6)
plt.scatter(births[idxs],deaths[idxs],color='darkorange',label='P,S,T-wave H1-features', s=0.6)
plt.ylabel('Death Radius', fontsize=7)
plt.xlim(0,0.1)
plt.ylim(0,0.1)
plt.xticks([0,0.05,0.1], fontsize=7)
plt.yticks([0,0.05,0.1], fontsize=7)
plt.legend(loc='lower right', markerscale=2, fontsize=4.5)
plt.title('D) PD: Normal Sinus Rhythm with Baseline', fontsize=8)



plt.subplot(4,2,3)
plt.scatter(ekg_sr_baseline[:,0], ekg_sr_baseline[:,1], s=0.0001, c='black')
for i in range(0,len(idxs)):
    if i == 0:
        plt.scatter(bps[idxs[i]][:,0], bps[idxs[i]][:,1], s=0.0001, c='darkorange', label='P,S,T-waves')
    else:
        plt.scatter(bps[idxs[i]][:,0], bps[idxs[i]][:,1], s=0.0001, c='darkorange')
plt.xlim(0,np.max(ekg_sr_baseline[:,0]))
plt.ylim(-0.1,1.1)
plt.xticks((0,2,4,6,8,10), fontsize=7)
plt.yticks((0,0.5,1), fontsize=7)
plt.ylabel('Amplitude', fontsize=7)
plt.title('C) Normal Sinus Rhythm with Baseline', fontsize=8)
plt.legend(loc='center right', markerscale=200, fontsize=5)




output=hc.PDList.from_alpha_filtration(ekg_af_wo_baseline,no_squared=True,save_boundary_map=True,save_phtrees=True,save_to="pointcloud.pdgm")
pd1=hc.PDList("pointcloud.pdgm").dth_diagram(1)
persist=np.asarray(pd1.deaths-pd1.births)
births=np.asarray(pd1.births)
deaths=np.asarray(pd1.deaths)
x=np.linspace(0,np.amax(births),100)
plt.subplot(4,2,6)
plt.plot(x,x,color='gray',label='y=x line', linestyle='dashed', linewidth=0.7)
plt.scatter(births,deaths,color='darkblue',label='H1 features', s=0.7)
plt.ylabel('Death Radius', fontsize=7)
plt.xlim(0,0.1)
plt.ylim(0,0.1)
plt.xticks([0,0.05,0.1], fontsize=7)
plt.yticks([0,0.05,0.1], fontsize=7)
plt.legend(loc='lower right', markerscale=2, fontsize=5)
plt.title('F) PD: Atrial Fibrillation without Baseline', fontsize=8)

output=hc.PDList.from_alpha_filtration(ekg_af_baseline,no_squared=True,save_boundary_map=True,save_phtrees=True,save_to="pointcloud.pdgm")
pd1=hc.PDList("pointcloud.pdgm").dth_diagram(1)
persist=np.asarray(pd1.deaths-pd1.births)
births=np.asarray(pd1.births)
deaths=np.asarray(pd1.deaths)
x=np.linspace(0,np.amax(births),100)
plt.subplot(4,2,8)
plt.plot(x,x,color='gray',label='y=x line', linestyle='dashed', linewidth=0.7)
plt.scatter(pd1.births,pd1.deaths,color='darkblue',label='H1 features', s=0.7)
plt.xlabel('Birth Radius', fontsize=7)
plt.ylabel('Death Radius', fontsize=7)
plt.xlim(0,0.1)
plt.ylim(0,0.1)
plt.xticks([0,0.05,0.1], fontsize=7)
plt.yticks([0,0.05,0.1], fontsize=7)
plt.legend(loc='lower right', markerscale=2, fontsize=5)
plt.title('H) PD: Atrial Fibrillation with Baseline', fontsize=8)



#plt.tight_layout()
plt.subplots_adjust(wspace=0.5, hspace=0.8)
#plt.show()
plt.savefig('/home/hunter/ekg/afib2/figures/ecg_persistence_example.eps', format='eps', dpi=1200)




