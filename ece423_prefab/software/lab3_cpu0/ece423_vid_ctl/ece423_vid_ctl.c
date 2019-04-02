/*
 ****************************
 * ECE423 Video Controller *
 ****************************
 */

/*
 **********************************************************************************
 * This is a rewrite of alt_video_display.c for use with         *
 * a MODULAR SGDMA Controller ie. mSGDMA                                          *
 **********************************************************************************
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <io.h>
#include <sys/alt_cache.h>
#include <malloc.h>
#include <priv/alt_file.h>
#include "system.h"
#include "i2c.h"

#include "heatshrink/heatshrink.h"
#include "ece423_vid_ctl.h" // New mSGDMA Video Controller

extern uint* logo;
extern logo_width;
extern logo_height;
extern const unsigned int logo_len;
extern const unsigned int logo_len_out;
extern const unsigned char logo_compressed[];

extern const unsigned char font_compressed[];
extern const unsigned int font_len;
extern const unsigned int font_len_out;
extern const int font_height;
extern const char*  font_glyph_bitmap;
typedef struct
{
    int w_px;
    int glyph_index;
} lv_font_glyph_dsc_t;
extern const lv_font_glyph_dsc_t font_glyph_dsc[];

/******************************************************************
 *                    ece423_video_display_init
 *                    ----------------------
 *
 *  This Inits the display controller. Gets memory for the
 *           Frame Bufs & descriptors , Inits the
 *           descriptors, sets size of the Frame Bufs,
 *           Inits all Frame Bufs to Black & Sets Up & STARTS
 *           the mSGDMA.
 *
 *  Returns: Ptr to  display controller structure, or NULL on failure.
 ******************************************************************/
ece423_video_display* ece423_video_display_init(char* sgdma_name, int width,
		int height, int num_buffers) {

	/* ------------------------------- decompress ------------------------------- */

	font_glyph_bitmap = malloc(font_len_out);
    if(font_glyph_bitmap == NULL)
        printf("Can not allocate buffer");
    decompress(font_compressed, font_len, font_glyph_bitmap, font_len_out);

    logo = (uint*)malloc(logo_len_out);
    if(logo == NULL)
        printf("Can not allocate buffer");
    decompress(logo_compressed, logo_len, logo, logo_len_out);

	/* ----------------------------- init HDMI chip ----------------------------- */
	if (ece423_init_hdmi()) {
		printf("Failed to initiate the HDMI chip!\n");
		return 0;
	}

	/* ------------------------------ init display ------------------------------ */

	ece423_video_display* display;
	unsigned int bytes_per_pixel, bytes_per_frame, descriptors_per_frame, i;

	alt_msgdma_dev* pVid_DMA_CSR_Dev; // Ptr to mSGDMA Cont & Status Device

	// PreCalc Values
	bytes_per_pixel = 4;
	bytes_per_frame = ((width * height) * bytes_per_pixel);

	descriptors_per_frame = 1;

	// DON'T EXCEED MAX Frame Bufs
	if (num_buffers > ECE423_VIDEO_DISPLAY_MAX_BUFFERS) {
		printf("The required number of buffers exceeds the max!\n");
		num_buffers = ECE423_VIDEO_DISPLAY_MAX_BUFFERS;
	} else if (num_buffers < 2) {
		printf("The number of buffers must be > 2!\n");
		num_buffers = 2;
	}
	num_buffers = num_buffers + 1;

	// malloc display struct
	display = (ece423_video_display*) malloc(sizeof(ece423_video_display));
	if (!display) {
		return NULL;
	}

	// Init display struct
	display->width = width;
	display->height = height;
	display->num_frame_buffers = num_buffers;
	display->bytes_per_frame = bytes_per_frame;
	display->bytes_per_pixel = bytes_per_pixel;
	display->buffer_being_displayed = 0;
	display->buffer_being_written = 1; // Init iPrev_Wr_Buf MUST MATCH
	// See iPrev_Wr_Buf in ece423_video_display_buffer_is_available
	display->descriptors_per_frame = descriptors_per_frame;
	display->video_name = "";

	// malloc Frame and descriptor Bufs & SetUp Frame Buf Ptrs & Descriptor Ptrs
	if (ece423_video_display_allocate_buffers(display, bytes_per_frame,
			num_buffers)) {
		return NULL;
	}

	pVid_DMA_CSR_Dev = alt_msgdma_open(sgdma_name); // Pt to Cont & Status Dev
	display->mSGDMA = pVid_DMA_CSR_Dev;
	if (pVid_DMA_CSR_Dev == NULL) {
		printf("ERROR ********* UNABLE to OPEN /dev/msgdma_csr\r\n");
		return NULL;
	}
	alt_u32 DMA_Status = IORD_ALTERA_MSGDMA_CSR_STATUS(
			display->mSGDMA->csr_base);
	if (DMA_Status != 0x22) {
		printf("\n\t\tVideo DMA Error\n");
		printf("\t\tReset the CPU or re-program the hardware!\n");
		printf("\t\tExiting ....\n\n");
		exit(-1);
	}

// Construct mSGDMA descriptors for each Frame Buf
	for (i = 0; i < num_buffers; i++) {
		alt_msgdma_construct_standard_mm_to_st_descriptor(pVid_DMA_CSR_Dev,
				display->buffer_ptrs[i]->desc_base,
				(alt_u32 *) display->buffer_ptrs[i]->buffer, bytes_per_frame,
				DESC_CONTROL);
	}

	alt_msgdma_construct_standard_mm_to_st_descriptor(pVid_DMA_CSR_Dev,
			display->text_buffer_ptr->desc_base,
			(alt_u32 *) display->text_buffer_ptr->buffer, bytes_per_frame,
			DESC_CONTROL);
	// Clear First Frame to WHITE
	ece423_video_display_clear_screen(display);
	// draw UW logo
	ece423_video_display_draw_logo(display);
	ece423_video_display_register_written_buffer(display);
	ece423_video_display_switch_frames(display);

	return (display);
}

