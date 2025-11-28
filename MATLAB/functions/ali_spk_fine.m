function [sloc,bns,roi]=ali_spk_fine(df,npix,radius,initloc)
% ali_spk_fine Localize AP with sub-pixel precision through weighted averagaing
%
% input--
%   df: nrow x ncol x nspike, stack of df_AP images, contain positively going spikes
%   npix: scalar, number of pixels around the peak for calculating the average
%   radius: scalar
%   initloc: nspike x 2, coarse coordinates [row,col] of action potentials, integer pixel values
% output--
%   sloc: nspike x 2 array
%         sloc(i,1) stores the row location of the i th spike;
%         sloc(i,2) stores the col location of the i th spike
%   bns: 1 x nspike, mean brigtness of the region included in the average
%   roi: nrow x ncol x nspike, BW images of the region included in the average
%   
% Created 01/26/2024 Tsai-Wen Chen

sloc=[];
bns=[];
roi=[];
for i=1:size(df,3)
    im=df(:,:,i);
    if ~exist('initloc')
        M=max(im(:));
        [I,J]=find(im==M);
    else
        I=initloc(i,1);
        J=initloc(i,2);
    end
    [pixel_list,roimap,indexIJ]=ali_select_connected(im,[I;J],npix,radius);
    val=im(pixel_list)';
    w=val.^2;
    loc=indexIJ*w./sum(w); % weigted avg
    bns=[bns,mean(val)];
    sloc=[sloc;loc'];
    roi=[cat(3,roi,roimap)];
end