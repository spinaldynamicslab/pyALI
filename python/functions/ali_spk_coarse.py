import numpy as np
from scipy.ndimage import gaussian_filter
from skimage.measure import label

def ali_spk_coarse(df):
    """
    ali_spk_coarse Detect candidate spikes and return coarse coordinates
    assume spikes are positive going in df images!!

    input--
      df:   nrow x ncol x nframe, stack of df images, contain positively going spikes
    output--
      spk:   nspike x 3 matrix, contains the [row, col, frame] coordinates of detected spikes 
    """

    # 1) spatial filtering: df_LP
    sz = df.shape
    df_lp = np.zeros(sz)
    for k in range(sz[2]):
        df_lp[:, :, k] = gaussian_filter(df[:, :, k], sigma=1.8, radius=2) # kernel size is 2*radius + 1 = 5

    # 2) estimate SD, use mean absolute deviation, which is more robust to outliers
    sd = np.std(df_lp, axis=2)

    # 3) thresholding:
    # Need to broadcast sd to 3D shape for comparison
    BW = df_lp > (5 * sd[:, :, np.newaxis])

    # 4) find spatial-temporal connected 'segments'
    labeled, num_features = label(BW, connectivity=3, return_num=True)

    # 5) find peak pixel of each segment, and save its coordinate
    spk_list = []  
    
    for seg_id in range(1, num_features + 1):
        segment_indices = np.where(labeled == seg_id)
        cnt = len(segment_indices[0])
        if cnt > 4:
            # Extract values of df_lp at segment pixels
            values = df_lp[segment_indices]
            max_idx = np.argmax(values)
            # Get coordinates of max pixel
            spk_list.append([segment_indices[0][max_idx], segment_indices[1][max_idx], segment_indices[2][max_idx]])

    spk = np.array(spk_list)
    return spk