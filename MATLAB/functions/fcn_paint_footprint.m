function [colorfoot,rgb_cell]=fcn_paint_footprint(footprint)
ss=size(footprint);
if length(ss)==2
    ss(3)=1;
end

colorfoot=zeros(ss(1),ss(2),3,ss(3));
hue=linspace(0,1,ss(3)+1);
hue=hue(1:ss(3));
rgb_cell=zeros(ss(3),3);
for i=1:ss(3)
    foot=footprint(:,:,i);
    
    foot=foot/max(foot(:));
    rgb=hsv2rgb([hue(i),1,1]);
    rgb_cell(i,:)=rgb;
    colorfoot(:,:,:,i)=reshape(foot(:)*rgb,[ss(1),ss(2),3]);    
end