/******************************************************************
 *              ece423_video_display_buffer_is_available
 *              -------------------------------------
 *
 * This Checks If Frame Buf is free to write to
 *             NOTE:buffer_being_written ALREADY points to it.
 *
 *  Returns:  0 - Free Buf available
 *                If Free Buf & NEW Frame HAS been Reg
 *                THEN
 *                buffer_being_displayed is UpDated
 *
 *           -1 - Free Buf not yet available
 *
 ******************************************************************/

int ece423_video_display_buffer_is_available(ece423_video_display* display) {


	if (display->num_frame_buffers > 1) {
		int iNext_Rd_Buf = ((display->buffer_being_displayed - 1 + display->num_frame_buffers)
			% display->num_frame_buffers);
		if (iNext_Rd_Buf == display->buffer_being_written) // If Frame Buf free to write to
			return -1; // Free Buf not yet available

	} // END if(display->num_frame_buffers > 1)
	// Else Only one display Buf so HAVE TO Overwrite LIVE Buf
	return 0;
}

/******************************************************************
 *              ece423_video_display_get_buffer
 *              -------------------------------------
 *
 *  Returns a pointer to the next buffer
 *
 *  Returns:  0 - Frames switched
 *
 *           -1 - No new frame available, so no switch
 *
 ******************************************************************/
alt_u32* ece423_video_display_get_buffer(ece423_video_display* display) {

	return (display->buffer_ptrs[display->buffer_being_written]->buffer);
}

/******************************************************************
 *                 ece423_video_display_register_written_buffer
 *                 -----------------------------------------
 *
 *  This Registers Buf pointed to by buffer_being_written
 *
 ******************************************************************/
void ece423_video_display_register_written_buffer(ece423_video_display* display) {

	/*
	 * Update buffer_being_written
	 * Note: The new buffer_being_written may NOT Yet be FREE
	 * So Call
	 * ece423_video_display_buffer_is_available
	 * to Check Before Drawing in it
	 */
	if(display->video_name)
		ece423_video_display_add_text(display, display->video_name, 10, 10, RGB_BLACK, 1);
	display->buffer_being_written = (display->buffer_being_written + 1)
			% display->num_frame_buffers;


}

/******************************************************************
 *              ece423_video_display_switch_frames
 *              -------------------------------------
 *
 * This switches the displayed frame to the next ready frame
 *
 *  Returns:  0 - Frames switched
 *
 *           -1 - No new frame available, so no switch
 *
 ******************************************************************/

