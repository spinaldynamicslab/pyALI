function [U,S,V]=fcn_mysvd(data,ncomp)
% fcn_mysvd A simple routine for computing sigular value decomposition (SVD) with 'ncomp'
% singular values
%
% This function implements the approach described in Mukamel et. al. 2009 Neuron
% paper: "Automated analysis of cellular signals from large-scale calcium imaging data"
%

sz=size(data);

if sz(2)<sz(1)   
    cc=data'*data;
    [V,D]=eigs(double(cc),ncomp);      
    S=sqrt(D);
    U=data*V*inv(S);   
else
    cc=data*data';
    [U,D]=eigs(double(cc),ncomp);
    S=sqrt(D);
    V=(inv(S)*U'*data)';    
end
    