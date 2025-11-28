function df=ali_hp_filter(stack,win)
% ali_hp_filter Remove median-filtered baseline traces from each pixel
%
% input--
%   stack:   nrow x ncol x nframe, stack of images
%   win:     scalar, length of median filtering window in sample
% output--
%   df:     nrow x ncol x nframe, baseline removed 'df' images
%
% Created 01/26/2024 Tsai-Wen Chen 

sz=size(stack);
stack=reshape(stack,[],sz(3));
npixel=size(stack,1);  
for i=1:npixel
    baseline=medfilt1(stack(i,:),win,'truncate'); % median filter
    stack(i,:)=stack(i,:)-baseline;
end
df=reshape(stack,sz);
end