int ece423_video_display_switch_frames(ece423_video_display* display) {
	int iNext_Rd_Buf;

	alt_u32 RD_Desc_Fifo_Level;

	iNext_Rd_Buf = ((display->buffer_being_displayed + 1)
			% display->num_frame_buffers);

	// Check if there is a new buffer to display
	if ((iNext_Rd_Buf != display->buffer_being_written)) {

		// Transfer Descriptor for Frame to mSGDMA
		while (alt_msgdma_standard_descriptor_async_transfer(display->mSGDMA,
				display->buffer_ptrs[iNext_Rd_Buf]->desc_base) != 0) {
		}  // Keep Trying until there is room to Transfer another Frame

		// Wait if there is another frame waiting in the list
		do {
			RD_Desc_Fifo_Level = (IORD_ALTERA_MSGDMA_CSR_DESCRIPTOR_FILL_LEVEL(
					display->mSGDMA->csr_base)
					& ALTERA_MSGDMA_CSR_READ_FILL_LEVEL_MASK)
					>> ALTERA_MSGDMA_CSR_READ_FILL_LEVEL_OFFSET;
		} while (RD_Desc_Fifo_Level > 1);

		display->buffer_being_displayed = iNext_Rd_Buf;
//		 	printf("Displayed %d - Written %d\n", display->buffer_being_displayed, display->buffer_being_written);
		return 0;
	} else {
		return -1;
	}

}

/******************************************************************
 *  Function: ece423_video_display_discard_buffered_frames
 *
 *  Purpose: Clear buffered frames
 *
 ******************************************************************/
void ece423_video_display_discard_buffered_frames(ece423_video_display* display) {

	// Reset the buffer to be written to the next buffer after the one being displayed
	display->buffer_being_written = ((display->buffer_being_displayed + 1)
		% display->num_frame_buffers);
}

/******************************************************************
 *              ece423_video_display_is_empty
 *              -------------------------------------
 *
 * This switches the displayed frame to the next ready frame
 *
 *  Returns:  0 - Frames switched
 *
 *           -1 - No new frame available, so no switch
 *
 ******************************************************************/

int ece423_video_display_is_empty(ece423_video_display* display) {
	int Next_Buf = ((display->buffer_being_displayed + 1)
					% display->num_frame_buffers);
	return (Next_Buf == display->buffer_being_written);
}

/******************************************************************
 *  Function: ece423_video_display_demo
 *
 *  Purpose: Display a simple animation to test the functionality
 *
 ******************************************************************/
void ece423_video_display_demo(ece423_video_display* display) {

	int i_scale = (display->height + 255) / 255;
	int j_scale = (display->width + 255) / 255;

	unsigned char y = 0;
	for (int f = 0; f < 255; f = f + 3) {

		while (ece423_video_display_buffer_is_available(display) != 0) {
		};

		int* frame = ece423_video_display_get_buffer(display);

		unsigned char cr = 0;

		for(int i = 0; i < display->height; i = i + i_scale) {
			unsigned char cb = 0;
			for(int j = 0; j < display->width; j = j + j_scale) {
				for(int ip = 0; ip < i_scale; ip++)
					for(int jp = 0; jp < j_scale; jp++){
						unsigned char y_f =y, cr_f = cr, cb_f = cb;
						int m = 10;

						int f_y = m*f < 255? m*f : m*(254 - f) < 255 ? m*(254 - f) : -1;
						if (f_y >= 0) {
							y_f = 0xFF - y < 0xFF-f_y? 0xFF - y : 0xFF-f_y;
							y_f = y + y_f;
						}

						int f_c = m*f < 128? m*f : m*(254 - f) < 128 ? m*(254 - f) : -1;
						if (f_c >= 0) {
							if (cb >= 128) {
								cb_f = cb - 128 < 128 - f_c? cb - 128 : 128 - f_c;
								cb_f = cb - cb_f;
							} else {
								cb_f = 128 - cb < 128 - f_c? 128 - cb : 128 - f_c;
								cb_f = cb + cb_f;
							}
							if (cr >= 128) {
								cr_f = cr - 128 < 128 - f_c? cr - 128 : 128 - f_c;
								cr_f = cr - cr_f;
							} else {
								cr_f = 128 - cr < 128 - f_c? 128 - cr : 128 - f_c;
								cr_f = cr + cr_f;
							}
						}

						frame[ (i + ip) * display->width + (j + jp) ] = (cr_f << 16) | (y_f << 8) | (cb_f);
						y = y - (i*10 & 0xFF) - (j*6 & 0x00FF);
					}
				cb = cb + 1;

			}
			cr = 255 - f;
		}

		ece423_video_display_draw_logo(display);
		ece423_video_display_register_written_buffer(display);
		ece423_video_display_switch_frames(display);
	}

}

