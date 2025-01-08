function clust_idx=ali_assign_cluster(sloc,clust_cen,radius)
% ali_assign_cluster Assign spikes to the nearest cluster
%
% if a spike is more than 'radius' pixels away from all the clusters, then it is not
% assigned to any cluster, ie., clust_idx=0
%
% input--
%   sloc: nspike x 2, array of spike locations
%   clust_cen: nclust x 2, center coordinates of ALI clusters
%
% output--
%   clust_idx: nspike x 1, cluster index of each spike, values could range from 0 to nclust 
%                          0 means that the spike is NOT assigned to any cluster         
%
% Created 01/26/2024 Tsai-Wen Chen


% assign spikes to the nearest cluster, within distance specified in 'radius'
nspike=size(sloc,1);
clust_idx=zeros(nspike,1);

for i=1:nspike    
    dist=sqrt((sloc(i,1)-clust_cen(:,1)).^2+(sloc(i,2)-clust_cen(:,2)).^2);
    [m,idx]=min(dist);
    if m<radius %assign to nearest cluster        
        clust_idx(i)=idx;
    end
end
