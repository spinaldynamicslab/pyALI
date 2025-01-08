function hlines=ali_plot_cluster(sloc,clust_idx)
% ali_plot_cluster Plot spike locations, use different color for spikes
% beloning to different clusters
%
% input--
%   sloc: nspike x 2, (row,col) coordinates of each spike
%   clust_idx: nspike x 1, cluster index of each spike 
% output--
%   hlines:  handles of the line objects
%
% Created 01/26/2024 Tsai-Wen Chen 

hold on;
nclust=max(clust_idx);
hue=linspace(0,1,nclust+1);
hue=hue(1:nclust);

for i=1:nclust
    idx=(clust_idx==i);    
    hlines(i)=plot(sloc(idx,2),sloc(idx,1),'.','color',hsv2rgb(hue(i),1,1),'markersize',1);    
    c1=mean(sloc(idx,1));
    c2=mean(sloc(idx,2));
    text(c2+0.5,c1+0.5,num2str(i), 'Clipping', 'on');
end

%% plot spikes that do not belong to any cluster in 'black'
idx=(clust_idx==0);
rx=sloc(idx,2);
ry=sloc(idx,1);
dr=sqrt((rx-rx').^2+(ry-ry').^2);
nn=sum(dr<3,2)-1;
hlines(end+1)=plot(rx(nn>3),ry(nn>3),'.k','markersize',1);
% plot(rx,ry,'.k');
set(gca,'YDir','reverse');
