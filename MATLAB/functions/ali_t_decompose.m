function [trace_ls,trace_new]=ali_t_decompose(df,fp)
% ali_t_decompose Extract temporal traces from the df movie given footprints of individual cells
%
% input--
%   df: npixel x nframe, df images
%   fp: npixel x nclust, footprints of individual cells
%
% output--
%   trace_ls: nframe x nclust, extracted trace using least-square regression
%   trace_new: nframe x nclust, extracted trace with better SNR  
%
% Created 01/26/2024 Tsai-Wen Chen 

cc=fp'*fp;      
cn=diag(cc);
proj=fp'*df;
trace_ls=cc\proj; 

ncomp=size(fp,2);
trace_new=trace_ls;
trace_nonneg=max(0,trace_new);
for i=1:ncomp
    trace_new(i,:)=trace_nonneg(i,:)+(proj(i,:)-cc(i,:)*trace_nonneg)/cn(i);
    
end
trace_new=trace_new-median(trace_new,2);
trace_new=trace_new';
trace_ls=trace_ls';
