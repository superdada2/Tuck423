#include "decoder/mjpeg423_decoder.h"
#include "altera_avalon_pio_regs.h"
#include "sys/alt_irq.h"
#include "system.h"
#include <stdio.h>
#include <unistd.h>

//resolution: width
#define WIDTH (640)
//resolution: height
#define HEIGHT (480)
// extension of MJPEG files
#define MPEG_EXTENSION (".MPG")
// period of each frame in seconds
#define FRAME_RATE (10)

static void timer_ISR(void *context, alt_u32 id)
{
    // acknowledge the interrupt by clearing the TO bit in the status register
    IOWR(TIMER_1_BASE, 0, 0x0);
    // switch frames
	if (ece423_video_display_switch_frames(state.p_display) != 0)
	{
		 // printf("switch fail\n");
	}
}

static void button_ISR(void *context, alt_u32 id)
{
	// disable interrupts
	IOWR(KEY_BASE, 2, 0x0);

    // get value from the edge capture register and mask off all bits except the 4 least significant
    is_pressed = IORD(KEY_BASE, 3) & 0xf;

    // reset the edge capture register to clear the interrupt
    IOWR(KEY_BASE, 3, 0x0);

    // ghetto debouncing
    usleep(1000);  // sleep for 1 ms

    // re-enable interrupts
    IOWR(KEY_BASE, 2, 0xf);
}

static void begin_file_browsing()
{
	if (Fat_FileBrowseBegin(state.fs_handle, &state.fs_browse_handle) == FALSE)
	{
		error_and_exit("could not browse file system");
	}
}

static char *get_next_mpeg_filename()
{
	FILE_CONTEXT f_context;

	do
	{
		if (Fat_FileBrowseNext(&state.fs_browse_handle, &f_context) == FALSE)
		{
			begin_file_browsing(&state);
			Fat_FileBrowseNext(&state.fs_browse_handle, &f_context);  // or else last file is selected twice
		}
	} while (Fat_CheckExtension(&f_context, MPEG_EXTENSION) != TRUE);

	return Fat_GetFileName(&f_context);
}

static void setup()
{
	alt_u32 timerPeriod = TIMER_1_FREQ / FRAME_RATE;
	is_pressed = NONE_PRESSED;

	// display initialization
	state.p_display = ece423_video_display_init(VIDEO_DMA_CSR_NAME, WIDTH, HEIGHT, 36);

    // enable button interrupts
	alt_irq_register(KEY_IRQ, (void*)0, button_ISR);  // setup the interrupt vector
	IOWR(KEY_BASE, 3, 0x0);  // reset the edge capture register by writing to it (any value will do)
	IOWR(KEY_BASE, 2, 0xf);  // enable interrupts for all four buttons

	// enable timer interrupt
	IOWR(TIMER_1_BASE, 2, (alt_u16)timerPeriod);
	IOWR(TIMER_1_BASE, 3, (alt_u16)(timerPeriod >> 16));

	alt_irq_register(TIMER_1_IRQ, (void *)0, timer_ISR);
	IOWR(TIMER_1_BASE, 0, 0x0);
	IOWR(TIMER_1_BASE, 1, 0x7);  // initialize timer control - start timer, run continuously, enable interrupts

	// initialize DMA
	state.read_dma_y = alt_msgdma_open(READ_DMA_Y_CSR_NAME);
	state.write_dma = alt_msgdma_open(WRITE_DMA_CSR_NAME);

	if (state.read_dma_y == NULL || state.write_dma == NULL)
	{
		fprintf(stderr, "ERROR: Could not open DMA.\n");
	}

	// filesystem initialization
	state.fs_handle = Fat_Mount();
	begin_file_browsing(&state);
}

static void loop()
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
				mjpeg423_decode(state.file_handle, state.p_display, state.read_dma_y, state.write_dma);
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
}


int main()
{
	printf("Hi, I'm CPU 0 :)\n");
	setup();
	loop();

	return 0;
}
