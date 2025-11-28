function [pixel_list,roimap,indexIJ]=ali_select_connected(im,startpix,N,radius)
% ali_select_connected: Return a list of N brightest pixels in the input
% image that are connected to and within 'radius' pixels away from the starting
% pixel 'startpix'
%
% input--
%   im: [nrow x ncol] input image 
%   startpix: 2x1 array containing the row and column coordinates of the starting pixel
%   N: scalar specify the number of pixels to be detected
%   radius: maximal distance from the starting pixel, for a pixel to be detected
%
% output--
%   pixel_list: 1x N array containing linear indices of N detected pixels
%   roimap: [nrow x ncol] binary image of detected pixel location
%   indexIJ: 2 x N array containing row and col indices of the N detected pixels 
%
% Created 01/26/2024 Tsai-Wen Chen 
%
ss=size(im);
queue=startpix;
queueval=im(queue(1),queue(2));
roimap=false(ss);
queuemap=zeros(ss);
queuemap(queue(1),queue(2))=1;
indexIJ=[];
nsel=0;

while nsel<N
    % add brightest (i.e. first) pixel in queue to roi
    pix=queue(:,1);
    roimap(pix(1),pix(2))=1;
    indexIJ=[indexIJ,pix];
    queue(:,1)=[];
    queueval(1)=[];
    nsel=nsel+1;
    % add pixels connected to the added pixel to queue
    candidate=[pix(1);pix(2)]+[[1 0]',[-1 0]', [0 1]',[0 -1]'];
    d=sqrt(sum([candidate-startpix].^2));
    idx=(candidate(1,:)>0)&(candidate(1,:)<=ss(1))&(candidate(2,:)>0)&(candidate(2,:)<=ss(2))&(d<=radius);
    candidate=candidate(:,idx);
    for i=1:size(candidate,2)
        pix=candidate(:,i);
        if queuemap(pix(1),pix(2))==0
            queue=[queue,pix];
            queueval=[queueval,im(pix(1),pix(2))];
            queuemap(pix(1),pix(2))=1;
        end
    end
    % sort all pixels in queue
    [v,idx]=sort(queueval,'descend');
    queue=queue(:,idx);
    queueval=queueval(idx);
end
pixel_list=sub2ind(ss,indexIJ(1,:),indexIJ(2,:));
end
