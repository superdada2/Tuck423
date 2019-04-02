/******************************************************************************
*                                                                             *
* License Agreement                                                           *
*                                                                             *
* Copyright (c) 2007 Altera Corporation, San Jose, California, USA.           *
* All rights reserved.                                                        *
*                                                                             *
* Permission is hereby granted, free of charge, to any person obtaining a     *
* copy of this software and associated documentation files (the "Software"),  *
* to deal in the Software without restriction, including without limitation   *
* the rights to use, copy, modify, merge, publish, distribute, sublicense,    *
* and/or sell copies of the Software, and to permit persons to whom the       *
* Software is furnished to do so, subject to the following conditions:        *
*                                                                             *
* The above copyright notice and this permission notice shall be included in  *
* all copies or substantial portions of the Software.                         *
*                                                                             *
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR  *
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,    *
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE *
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER      *
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING     *
* FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER         *
* DEALINGS IN THE SOFTWARE.                                                   *
*                                                                             *
* This agreement shall be governed in all respects by the laws of the State   *
* of California and by the laws of the United States of America.              *
*                                                                             *
******************************************************************************/

/*
****************************
* ECE423 Video Controller *
****************************
*/

#ifndef __ECE423_VID_CTL_H__
#define __ECE423_VID_CTL_H__

#include <stdio.h>
#include "system.h"
#include "altera_msgdma.h"
#include "altera_msgdma_descriptor_regs.h"
#include "altera_msgdma_csr_regs.h"

/* Maximum number of display buffers the driver will accept */
#define ECE423_VIDEO_DISPLAY_MAX_BUFFERS 36

#define RGB_BLACK 0x000000
#define RGB_WHITE 0xFFFFFF
#define RGB_RED 0xFF0000
#define RGB_GREEN 0x00FF00
#define RGB_BLUE 0x0000FF
#define RGB_YELLOW 0xFFFF00
#define RGB_MAGENTA 0xFF00FF
#define RGB_CYAN 0x00FFFF
#define RGB_AMBER 0xEBD150
#define RGB_COLORX 0xB22222

#define DESC_CONTROL (ALTERA_MSGDMA_DESCRIPTOR_CONTROL_PARK_READS_MASK | ALTERA_MSGDMA_DESCRIPTOR_CONTROL_GENERATE_SOP_MASK | ALTERA_MSGDMA_DESCRIPTOR_CONTROL_GENERATE_EOP_MASK | ALTERA_MSGDMA_DESCRIPTOR_CONTROL_GO_MASK) // Also set the park bit so that we can let the mSGDMA worry about the frame DUPLICATION

typedef struct
{
  alt_msgdma_standard_descriptor *desc_base; /* Pointer to mSGDMA descriptor chain Changed 4Jun16 */
  void *buffer;                              /* Pointer to video data buffer */
} ece423_video_frame;

typedef struct
{
  alt_msgdma_dev *mSGDMA; // Changed 4Jun16
  ece423_video_frame *buffer_ptrs[ECE423_VIDEO_DISPLAY_MAX_BUFFERS];
  ece423_video_frame *text_buffer_ptr;
  int buffer_being_displayed;
  int buffer_being_written;
  int width;
  int height;
  int bytes_per_pixel;
  int bytes_per_frame;
  int num_frame_buffers;
  int descriptors_per_frame;
  char *video_name;
} ece423_video_display;

// -------------
/* Public API */
// -------------
ece423_video_display *ece423_video_display_init(char *sgdma_name, int width, int height, int num_buffers);
int ece423_video_display_buffer_is_available(ece423_video_display *display);
alt_u32 *ece423_video_display_get_buffer(ece423_video_display *display);
void ece423_video_display_register_written_buffer(ece423_video_display *display);
int ece423_video_display_switch_frames(ece423_video_display *display);
void ece423_video_display_discard_buffered_frames(ece423_video_display *display);
int ece423_video_display_is_empty(ece423_video_display *display);

void ece423_video_display_demo(ece423_video_display* display);
void ece423_video_display_clear_screen(ece423_video_display *frame_buffer);
void ece423_video_display_color_screen(ece423_video_display *display, uint rgb_color);
void ece423_video_display_add_frame_number(ece423_video_display *display, int frame_num, int total_frames);
void ece423_video_display_set_video_name(ece423_video_display *display, char *name);
void ece423_video_display_draw_logo(ece423_video_display *display);
void ece423_video_display_add_text(ece423_video_display *display, char *text, int x, int y, uint rgb_color, int scale);
void ece423_video_display_text_frame(ece423_video_display* display, char* text);
void ece423_video_display_text_on_last_frame(ece423_video_display* display, char* text);

// --------------------
/* Private functions */
// --------------------
int ece423_init_hdmi();
alt_u32 ece423_video_display_get_descriptor_span(ece423_video_display *display);
int ece423_video_display_allocate_buffers(ece423_video_display *display, int bytes_per_frame, int num_buffers);
uint rgb2ycbcr(uint rgb);
char *itoa(int value, char *result, int base);
#endif // __ECE423_VID_CTL_H__
