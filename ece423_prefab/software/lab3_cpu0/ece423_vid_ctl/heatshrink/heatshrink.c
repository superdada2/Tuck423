#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>

#include "heatshrink_decoder.h"
#include "heatshrink.h"

#define DEF_WINDOW_SZ2 14
#define DEF_LOOKAHEAD_SZ2 10
#define DEF_DECODER_INPUT_BUFFER_SIZE 256
#define DEF_BUFFER_SIZE (64 * 1024)


static void die(char *msg) {
    printf("%s\n", msg);
//    exit(EXIT_FAILURE);
}


static int decoder_sink_read(char** out, heatshrink_decoder *hsd,
        uint8_t *data, size_t data_sz) {
    size_t sink_sz = 0;
    size_t poll_sz = 0;
    size_t out_sz = 4096;
    uint8_t out_buf[out_sz];
    memset(out_buf, 0, out_sz);

    HSD_sink_res sres;
    HSD_poll_res pres;
    HSD_finish_res fres;
//    printf("Sinking: %d\n", data_sz);
    char* out_ptr = *out;
    size_t sunk = 0;
    do {
        if (data_sz > 0) {
            sres = heatshrink_decoder_sink(hsd, &data[sunk], data_sz - sunk, &sink_sz);
            if (sres < 0) { die("sink"); }
            sunk += sink_sz;
        }

        do {
            pres = heatshrink_decoder_poll(hsd, out_buf, out_sz, &poll_sz);
            if (pres < 0) { die("poll"); }
            memcpy(out_ptr, out_buf, poll_sz);
            out_ptr = out_ptr + poll_sz;
            *out = out_ptr;
            
        } while (pres == HSDR_POLL_MORE);
        
        if (data_sz == 0 && poll_sz == 0) {
            fres = heatshrink_decoder_finish(hsd);
            if (fres < 0) { die("finish"); }
            if (fres == HSDR_FINISH_DONE) { return 1; }
        }
    } while (sunk < data_sz);

    return 0;
}

int decompress(char* in, int in_size, char* out, int out_size) {
    size_t window_sz = 1 << DEF_WINDOW_SZ2;
    size_t ibs = DEF_DECODER_INPUT_BUFFER_SIZE;
    heatshrink_decoder *hsd = heatshrink_decoder_alloc(ibs,
        DEF_WINDOW_SZ2, DEF_LOOKAHEAD_SZ2);

    if (hsd == NULL) { die("failed to init decoder"); }

    ssize_t read_sz = 0;
    HSD_finish_res fres;
    int done_sz = 0;
    char* out_ptr = out;
//    printf("Decoding\n");
    /* Process input until end of stream */
    while (1) {
        int rem_sz = in_size - done_sz;
        read_sz = rem_sz >= window_sz? window_sz : rem_sz;
        uint8_t *input = in + done_sz;
        
        if (rem_sz == 0) {
            fres = heatshrink_decoder_finish(hsd);
            if (fres < 0) { die("finish"); }
            if (fres == HSDR_FINISH_DONE) break;        
        } else {
            if (decoder_sink_read(&out_ptr, hsd, input, read_sz)) { break; }
        }
        done_sz = done_sz + rem_sz;
    }
        
    heatshrink_decoder_free(hsd);
    return 0;
}

