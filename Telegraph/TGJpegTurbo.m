#import "TGJpegTurbo.h"

/*#import "Endian.h"
#include "jpeglib.h"
#include <setjmp.h>

#import <ImageIO/ImageIO.h>

struct TGJpegErrorManager
{
    struct jpeg_error_mgr pub;
    jmp_buf setjmp_buffer;
};

typedef struct TGJpegErrorManager * TGJpegErrorManagerRef;

static void TGJpegErrorExit(j_common_ptr cinfo)
{
    TGJpegErrorManagerRef myerr = (TGJpegErrorManagerRef)cinfo->err;
    (*cinfo->err->output_message) (cinfo);
    longjmp(myerr->setjmp_buffer, 1);
}

UIImage *TGJpegTurboDecode(NSData *data)
{
    struct jpeg_decompress_struct cinfo;
    struct TGJpegErrorManager errorManager;
    
    JSAMPARRAY buffer;
    int row_stride;
    
    cinfo.err = jpeg_std_error(&errorManager.pub);
    errorManager.pub.error_exit = TGJpegErrorExit;
    if (setjmp(errorManager.setjmp_buffer))
    {
        jpeg_destroy_decompress(&cinfo);
        return nil;
    }
    
    jpeg_create_decompress(&cinfo);
    
    jpeg_mem_src(&cinfo, (unsigned char *)data.bytes, data.length);
    
    jpeg_read_header(&cinfo, true);
    
    cinfo.dct_method = JDCT_IFAST;
    cinfo.do_fancy_upsampling = false;
    cinfo.two_pass_quantize = false;
    cinfo.do_block_smoothing = false;
    cinfo.dither_mode = JDITHER_NONE;
    if (false)
    {
        if (cinfo.image_width > 2000 || cinfo.image_height > 2000)
        {
            cinfo.scale_num = 2;
            cinfo.scale_denom = 8;
        }
    }
    cinfo.out_color_space = JCS_EXT_RGBA;
    
    jpeg_start_decompress(&cinfo);
    
    row_stride = cinfo.output_width * cinfo.output_components;
    
    int resultWidth = cinfo.output_width;
    int resultHeight = cinfo.output_height;
    int outputStride = resultWidth * 4;
    
    //NSLog(@"output: %dx%d (row stride %d)", cinfo.output_width, cinfo.output_height, row_stride);
    
    buffer = (*cinfo.mem->alloc_sarray)((j_common_ptr) &cinfo, JPOOL_IMAGE, row_stride, 1);
    
    uint8_t *rgba = (uint8_t *)malloc(cinfo.output_width * cinfo.output_height * 4);
    JSAMPLE *rowptr = (JSAMPLE *)rgba;
    
    CFAbsoluteTime decompressStart = CFAbsoluteTimeGetCurrent();
    
    while (cinfo.output_scanline < cinfo.output_height)
    {
        int rowCount = jpeg_read_scanlines(&cinfo, &rowptr, 1);
        rowptr += rowCount * row_stride;
    }
    
    //NSLog(@"Decompress time: %d ms", (int)((CFAbsoluteTimeGetCurrent() - decompressStart) * 1000));
    decompressStart = CFAbsoluteTimeGetCurrent();
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef bitmapContext = CGBitmapContextCreate(rgba, resultWidth, resultHeight, 8, outputStride, colorSpace, kCGImageAlphaPremultipliedLast);
    CFRelease(colorSpace);
    
    CGImageRef cgImage = CGBitmapContextCreateImage(bitmapContext);
    CGContextRelease(bitmapContext);
    free(rgba);
    
    __autoreleasing UIImage *resultImage = [[UIImage alloc] initWithCGImage:cgImage];
    CGImageRelease(cgImage);
    
    jpeg_finish_decompress(&cinfo);
    jpeg_destroy_decompress(&cinfo);
    
    //NSLog(@"Parse time: %d ms", (int)((CFAbsoluteTimeGetCurrent() - decompressStart) * 1000));
    
    return resultImage;
}
*/