/******************************************************************
 *  Function: ece423_video_display_clear_screen
 *
 *  Purpose: Clear entire Frame Buf
 *
 ******************************************************************/
void ece423_video_display_clear_screen(ece423_video_display* display) {
	ece423_video_display_color_screen(display, RGB_WHITE);
}

/******************************************************************
 *  Function: ece423_video_display_color_screen
 *
 *  Purpose: Clear entire Frame Buf
 *
 ******************************************************************/
void ece423_video_display_color_screen(ece423_video_display* display,
		uint rgb_color) {
	uint color = rgb2ycbcr(rgb_color);
	int* frame = display->buffer_ptrs[display->buffer_being_written]->buffer;
	for (int i = 0; i < display->bytes_per_frame / 4; i += 1)
		frame[i] = color;
}

/******************************************************************
 *  Function: ece423_video_display_colored_screen
 *
 *  Purpose: Draw a colored screen
 *
 ******************************************************************/
void ece423_video_display_colored_screen(ece423_video_display* display) {

	int* frame = display->buffer_ptrs[display->buffer_being_displayed]->buffer;

	int i_scale = (display->height + 255) / 255;
	int j_scale = (display->width + 255) / 255;

	unsigned char y = 104;
	unsigned char cr = 0;

	for(int i = 0; i < display->height; i = i + i_scale) {
		unsigned char cb = 0;
		for(int j = 0; j < display->width; j = j + j_scale) {
			for(int ip = 0; ip < i_scale; ip++)
				for(int jp = 0; jp < j_scale; jp++){
					frame[ (i + ip) * display->width + (j + jp)] = (cr << 16) | (y << 8) | (cb);
					y = y - (i & 0xFF) - (j & 0x00FF);
				}
			cb = cb + 1;
		}
		cr = cr + 1;
	}
}

/******************************************************************
 *                 ece423_video_display_add_frame_number
 *                 -----------------------------------------
 *
 *  This add a frame number pointed to by buffer_being_written
 *
 ******************************************************************/
void ece423_video_display_add_frame_number(ece423_video_display* display, int frame_num, int total_frames) {

	int num_str_len = 5;
	char text[2*num_str_len+4];
	char num[num_str_len];
	int num_len;

	itoa(frame_num, num, 10);
	num_len = strlen(num);
	for(int i = 0, j = 0; i < num_str_len; i++)
		text[i] = (i < num_str_len-num_len)? ' ' : num[j++];

	text[num_str_len] = ' ';
	text[num_str_len+1] = '/';
	text[num_str_len+2] = ' ';

	itoa(total_frames, num, 10);
	num_len = strlen(num);

	for(int i = 0, j = 0; i < 7; i++)
		text[i+num_str_len+3] = (i >= num_len)? ' ' : num[j++];

	text[2*num_str_len+3] = '\0';
	// ece423_video_display_add_text(display, text, display->width - 10*(2*num_str_len + 7), 20, RGB_BLACK);
	ece423_video_display_add_text(display, text, 10, 32, RGB_BLACK, 1);
}

/******************************************************************
 *  Function: ece423_video_display_set_video_name
 *
 *  Purpose: Set the video name to display on the frames
 *
 ******************************************************************/
void ece423_video_display_set_video_name(ece423_video_display* display, char* name) {

	display->video_name = name;
}
/******************************************************************
 *  Function: ece423_video_display_draw_logo
 *
 *  Purpose: Draw Logo in the middle of the screen
 *
 ******************************************************************/
