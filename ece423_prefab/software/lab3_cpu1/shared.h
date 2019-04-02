#ifndef SHARED_H
#define SHARED_H

#include <altera_msgdma.h>

typedef struct prog_state
{
	// DMA
	alt_msgdma_dev *read_dma_cb;
	alt_msgdma_dev *read_dma_cr;
} prog_state_t;

typedef struct message
{
	uint8_t* Cbbitstream;
	uint8_t* Crbitstream;
	uint32_t frame_type;
	uint32_t block_size;
} message_t;

volatile prog_state_t state;

#endif  // SHARED_H
