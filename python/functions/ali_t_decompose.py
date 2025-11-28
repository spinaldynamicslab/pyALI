import numpy as np

def ali_t_decompose(df, fp):
    """
    ali_t_decompose Extract temporal traces from the df movie given footprints of individual cells

    input--
      df: npixel x nframe, df images
      fp: npixel x nclust, footprints of individual cells

    output--
      trace_ls: nframe x nclust, extracted trace using least-square regression
      trace_new: nframe x nclust, extracted trace with better SNR  
    """
    cc = fp.T @ fp
    cn = np.diag(cc)
    proj = fp.T @ df
    trace_ls = np.linalg.solve(cc, proj)

    ncomp = fp.shape[1]
    trace_new = trace_ls.copy()
    trace_nonneg = np.maximum(0, trace_new)
    for i in range(ncomp):
        trace_new[i, :] = trace_nonneg[i, :] + (proj[i, :] - cc[i, :] @ trace_nonneg) / cn[i]

    trace_new = trace_new - np.median(trace_new, axis=1, keepdims=True)
    trace_new = trace_new.T
    trace_ls = trace_ls.T

    return trace_ls, trace_new