void ece423_video_display_draw_logo(ece423_video_display* display) {

	int* frame = display->buffer_ptrs[display->buffer_being_written]->buffer;

	int k1 = (display->height / 2 - logo_height/2) * display->width
			+ (display->width / 2 - logo_width/2);
	int k2 = 0;
	for (int i = 0; i < logo_height; i++) {
		for (int j = 0; j < logo_width; j++) {
			// TODO: this is just a hack to remove balck dots on the sides of the logo, the image quality should be better
			int cond1 = (j > 0) && (j < logo_width - 1) && (logo[k2] != 0) && (logo[k2-1] == 0) && (logo[k2+1] != logo[k2]);
			int cond2 = (j > 0) && (j < logo_width - 1) && (logo[k2] != 0) && (logo[k2+1] == 0) && (logo[k2-1] != logo[k2]);
			if(logo[k2] == 0 || cond1 || cond2) {
				k1++; k2++;
				continue;
			}

			frame[k1++] = logo[k2++];
		}
		k1 += display->width - logo_width;
	}

}

/******************************************************************
 *  Function: ece423_video_display_add_text
 *
 *  Purpose: Add a string to the screen
 *
 ******************************************************************/
void ece423_video_display_add_text(ece423_video_display* display, char* text, int x, int y, uint rgb_color, int scale) {

	int* frame = display->buffer_ptrs[display->buffer_being_written]->buffer;

	int spacing = 0;
	uint color = rgb2ycbcr(rgb_color);
	int x_offset = x;
	int y_offset = y;

	int c_height = font_height;
	for (int i = 0; i < strlen(text); i++) {

		int c_offset = text[i] - 32;

		int c_width = font_glyph_dsc[c_offset].w_px;
		int c_index = font_glyph_dsc[c_offset].glyph_index;

		for (int j = 0; j < c_height; j++) {
			int k = 0;
			unsigned char mask = 0x80;
			unsigned char b = font_glyph_bitmap[c_index];
			while(k < c_width) {

				for(int l = 0; l < scale; l++)
					for(int m = 0; m < scale; m++) {
						int jl = j*scale + l;
						int km = k*scale + m;
						int frame_offset = x_offset + (jl + y_offset)* display->width + km;

						if(b & mask) {
							frame[frame_offset] = color;
							continue;
						}
						unsigned int bg_color = frame[frame_offset];
						unsigned int p_color = bg_color & 0x0000FF00;
						if(p_color < 0x0000DD00) {
							p_color += 0x00005000;
							if(p_color > 0x0000FF00)
								p_color = 0x0000FF00;
							else if(p_color < 0x0000CC00)
								p_color = 0x0000CC00;
							frame[frame_offset] = (bg_color & 0xFFFF00FF) | p_color;
						}
					}

				k++;
				mask = mask >> 1;

				if (mask == 0 || k >= c_width) {
					c_index++;
					b = font_glyph_bitmap[c_index];
					mask = 0x80;
				}
			}
		}
		x_offset += scale*c_width + spacing;
	}

}

/******************************************************************
 *  Function: ece423_video_display_text_frame
 *
 *  Purpose: Add a string to the screen
 *
 ******************************************************************/
void ece423_video_display_text_frame(ece423_video_display* display, char* text) {

	int scale = 4;
	ece423_video_display_clear_screen(display);
	// ece423_video_display_draw_logo(display);
	int text_width = 0;
	for(int i = 0; i < strlen(text); i++) {
		int c_offset = text[i] - 32;
		text_width += font_glyph_dsc[c_offset].w_px*scale;
	}
	int x = (display->width - text_width)/2;
	// int y = 5*display->height/10;
	int y = (display->height - font_height*scale)/2;
	ece423_video_display_add_text(display, text, x, y, RGB_RED, scale);
	ece423_video_display_register_written_buffer(display);
	ece423_video_display_switch_frames(display);
}

/******************************************************************
 *  Function: ece423_video_display_text_on_last_frame
 *
 *  Purpose: Add a string to the screen
 *
 ******************************************************************/
