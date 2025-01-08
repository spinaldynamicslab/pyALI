function [footprint,support]=ali_fp_support(footprint,clust_cen,r)
% ali_fp_support Set the footprint values to zeros beyond a 'r'-pixel circular
%                region around the center
% input--
%   footprint: nrow x ncol x nclust, footprints of ALI clusters
%   clust_cen: nclust x 2 center coordinates of ALI clusters 
%   r: radius of footprint support
% output--
%   footprint: nrow x ncol x nclust, footprints with limited spatial support 
%   support: nrow x ncol x nclust, non-zero pixels of the footprint
%
% Created 01/26/2024 Tsai-Wen Chen

ss=size(footprint);

for k=1:ss(3)
    for i=1:ss(1)
        for j=1:ss(2)
            d=sqrt((i-clust_cen(k,1)).^2+(j-clust_cen(k,2)).^2);
            if d>r
                footprint(i,j,k)=0;
            end
        end
    end
end
support=(footprint~=0);