"""This script demonstrate activity localization imaging (ALI)
python port by Urs Böhm based on MATLAB code by Tsai-Wen Chen
https://github.com/Tsai-WenChen/Activity-Localization-Imaging"""


import numpy as np
from scipy import io
from ali_hp_filter import ali_hp_filter
from ali_spk_coarse import ali_spk_coarse
from ali_denoising import ali_denoising
from ali_spk_fine import ali_spk_fine
from ali_density_map import ali_density_map
from ali_assign_cluster import ali_assign_cluster
from ali_fp_support import ali_fp_support
from ali_t_decompose import ali_t_decompose
from scipy.ndimage import gaussian_filter
from skimage.feature import peak_local_max
import matplotlib.pyplot as plt

# 1) Load example data
data = np.asarray(io.loadmat('../../ali_demo_data.mat')['data'], dtype="float")
nframe=data.shape[2]
#%% 2) Detect and localize spikes, generate ALI map

fs=2000
win=int(fs/1000*10) # 10 ms window
df=ali_hp_filter(data,win) # temporal highpss filtering by removing median-filtered baseline traces from each pixel

#%% 2) Detect and localize spikes, generate ALI map

# detect candidate spikes in the hp filterred data by thresholding
spk=ali_spk_coarse(-df) # spk(k,:) contains a coarse coordinate [row, col, frame] of the kth spike

#%%
nsvd=25 # number of svd components, should be larger than the potential number of neurons 
df_AP=df[:,:,spk[:,2]] #the subset of frames that potentially contain spikes
df_AP_dnoised=ali_denoising(df_AP,nsvd)[0]

#%% determines fine coordinates of each spike with sub-pixel precision
spk_fine = spk.astype(np.float64)
spk_fine[:,:2]=ali_spk_fine(-df_AP_dnoised,15,4,spk[:,:2])[0]

#%% generate ALI map
f0 = np.mean(data,axis=2)
sz = f0.shape
factor = 4 # specify the resolution of the ALI map (4x higher than the original pixel resolution)
cnt,cen = ali_density_map(spk_fine[:,:2],sz,factor) #Count the number of APs in each spatial bin
alimap = gaussian_filter(cnt, sigma=0.7, radius=2)

#%% 3) Automatically detect ALI clusters from the ALI map
th=2 # detect peaks in the ALI map that are brighter than the value 'th'

pks=peak_local_max(alimap, threshold_abs=th)
clust_cen=np.array([cen[0][pks[:,0]],cen[1][pks[:,1]]]) # 2 x nclust center locations of detected clusters
nclust = clust_cen.shape[1]

r = 1.5
clust_idx = ali_assign_cluster(spk_fine[:,:2],clust_cen,r) # assign spikes to the nearest cluster within a distance of 1.5 pixels
#%% plot everything
idd = np.argsort(clust_cen[1,:]) # to make the order the same as the original ali matlab code
idd = idd[::-1]
f,a = plt.subplots(2,2)

a[0,0].imshow(f0, cmap='gray')
a[0,1].imshow(f0, cmap='gray')
a[0,1].plot(spk_fine[:,1], spk_fine[:,0], color='r', marker='.', markersize=2, ls='')
a[1,0].imshow(alimap, vmax=10, cmap='gray')
for n in range(nclust):
    a[1,1].plot(spk_fine[clust_idx==idd[n]+1,1], spk_fine[clust_idx==idd[n]+1,0], marker='.', markersize=2, ls='')
a[1,1].invert_yaxis()
a[1,1].set_aspect('equal', 'box')
    
#%% 4) Calculate footprints, extract traces
# calculate footprint by averaging df-AP images of the same cluster
footprint = np.zeros((sz[0],sz[1],nclust))
for i in range(nclust):
    footprint[:,:,i] = np.mean(df[:,:,spk[clust_idx==i+1,2]],axis=2)
#%%
fp,_ = ali_fp_support(footprint,clust_cen,10) # limit the support of footprint to a 10-pixel circular region around cluster center
#%%
_,traces = ali_t_decompose(df.reshape((-1,nframe)),fp.reshape((-1,nclust))) #extract time traces from the df movie using the provided footprints
traces[traces<0] = 0
#%%
f,a = plt.subplots()
for n in range(traces.shape[1]):
    a.plot(traces[:,idd[n]] + n*2)