void ece423_video_display_text_on_last_frame(ece423_video_display* display, char* text) {

	// copy current buffer
	int* frame = display->buffer_ptrs[display->buffer_being_displayed]->buffer;
	int* text_frame = display->text_buffer_ptr->buffer;
	for (int i = 0; i < display->bytes_per_frame / 4; i += 1)
		text_frame[i] = frame[i];

	// draw th text
	int scale = 4;

	int text_width = 0;
	for(int i = 0; i < strlen(text); i++) {
		int c_offset = text[i] - 32;
		text_width += font_glyph_dsc[c_offset].w_px*scale;
	}
	int x = (display->width - text_width)/2;
	// int y = (display->height - font_height*scale)/2;
	int y = (display->height - font_height*scale - 20);
	int spacing = 0;
	uint color = rgb2ycbcr(RGB_BLACK);
	int x_offset = x;
	int y_offset = y;

	int c_height = font_height;
	for (int i = 0; i < strlen(text); i++) {
		int c_offset = text[i] - 32;

		int c_width = font_glyph_dsc[c_offset].w_px;
		int c_index = font_glyph_dsc[c_offset].glyph_index;

		for (int j = 0; j < c_height; j++) {
			int k = 0;
			unsigned char mask = 0x80;
			unsigned char b = font_glyph_bitmap[c_index];
			while(k < c_width) {

				for(int l = 0; l < scale; l++)
					for(int m = 0; m < scale; m++) {
						int jl = j*scale + l;
						int km = k*scale + m;
						int frame_offset = x_offset + (jl + y_offset)* display->width + km;

						if(b & mask) {
							text_frame[frame_offset] = color;
							continue;
						}
						unsigned int bg_color = text_frame[frame_offset];
						unsigned int p_color = bg_color & 0x0000FF00;
						if(p_color < 0x0000DD00) {
							p_color += 0x00005000;
							if(p_color > 0x0000FF00)
								p_color = 0x0000FF00;
							else if(p_color < 0x0000CC00)
								p_color = 0x0000CC00;
							text_frame[frame_offset] = (bg_color & 0xFFFF00FF) | p_color;
						}
					}

				k++;
				mask = mask >> 1;

				if (mask == 0 || k >= c_width) {
					c_index++;
					b = font_glyph_bitmap[c_index];
					mask = 0x80;
				}
			}
		}
		x_offset += scale*c_width + spacing;
	}


	// Transfer Descriptor for Frame to mSGDMA
	while (alt_msgdma_standard_descriptor_async_transfer(display->mSGDMA,
			display->text_buffer_ptr->desc_base) != 0) {
	}  // Keep Trying until there is room to Transfer another Frame


}

/******************************************************************
 *                     PRIVATE FUNCTIONS                           *
 ******************************************************************/

/******************************************************************
 *          ece423_video_display_get_descriptor_span
 *          -------------------------------------
 *
 * This Calcs the number of bytes required for descriptor storage
 *
 * The New mSGDMA only needs 1 descriptor per Frame
 *
 * The OLD SGDMA nedded Multiple descriptors per Frame
 *
 * display->descriptors_per_frame
 *  MUST be SetUp Before Calling this func
 *
 * Returns: Size (in bytes) of descriptor memory required.
 ******************************************************************/
alt_u32 ece423_video_display_get_descriptor_span(ece423_video_display *display) {
	return ((display->descriptors_per_frame + 2)
			* sizeof(alt_msgdma_standard_descriptor));
}

/******************************************************************
 *              ece423_video_display_allocate_buffers
 *              ----------------------------------
 *
 *  This Allocates memory for Frame Bufs & descriptors
 *  Returns:  0 - Success
 *           -1 - Error allocating memory
 ******************************************************************/
int ece423_video_display_allocate_buffers(ece423_video_display* display,
		int bytes_per_frame, int num_buffers) {
	int i, ret_code = 0;

	/* Allocate Frame Bufs and descriptor Bufs */

	for (i = 0; i < num_buffers; i++) {
		display->buffer_ptrs[i] = (ece423_video_frame*) malloc(
				sizeof(ece423_video_frame)); // malloc Struct with 2 Ptrs

		if (display->buffer_ptrs[i] == NULL) {
			ret_code = -1;
		}

		display->buffer_ptrs[i]->buffer = (void*) alt_uncached_malloc(
				(bytes_per_frame)); // malloc Frame Buf on Heap
//      display->buffer_ptrs[i]->buffer =
//        (void*) memalign(16, bytes_per_frame); // malloc Frame Buf on Heap
		if (display->buffer_ptrs[i]->buffer == NULL)
			ret_code = -1;

		display->buffer_ptrs[i]->desc_base =
				(alt_msgdma_standard_descriptor*) memalign(32,
						ece423_video_display_get_descriptor_span(display)); // Desc on Heap

		if (display->buffer_ptrs[i]->desc_base == NULL) {
			ret_code = -1;
		}
	}

	display->text_buffer_ptr = (ece423_video_frame*) malloc(
				sizeof(ece423_video_frame)); // malloc Struct with 2 Ptrs
	if (display->text_buffer_ptr == NULL) {
		ret_code = -1;
	}
	display->text_buffer_ptr->buffer = (void*) alt_uncached_malloc(
					(bytes_per_frame)); // malloc Frame Buf on Heap

	if (display->text_buffer_ptr->buffer == NULL)
		ret_code = -1;

	display->text_buffer_ptr->desc_base =
			(alt_msgdma_standard_descriptor*) memalign(32,
					ece423_video_display_get_descriptor_span(display)); // Desc on Heap

	if (display->text_buffer_ptr->desc_base == NULL) {
		ret_code = -1;
	}

	return ret_code;
}

