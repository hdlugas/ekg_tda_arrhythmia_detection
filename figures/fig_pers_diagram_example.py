import numpy as np
import matplotlib.pyplot as plt
import homcloud.interface as hc

data = ([4.9,5],
        [5.1,6],
        [5.7,5.1],
        [5.9,5],
        [6.8,7],
        [5.2,6.9],
        [6.5,5.9],
        [6.1,7.1],
        [9.8,10],
        [9.7,13],
        [10.1,15],
        [15.1,10],
        [15.6,12],
        [11,16.7],
        [12.2,16.5],
        [11.9,8.5],
        [14.5,15.5],
        [13,9.5],
        [13.2,16],
        [14.2,9.2],
        [14.8,15])

data=np.asarray(data)

data[:,0] = np.subtract(data[:,0], 5)
data[:,1] = np.subtract(data[:,1], 5)
#data[:,1] = np.multiply(data[:,1], 1.5)

#plt.scatter(data[:,0], data[:,1])
#plt.show()


r1 = 0.570
r2 = 0.805
r3 = 1.552
r4 = 3.011

#fig, (ax0,ax1,ax2,ax3,ax4,ax5) = plt.subplots(3,2, figsize=(10,15))
#fig, axs = plt.subplots(3, 2, figsize=(10,15))
fig, axs = plt.subplots(3, 2)


#plt.subplot(2,3,2)
plt.subplot(3,2,1)
plt.xlim(-5,15)
plt.ylim(-5,15)
plt.xticks((-5,0,5,10,15), fontsize=14)
plt.yticks((-5,0,5,10,15), fontsize=14)
plt.scatter(data[:,0],data[:,1],color='black')
plt.title('A) Example Data', fontsize=18)
plt.xlabel('x-axis', fontsize=14)
plt.ylabel('y-axis', fontsize=14)

#plt.subplot(2,3,2)
plt.subplot(3,2,2)
plt.xlim(-5,15)
plt.ylim(-5,15)
plt.xticks((-5,0,5,10,15), fontsize=14)
plt.yticks((-5,0,5,10,15), fontsize=14)
plt.scatter(data[:,0],data[:,1])
for i in range(0, data.shape[0]):
  c = plt.Circle(data[i,:], radius=r1, color='black')
  plt.gca().add_artist(c)
plt.title('B) Radius ' + '%0.2f' % r1, fontsize=18)
plt.xlabel('x-axis', fontsize=14)
plt.ylabel('y-axis', fontsize=14)

#plt.subplot(2,3,3)
plt.subplot(3,2,3)
plt.xlim(-5,15)
plt.ylim(-5,15)
plt.xticks((-5,0,5,10,15), fontsize=14)
plt.yticks((-5,0,5,10,15), fontsize=14)
plt.scatter(data[:,0],data[:,1])
for i in range(0, data.shape[0]):
  c = plt.Circle(data[i,:], radius=r2, color='black')
  plt.gca().add_artist(c)
plt.title('C) Radius ' + '%0.2f' % r2, fontsize=18)
plt.xlabel('x-axis', fontsize=14)
plt.ylabel('y-axis', fontsize=14)

#plt.subplot(2,3,4)
plt.subplot(3,2,4)
plt.xlim(-5,15)
plt.ylim(-5,15)
plt.xticks((-5,0,5,10,15), fontsize=14)
plt.yticks((-5,0,5,10,15), fontsize=14)
plt.scatter(data[:,0],data[:,1])
for i in range(0, data.shape[0]):
  c = plt.Circle(data[i,:], radius=r3, color='black')
  plt.gca().add_artist(c)
plt.title('D) Radius ' + '%0.2f' % r3, fontsize=18)
plt.xlabel('x-axis', fontsize=14)
plt.ylabel('y-axis', fontsize=14)

#plt.subplot(2,3,5)
plt.subplot(3,2,5)
plt.xlim(-5,15)
plt.ylim(-5,15)
plt.xticks((-10,0,10,20), fontsize=14)
plt.yticks((-5,0,5,10,15), fontsize=14)
plt.scatter(data[:,0],data[:,1])
for i in range(0, data.shape[0]):
  c = plt.Circle(data[i,:], radius=r4, color='black')
  plt.gca().add_artist(c)
plt.title('E) Radius ' + '%0.2f' % r4, fontsize=18)
plt.xlabel('x-axis', fontsize=16)
plt.ylabel('y-axis', fontsize=16)

output=hc.PDList.from_alpha_filtration(data,no_squared=True,save_boundary_map=True,save_phtrees=True,save_to="pointcloud.pdgm")
pd1=hc.PDList("pointcloud.pdgm").dth_diagram(1)
persist=np.asarray(pd1.deaths-pd1.births)
births=np.asarray(pd1.births)
deaths=np.asarray(pd1.deaths)
x=np.linspace(0,np.amax(births),100)
#plt.subplot(2,3,6)
plt.subplot(3,2,6)
plt.scatter(pd1.births,pd1.deaths,color='black',label='H1 features')
plt.plot(x,x,color='gray',label='y=x line', linestyle='dashed')
plt.xlabel('Birth Radius', fontsize=14)
plt.ylabel('Death Radius', fontsize=14)
plt.xlim(0,2)
plt.ylim(0,3.5)
plt.xticks([0,0.5,1,1.5,2], fontsize=14)
plt.yticks([0,1,2,3], fontsize=14)
plt.legend(loc='upper left')
plt.annotate('(0.57,0.81)', xy=[0.33,1], fontsize=15)
plt.annotate('(1.55,3.01)', xy=[1.36,2.5], fontsize=15)
plt.title('F) Persistence Diagram of Dimension One Homology Features', fontsize=17)

plt.tight_layout()
plt.subplots_adjust(wspace=0.3, hspace=0.6)
plt.show()
#plt.savefig('/home/hunter/ekg/afib2/figures/pers_diagram_example.png')




