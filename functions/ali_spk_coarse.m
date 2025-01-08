function spk=ali_spk_coarse(df)
% ali_spk_coarse Detect candidate spikes and return coarse coordinates
% assume spikes are positive going in df images!!
%
% input--
%   df:   nrow x ncol x nframe, stack of df images, contain positively going spikes
% output--
%   spk:   nspike x 3 matrix, contains the [row, col, frame] coordinates of detected spikes 
%
% Created 01/26/2024 Tsai-Wen Chen 

% 1) spatial filtering: df_LP
sz=size(df);
h=fspecial('gaussian',5,1.8);
df_lp=zeros(sz);
for k=1:sz(3)
    df_lp(:,:,k)=filter2(h,df(:,:,k));
end

% 2) estimate SD, use mean absolute deviation, which is more rubust to outliers
sd=mad(df_lp,0,3)*1.25;

% 3) thresholding: 
BW=df_lp>5*sd;

% 4) find spatial-temporal connected 'segments' 
CC = bwconncomp(BW,26);

% 5) find peak pixel of each segment, and save its coordinate
list=CC.PixelIdxList;
nspk=length(list);
spk=zeros(nspk,3);
cnt=[];
for k=1:nspk    
    cnt(k)=length(list{k}); %number of connected-pixels above threshold of this segment
    [~,idx]=max(df_lp(list{k}));
    pix=list{k}(idx);
    [I,J,K]=ind2sub(sz,pix);
    spk(k,1)=I; %row
    spk(k,2)=J; %col
    spk(k,3)=K; %frame
end

% keep only those segment with more than 4 pixels
spk=spk(cnt>4,:);
