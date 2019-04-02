#ifndef SHARED_H
#define SHARED_H

#define NONE_PRESSED 15
#define BUTTON_0     1
#define BUTTON_1     2
#define BUTTON_2     4
#define BUTTON_3     8

// profiling
#define PROFILE (0)

// only enable one at a time
#if PROFILE
// SD read
#define PROFILE_SD_READ     (0)
// lossless decode
#define PROFILE_DECODE_Y    (0)
#define PROFILE_DECODE_CB   (0)
#define PROFILE_DECODE_CR   (0)
// IDCT
#define PROFILE_IDCT_FRAME  (1)
// YCbCr to RGB
#define PROFILE_YCBCR_FRAME (0)
#define PROFILE_YCBCR_BLOCK (0)
#endif

#include <altera_msgdma.h>

#if PROFILE
#include <sys/alt_timestamp.h>
#endif

typedef struct prog_state
{
	// DISPLAY
	ece423_video_display *p_display;

	// FILE MANAGEMENT
	FAT_FILE_HANDLE file_handle;
	FAT_HANDLE fs_handle;
	FAT_BROWSE_HANDLE fs_browse_handle;

	// DMA
	alt_msgdma_dev *read_dma_y;
	alt_msgdma_dev *write_dma;

} prog_state_t;

typedef struct message
{
	uint8_t* Cbbitstream;
	uint8_t* Crbitstream;
	uint32_t frame_type;
	uint32_t block_size;
} message_t;

volatile prog_state_t state;
volatile alt_u8 	  is_pressed;

#endif  // SHARED_H
