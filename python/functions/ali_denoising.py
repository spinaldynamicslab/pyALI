"""
ali_denoising Reduce noise by PCA/SVD, keeping nsvd components

input--
  df:   nrow x ncol x nframe, stack of df images, contain positively going spikes
  nsvd: number of svd components to keep
output--
  df_dnoised:   nrow x ncol x nframe, de-noised df images
  ucomps: nrow x ncol x nsvd kept spatial components
  vcomps: nframe x nsvd kept temporal components
"""
# import numpy as np
# from fcn_mysvd import fcn_mysvd
from sklearn.decomposition import TruncatedSVD

def ali_denoising(df, nsvd):
    sz = df.shape
    # df_reshaped = df.reshape(-1, sz[2])
    df_reshaped = df.reshape(sz[0], -1) # we are now working with time being dim 0
    svd = TruncatedSVD(n_components=nsvd)
    if sz[0]<sz[1]:   
        transform = svd.fit_transform(df_reshaped)
        rec = svd.inverse_transform(transform)
        # cc=np.matmul(data.T,data)
        # D,V=eigs(cc,ncomp)
        # S=np.sqrt(np.diag(D))
        # U=data@V@np.linalg.inv(S)
    else:
        transform = svd.fit_transform(df_reshaped.T)
        rec = svd.inverse_transform(transform).T
        # cc=np.matmul(data,data.T)
        # D,U=eigs(cc,ncomp)
        # S=np.sqrt(np.diag(D))
        # V=(np.linalg.inv(S)@U.T@data).T  
    
    
    # uu, s, vv = fcn_mysvd(df_reshaped, nsvd)
    # rec = uu @ s @ vv.T
    
    df_dnoised = rec.reshape(sz)
    # ucomps = uu.reshape(sz[0], sz[1], nsvd)
    # vcomps = vv.reshape(sz[2], nsvd)
    
    return df_dnoised #, ucomps, vcomps