// ************************************************************
int reg_read(int slave_addr, int reg, void *data) {
	bool r = I2C_Read(I2C_SCL_BASE, I2C_SDA_BASE, slave_addr, (alt_u8) reg,
			(alt_u8 *) data);
	if (!r)
		return -1;

	return 0;
}

int reg_write(int slave_addr, int reg, int data) {
	bool r = I2C_Write(I2C_SCL_BASE, I2C_SDA_BASE, slave_addr, (alt_u8) reg,
			(alt_u8) data);
	if (!r)
		return -1;

	return 0;
}

int reg_update_bits(int slave_addr, int reg, int mask, int data) {
	bool r = 0;
	alt_u8 regv = 0;

	r = I2C_Read(I2C_SCL_BASE, I2C_SDA_BASE, slave_addr, reg, &regv);
	if (!r)
		return -1;

	regv &= ~((alt_u8) mask);

	regv |= ((alt_u8) data & (alt_u8) mask);

	r = I2C_Write(I2C_SCL_BASE, I2C_SDA_BASE, slave_addr, reg, regv);
	if (!r)
		return -1;

	return 0;
}

int ece423_hdmi_powerdown(int slave_addr) {
	// power down the encoder
	if (reg_update_bits(slave_addr, 0x41, 0x40, 0x40) != 0)
		return -1;

	return 0;
}

extern int ece423_hdmi_kick_up(int slave_addr) {
	// power up the encoder
	if (reg_update_bits(slave_addr, 0x41, 0x40, 0) != 0)
		return -1;
	return 0;
}

int ece423_hdmi_powerup(int slave_addr) {
	// power up the encoder
	if (reg_update_bits(slave_addr, 0x41, 0x40, 0) != 0)
		return -1;

	// table 14 -- fixed registers must be set after power up
	if (reg_write(slave_addr, 0x98, 0x03) != 0)
		return -1;
	if (reg_update_bits(slave_addr, 0x9a, 0xe0, 0x7 << 5) != 0)
		return -1;
	if (reg_write(slave_addr, 0x9c, 0x30) != 0)
		return -1;
	if (reg_update_bits(slave_addr, 0x9d, 0x03, 0x01) != 0)
		return -1;
	if (reg_write(slave_addr, 0xa2, 0xa4) != 0)
		return -1;
	if (reg_write(slave_addr, 0xa3, 0xa4) != 0)
		return -1;
	if (reg_write(slave_addr, 0xe0, 0xd0) != 0)
		return -1;

	// clear hpd interrupts
	// 0x96[7:6] <- 0xc0 & 0xc0
	if (reg_write(slave_addr, 0x96, 0xff) != 0)
		return -1;

	return 0;
}

