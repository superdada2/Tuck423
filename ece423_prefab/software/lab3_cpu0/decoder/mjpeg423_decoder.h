//
//  mjpeg423_decoder.h
//  mjpeg423app
//
//  Created by Rodolfo Pellizzoni on 12/24/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#ifndef mjpeg423app_mjpeg423_decoder_h
#define mjpeg423app_mjpeg423_decoder_h

// null color conversion
#define NULL_COLORCONV

#include "../common/mjpeg423_types.h"
#include "../ece423_vid_ctl/ece423_vid_ctl.h"
#include "../ece423_sd/ece423_sd.h"
#include "../shared.h"

void mjpeg423_decode(FAT_FILE_HANDLE file_handle, ece423_video_display* p_display, alt_msgdma_dev *read_dma, alt_msgdma_dev *write_dma);
void ycbcr_to_rgb(int h, int w, uint32_t w_size, pcolor_block_t Y, pcolor_block_t Cb, pcolor_block_t Cr, rgb_pixel_t* rgbblock);
void idct(dct_block_t DCAC, color_block_t block);
void lossless_decode(int num_blocks, void* bitstream, dct_block_t* DCACq, dct_block_t quant, BOOL P);

#endif
