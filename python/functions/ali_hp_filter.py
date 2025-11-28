from scipy.ndimage import median_filter

def ali_hp_filter(stack, win: int):
    """
    ali_hp_filter Remove median-filtered baseline traces from each pixel

    input--
      stack:   nrow x ncol x nframe, stack of images (numpy array)
      win:     scalar, length of median filtering window in samples
    output--
      df:     nrow x ncol x nframe, baseline removed 'df' images
    """
    # sz = stack.shape
    # stack_reshaped = stack.reshape(-1, sz[2])
    # npixel = stack_reshaped.shape[0]
    # if (win % 2) != 1:
    #     win +=1
    # for i in range(npixel):
    #     baseline = median_filter(stack_reshaped[i, :], kernel_size=win)
    #     stack_reshaped[i, :] = stack_reshaped[i, :] - baseline

    # df = stack_reshaped.reshape(sz)
    df = stack - median_filter(stack, size=(1,1,win))
    return df