int ece423_init_hdmi() {
	bool r = 0;
	int slave_addr = 0x39 << 1;
	int chip_id[4];
	int chip_rev[4];

	// Identify adv7513 chip
	r = I2C_Read(I2C_SCL_BASE, I2C_SDA_BASE, slave_addr, 0x00, &chip_rev[0]);
	if (!r)
		return -1;

	r = I2C_Read(I2C_SCL_BASE, I2C_SDA_BASE, slave_addr, 0xf6, &chip_id[0]);
	if (!r)
		return -2;

	r = I2C_Read(I2C_SCL_BASE, I2C_SDA_BASE, slave_addr, 0xf5, &chip_id[1]);
	if (!r)
		return -3;

	// kickup the encoder
	ece423_hdmi_kick_up(slave_addr);

	// Initiate Color Conversion Matrix
	I2C_Write(I2C_SCL_BASE, I2C_SDA_BASE, slave_addr, 0x18, 0xAA);
	I2C_Write(I2C_SCL_BASE, I2C_SDA_BASE, slave_addr, 0x19, 0xF8);
	I2C_Write(I2C_SCL_BASE, I2C_SDA_BASE, slave_addr, 0x1A, 0x08);
	I2C_Write(I2C_SCL_BASE, I2C_SDA_BASE, slave_addr, 0x1B, 0x00);
	I2C_Write(I2C_SCL_BASE, I2C_SDA_BASE, slave_addr, 0x1C, 0x00);
	I2C_Write(I2C_SCL_BASE, I2C_SDA_BASE, slave_addr, 0x1D, 0x00);
	I2C_Write(I2C_SCL_BASE, I2C_SDA_BASE, slave_addr, 0x1E, 0x1a);
	I2C_Write(I2C_SCL_BASE, I2C_SDA_BASE, slave_addr, 0x1F, 0x84);

	I2C_Write(I2C_SCL_BASE, I2C_SDA_BASE, slave_addr, 0x20, 0x1A);
	I2C_Write(I2C_SCL_BASE, I2C_SDA_BASE, slave_addr, 0x21, 0x6A);
	I2C_Write(I2C_SCL_BASE, I2C_SDA_BASE, slave_addr, 0x22, 0x08);
	I2C_Write(I2C_SCL_BASE, I2C_SDA_BASE, slave_addr, 0x23, 0x00);
	I2C_Write(I2C_SCL_BASE, I2C_SDA_BASE, slave_addr, 0x24, 0x1D);
	I2C_Write(I2C_SCL_BASE, I2C_SDA_BASE, slave_addr, 0x25, 0x50);
	I2C_Write(I2C_SCL_BASE, I2C_SDA_BASE, slave_addr, 0x26, 0x04);
	I2C_Write(I2C_SCL_BASE, I2C_SDA_BASE, slave_addr, 0x27, 0x23);

	I2C_Write(I2C_SCL_BASE, I2C_SDA_BASE, slave_addr, 0x28, 0x1F);
	I2C_Write(I2C_SCL_BASE, I2C_SDA_BASE, slave_addr, 0x29, 0xFC);
	I2C_Write(I2C_SCL_BASE, I2C_SDA_BASE, slave_addr, 0x2A, 0x08);
	I2C_Write(I2C_SCL_BASE, I2C_SDA_BASE, slave_addr, 0x2B, 0x00);
	I2C_Write(I2C_SCL_BASE, I2C_SDA_BASE, slave_addr, 0x2C, 0x0D);
	I2C_Write(I2C_SCL_BASE, I2C_SDA_BASE, slave_addr, 0x2D, 0xDE);
	I2C_Write(I2C_SCL_BASE, I2C_SDA_BASE, slave_addr, 0x2E, 0x19);
	I2C_Write(I2C_SCL_BASE, I2C_SDA_BASE, slave_addr, 0x2F, 0x13);

	return 0;
}

uint rgb2ycbcr(uint rgb) {
	unsigned char r, g, b;
	b = rgb & 0xff;
	g = (rgb >> 8) & 0xff;
	r = (rgb >> 16) & 0xff;

	unsigned char y, cb, cr;
	y = 0.299 * r + 0.587 * g + 0.114 * b;
	cb = -0.168736 * r - 0.331264 * g + 0.5 * b + 128;
	cr = 0.5 * r - 0.418688 * g - 0.081312 * b + 128;

	uint ycbcr = (cr << 16) | (y << 8) | (cb);
	return ycbcr & 0x00ffffff;
}

char *
itoa (int value, char *result, int base)
{
    // check that the base if valid
    if (base < 2 || base > 36) { *result = '\0'; return result; }

    char* ptr = result, *ptr1 = result, tmp_char;
    int tmp_value;

    do {
        tmp_value = value;
        value /= base;
        *ptr++ = "zyxwvutsrqponmlkjihgfedcba9876543210123456789abcdefghijklmnopqrstuvwxyz" [35 + (tmp_value - value * base)];
    } while ( value );

    // Apply negative sign
    if (tmp_value < 0) *ptr++ = '-';
    *ptr-- = '\0';
    while (ptr1 < ptr) {
        tmp_char = *ptr;
        *ptr--= *ptr1;
        *ptr1++ = tmp_char;
    }
    return result;
}
