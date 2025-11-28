% This script demonstrate activity localization imaging (ALI)
% Last Modified 2025/01/08, Tsai-Wen Chen
%% 1) Load example data
load('ali_demo_data.mat');
nframe=size(data,3);
data=double(data);
%% 2) Detect and localize spikes, generate ALI map
fs=2000;
win=fs/1000*10; % 10 ms window
df=ali_hp_filter(data,win); % temporal highpss filtering by removing median-filtered baseline traces from each pixel

%  detect candidate spikes in the hp filterred data by thresholding
spk=ali_spk_coarse(-df);  % spk(k,:) contains a coarse coordinate [row, col, frame] of the kth spike

% denoising by svd
nsvd=25; % number of svd components, should be larger than the potential number of neurons 
df_AP=df(:,:,spk(:,3)); %the subset of frames that potentially contain spikes
df_AP_dnoised=ali_denoising(df_AP,nsvd);

% determines fine coordinates of each spike with sub-pixel precision
spk(:,1:2)=ali_spk_fine(-df_AP_dnoised,15,4,spk(:,1:2));

% generate ALI map
f0=mean(data,3);
sz=size(f0);
factor=4; % specify the resolution of the ALI map (4x higher than the original pixel resolution)
[cnt,cen]=ali_density_map(spk(:,1:2),sz,factor); %Count the number of APs in each spatial bin
h=fspecial('gaussian',[5,5],0.7);
alimap=filter2(h,cnt); % smooth the map a bit


%% 3) Automatically detect ALI clusters from the ALI map
th=3; % detect peaks in the ALI map that are brighter than the value 'th'
map_th=alimap;
map_th(alimap<th)=0;
BW=imregionalmax(map_th);
[I,J]=find(BW);
clust_cen=[cen{1}(I)',cen{2}(J)']; % nclust x 2 center locations of detected clusters
nclust=size(clust_cen,1);

r=1.5;
clust_idx=ali_assign_cluster(spk(:,1:2),clust_cen,r); % assign spikes to the nearest cluster within a distance of 1.5 pixels

h1=figure('position',[100,100,650,500]);colormap gray;
subplot(2,2,1);imagesc(f0);axis image;title('Mean image');axis off;
subplot(2,2,2);imagesc(f0);hold on;plot(spk(:,2),spk(:,1),'r.','markersize',1);axis image;title('Spike locations');axis off;
subplot(2,2,3);imagesc(cen{2},cen{1},alimap);set(gca,'clim',[0,8]);axis image;title('ALI map');axis off;
subplot(2,2,4);imagesc(ones(size(f0)));set(gca,'clim',[0,1]);
ali_plot_cluster(spk(:,1:2),clust_idx);% plot spikes belonging to different clusters using different colors
axis image;title('Detected clusters');axis off;
linkaxes(h1.Children,'xy');
%% 4) Calculate footprints, extract traces
% calculate footprint by averaging df-AP images of the same cluster
footprint=zeros(sz(1),sz(2),nclust);
for i=1:nclust
    footprint(:,:,i)=mean(df(:,:,spk((clust_idx==i),3)),3);
end

fp=ali_fp_support(footprint,clust_cen,10);% limit the support of footprint to a 10-pixel circular region around cluster center
[~,traces]=ali_t_decompose(reshape(df,[],nframe),reshape(fp,[],nclust)); %extract time traces from the df movie using the provided footprints
traces(traces<0)=0;

[colorfoot,rgb_cell]=fcn_paint_footprint(-fp); %paint the footprints of different cells using different colors
cf=max(colorfoot,[],4);

h1=figure('position',[750,100,650,500]);colormap gray;

subplot(2,2,1);
imagesc(f0);axis image;axis off;title('Mean image')

subplot(2,2,3);
imagesc(cf);axis image;axis off;title('Footprints')
for i=1:nclust
    text(clust_cen(i,2)+0.5,clust_cen(i,1)+0.5,num2str(i),'color','w');
end
subplot(2,2,[2,4]);
for i=1:nclust
    plot(traces(:,i)-i*1.5,'color',rgb_cell(i,:));hold on;
    text(-30000,-i*1.5+0.5,num2str(i));
end
title('Unmixed traces')
axis off;    
