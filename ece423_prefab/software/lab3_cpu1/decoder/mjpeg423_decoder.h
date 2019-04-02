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
#include "../shared.h"

void mjpeg423_decode(alt_msgdma_dev *read_dma_1, alt_msgdma_dev *read_dma_2);
void lossless_decode(int num_blocks, void* bitstream, dct_block_t* DCACq, dct_block_t quant, BOOL P);

#endif
