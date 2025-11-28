function [df_dnoised,ucomps,vcomps]=ali_denoising(df,nsvd)
% ali_denoising Reduce noise by PCA/SVD, keeping nsvd components
%
% input--
%   df:   nrow x ncol x nframe, stack of df images, contain positively going spikes
%   nsvd: number of svd components to keep
% output--
%   df_dnosied:   nrow x ncol x nframe, de-noised df images
%   ucomps: nrow x ncol x nsvd kept spatial components
%   vcomps: nframe x nsvd kept temporal components
%
% Created 01/26/2024 Tsai-Wen Chen
sz=size(df);
df=reshape(df,[],sz(3));
[uu,s,vv]=fcn_mysvd(df,nsvd);
rec=uu*s*vv';

df_dnoised=reshape(rec,sz);
ucomps=reshape(uu,[sz(1:2),nsvd]);
vcomps=reshape(vv,[sz(3),nsvd]);