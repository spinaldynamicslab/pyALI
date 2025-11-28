function [cnt,cen]=ali_density_map(sloc,sz,factor)
% ali_density_map Generate spike density map (or ALI map) using 2D histogram
%
% input--
%   sloc: nspike x 2 array, row and col coordinate of spikes
%   sz:   [row, col] size of the raw image
%   factor: ALI map contains factor times more pixel in both row,col dimensions
% output--
%   cnt: (row*factor) x (col*factor) array of spike count in each bin
%   cen: 1 x 2 cell array, center locations of each bin
%
% Created 01/26/2024 Tsai-Wen Chen

bin_edges1=linspace(0.5,sz(1)+0.5,sz(1)*factor+1);
bin_edges2=linspace(0.5,sz(2)+0.5,sz(2)*factor+1);

[cnt,cen]=hist3([sloc(:,1),sloc(:,2)],'edges',{bin_edges1,bin_edges2});

cnt=cnt(1:end-1,1:end-1);
cen{1}=cen{1}(1:end-1);
cen{2}=cen{2}(1:end-1);
