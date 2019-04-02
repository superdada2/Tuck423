#include "decoder/mjpeg423_decoder.h"
#include "system.h"
#include <stdio.h>
#include <unistd.h>

static void setup()
{
	// initialize DMA
	state.read_dma_cb = alt_msgdma_open(READ_DMA_CB_CSR_NAME);
	state.read_dma_cr = alt_msgdma_open(READ_DMA_CR_CSR_NAME);

	if (state.read_dma_cb == NULL || state.read_dma_cr == NULL)
	{
		fprintf(stderr, "ERROR: Could not open DMA.\n");
	}
}

/*static void loop()
{
	// there's a memset to 0 of 256 bytes somewhere in Fat_FileOpen
	// so we need to pass in something of the same size
	char *p_filename;
	char filename[256] = {0};

	p_filename = get_next_mpeg_filename(&state);
	strcpy(filename, p_filename);

	printf("filename is: %s\n", filename);

	while (TRUE)
	{
	    while (is_pressed == NONE_PRESSED) {};

	    switch(is_pressed)
	    {
	    	// Play current file
	    	case BUTTON_0:
	    	{
				printf("Play\n");

	    		// Decode the video
				if((state.file_handle = Fat_FileOpen(state.fs_handle, filename)) == 0)
				{
					printf("cannot open file: %s\n", filename);
					exit(-1);
				}
				mjpeg423_decode(state.file_handle, state.p_display, state.read_dma, state.write_dma);
	    		Fat_FileClose(state.file_handle);
	    		printf("File End\n");

	    		break;
	    	}
	    	// Skip to next file
	    	case BUTTON_1:
	    	{
	    		p_filename = get_next_mpeg_filename(&state);
	    		strcpy(filename, p_filename);

	    	    printf("\nNext file: %s\n", filename);
	    		break;
	    	}
	    	default:
	    	{
	    		break;
	    	}
	    }

	    is_pressed = NONE_PRESSED;
	}

    return;
}*/


int main()
{
	printf("Hi, I'm CPU 1 :)\n");
	setup();
	// loop();

	mjpeg423_decode(state.read_dma_cb, state.read_dma_cr);

	return 0;
}
