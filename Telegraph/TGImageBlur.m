#import "TGImageBlur.h"

#import "TGImageUtils.h"

#import <Accelerate/Accelerate.h>

#import "UIImage+TG.h"
#import "TGStaticBackdropImageData.h"

#define TG_USE_NEON 0

#if TG_USE_NEON
#   import <arm_neon.h>
#endif

static inline uint64_t get_colors (const uint8_t *p) {
    return p[0] + (p[1] << 16) + ((uint64_t)p[2] << 32);
}

static void fastBlur (int imageWidth, int imageHeight, int imageStride, void *pixels)
{
    uint8_t *pix = (uint8_t *)pixels;
    const int w = imageWidth;
    const int h = imageHeight;
    const int stride = imageStride;
    const int radius = 3;
    const int r1 = radius + 1;
    const int div = radius * 2 + 1;
    
    if (radius > 15 || div >= w || div >= h)
    {
        return;
    }
    
    uint64_t rgb[imageStride * imageHeight];
    
    int x, y, i;
    
    int yw = 0;
    const int we = w - r1;
    for (y = 0; y < h; y++) {
        uint64_t cur = get_colors (&pix[yw]);
        uint64_t rgballsum = -radius * cur;
        uint64_t rgbsum = cur * ((r1 * (r1 + 1)) >> 1);
        
        for (i = 1; i <= radius; i++) {
            uint64_t cur = get_colors (&pix[yw + i * 4]);
            rgbsum += cur * (r1 - i);
            rgballsum += cur;
        }
        
        x = 0;
        
#define update(start, middle, end)                         \
rgb[y * w + x] = (rgbsum >> 4) & 0x00FF00FF00FF00FF; \
\
rgballsum += get_colors (&pix[yw + (start) * 4]) -   \
2 * get_colors (&pix[yw + (middle) * 4]) +  \
get_colors (&pix[yw + (end) * 4]);      \
rgbsum += rgballsum;                                 \
x++;                                                 \

        while (x < r1) {
            update (0, x, x + r1);
        }
        while (x < we) {
            update (x - r1, x, x + r1);
        }
        while (x < w) {
            update (x - r1, x, w - 1);
        }
#undef update
        
        yw += stride;
    }
    
    const int he = h - r1;
    for (x = 0; x < w; x++) {
        uint64_t rgballsum = -radius * rgb[x];
        uint64_t rgbsum = rgb[x] * ((r1 * (r1 + 1)) >> 1);
        for (i = 1; i <= radius; i++) {
            rgbsum += rgb[i * w + x] * (r1 - i);
            rgballsum += rgb[i * w + x];
        }
        
        y = 0;
        int yi = x * 4;
        
#define update(start, middle, end)         \
int64_t res = rgbsum >> 4;           \
pix[yi] = res;                       \
pix[yi + 1] = res >> 16;             \
pix[yi + 2] = res >> 32;             \
\
rgballsum += rgb[x + (start) * w] -  \
2 * rgb[x + (middle) * w] + \
rgb[x + (end) * w];     \
rgbsum += rgballsum;                 \
y++;                                 \
yi += stride;
        
        while (y < r1) {
            update (0, y, y + r1);
        }
        while (y < he) {
            update (y - r1, y, y + r1);
        }
        while (y < h) {
            update (y - r1, y, h - 1);
        }
#undef update
    }
}

static void fastBlurMore (int imageWidth, int imageHeight, int imageStride, void *pixels)
{
    uint8_t *pix = (uint8_t *)pixels;
    const int w = imageWidth;
    const int h = imageHeight;
    const int stride = imageStride;
    const int radius = 7;
    const int r1 = radius + 1;
    const int div = radius * 2 + 1;
    
    if (radius > 15 || div >= w || div >= h)
    {
        return;
    }
    
    uint64_t rgb[imageStride * imageHeight];
    
    int x, y, i;
    
    int yw = 0;
    const int we = w - r1;
    for (y = 0; y < h; y++) {
        uint64_t cur = get_colors (&pix[yw]);
        uint64_t rgballsum = -radius * cur;
        uint64_t rgbsum = cur * ((r1 * (r1 + 1)) >> 1);
        
        for (i = 1; i <= radius; i++) {
            uint64_t cur = get_colors (&pix[yw + i * 4]);
            rgbsum += cur * (r1 - i);
            rgballsum += cur;
        }
        
        x = 0;
        
#define update(start, middle, end)                         \
rgb[y * w + x] = (rgbsum >> 6) & 0x00FF00FF00FF00FF; \
\
rgballsum += get_colors (&pix[yw + (start) * 4]) -   \
2 * get_colors (&pix[yw + (middle) * 4]) +  \
get_colors (&pix[yw + (end) * 4]);      \
rgbsum += rgballsum;                                 \
x++;                                                 \

        while (x < r1) {
            update (0, x, x + r1);
        }
        while (x < we) {
            update (x - r1, x, x + r1);
        }
        while (x < w) {
            update (x - r1, x, w - 1);
        }
#undef update
        
        yw += stride;
    }
    
    const int he = h - r1;
    for (x = 0; x < w; x++) {
        uint64_t rgballsum = -radius * rgb[x];
        uint64_t rgbsum = rgb[x] * ((r1 * (r1 + 1)) >> 1);
        for (i = 1; i <= radius; i++) {
            rgbsum += rgb[i * w + x] * (r1 - i);
            rgballsum += rgb[i * w + x];
        }
        
        y = 0;
        int yi = x * 4;
        
#define update(start, middle, end)         \
int64_t res = rgbsum >> 6;           \
pix[yi] = res;                       \
pix[yi + 1] = res >> 16;             \
pix[yi + 2] = res >> 32;             \
\
rgballsum += rgb[x + (start) * w] -  \
2 * rgb[x + (middle) * w] + \
rgb[x + (end) * w];     \
rgbsum += rgballsum;                 \
y++;                                 \
yi += stride;
        
        while (y < r1) {
            update (0, y, y + r1);
        }
        while (y < he) {
            update (y - r1, y, y + r1);
        }
        while (y < h) {
            update (y - r1, y, h - 1);
        }
#undef update
    }
}

static void matrixMul(CGFloat *a, CGFloat *b, CGFloat *result)
{
	for (int i = 0; i != 4; ++i)
	{
 		for (int j = 0; j != 4; ++j)
		{
			CGFloat sum = 0;
			for (int k = 0; k != 4; ++k)
			{
				sum += a[i + k * 4] * b[k + j * 4];
			}
			result[i + j * 4] = sum;
		}
	}
}

static void matrixVectorMul(CGFloat *matrix, CGFloat *vector, CGFloat *result)
{
    for (int i=0; i < 4; i++)
    {
        for (int j = 0; j < 4; j++)
        {
            result[i] += (matrix[i * 4 + j] * vector[j]);
        }
    }
}

static inline CGSize fitSize(CGSize size, CGSize maxSize)
{
    if (size.width < 1)
        size.width = 1;
    if (size.height < 1)
        size.height = 1;
    
    if (size.width > maxSize.width)
    {
        size.height = CGFloor((size.height * maxSize.width / size.width));
        size.width = maxSize.width;
    }
    if (size.height > maxSize.height)
    {
        size.width = CGFloor((size.width * maxSize.height / size.height));
        size.height = maxSize.height;
    }
    return size;
}

static void computeImageVariance(uint8_t *memory, int width, int height, int stride, float *outVariance, float *outLuminance, float *outRealLuminance)
{
    uint32_t rnSum = 0;
    uint32_t gnSum = 0;
    uint32_t bnSum = 0;
    
    uint64_t rnSumSq = 0;
    uint64_t gnSumSq = 0;
    uint64_t bnSumSq = 0;
    
    uint32_t luminanceSum = 0;
    //uint64_t luminanceSumSq = 0;
    
    /*float rSum = 0.0f;
    float gSum = 0.0f;
    float bSum = 0.0f;
    
    float rSumSq = 0.0f;
    float gSumSq = 0.0f;
    float bSumSq = 0.0f;*/
    
    uint32_t histogram[10] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
    
    for (int y = 0; y < height; y++)
    {
        for (int x = 0; x < width; x++)
        {
            uint32_t color = *((uint32_t *)&memory[y * stride + x * 4]);
            
            uint32_t r = (color >> 16) & 0xff;
            uint32_t g = (color >> 8) & 0xff;
            uint32_t b = color & 0xff;
            
            uint32_t pixelLuminance = (uint8_t)((r * 299 + g * 587 + b * 114) / 1000);
            histogram[(pixelLuminance * 9 / 255) % 10]++;
            
            luminanceSum += pixelLuminance;
            //luminanceSumSq += pixelLuminance * pixelLuminance;
            
            rnSum += r;
            gnSum += g;
            bnSum += b;
            
            rnSumSq += r * r;
            gnSumSq += g * g;
            bnSumSq += b * b;
            
            /*rSum += r / 255.0f;
            gSum += g / 255.0f;
            bSum += b / 255.0f;
            
            rSumSq += (r / 255.0f) * (r / 255.0f);
            gSumSq += (g / 255.0f) * (g / 255.0f);
            bSumSq += (b / 255.0f) * (b / 255.0f);*/
        }
    }
    
    int n = width * height;
    
    /*float rVariance = (rSumSq - (rSum * rSum) / n) / (n);
    float gVariance = (gSumSq - (gSum * gSum) / n) / (n);
    float bVariance = (bSumSq - (bSum * bSum) / n) / (n);*/
    
    float rnVariance = ((uint64_t)((rnSumSq / 255) - ((uint64_t)rnSum * (uint64_t)rnSum / 255) / n)) / (255.0f * n);
    float gnVariance = ((uint64_t)((gnSumSq / 255) - ((uint64_t)gnSum * (uint64_t)gnSum / 255) / n)) / (255.0f * n);
    float bnVariance = ((uint64_t)((bnSumSq / 255) - ((uint64_t)bnSum * (uint64_t)bnSum / 255) / n)) / (255.0f * n);
    
    float variance = rnVariance + gnVariance + bnVariance;
    if (outVariance != NULL)
        *outVariance = variance;
    
    //float luminanceVariance = ((uint64_t)((luminanceSumSq / 255) - ((uint64_t)luminanceSum * (uint64_t)luminanceSum / 255) / n)) / (255.0f * n);
    
    float floatHistogram[10];
    
    float norm = (float)(width * height);
    
    float n0 = 0.0f;
    float n1 = 0.0f;
    for (int i = 0; i < 10; i++)
    {
        floatHistogram[i] = histogram[i] / norm;
        
        if (i <= 6)
            n0 += floatHistogram[i];
        else
            n1 += floatHistogram[i];
    }
    
    //TGLog(@"histogram: [%f %f %f %f %f %f %f %f %f %f]", floatHistogram[0], floatHistogram[1], floatHistogram[2], floatHistogram[3], floatHistogram[4], floatHistogram[5], floatHistogram[6], floatHistogram[7], floatHistogram[8], floatHistogram[9]);
    
    if (outLuminance != NULL)
        *outLuminance = n0 < n1 ? 0.95f : 0.5f;
    
    if (outRealLuminance != NULL)
        *outRealLuminance = (luminanceSum / (norm * 255.0f));
}

static void fastScaleImage(uint8_t *sourceMemory, int sourceWidth, int sourceHeight, int sourceStride, uint8_t *targetMemory, int targetWidth, int targetHeight, int targetStride, CGRect sourceRectInTargetSpace)
{
    int imageX = MIN(0, (int)sourceRectInTargetSpace.origin.x);
    int imageY = MIN(0, (int)sourceRectInTargetSpace.origin.y);
    int imageWidth = (int)sourceRectInTargetSpace.size.width;
    int imageHeight = (int)sourceRectInTargetSpace.size.height;
    
    for (int y = 0; y < targetHeight; y++)
    {
        for (int x = 0; x < targetWidth; x++)
        {
            int sourceY = (y - imageY) * sourceHeight / imageHeight;
            int sourceX = (x - imageX) * sourceWidth / imageWidth;
            
            if (sourceX >= 0 && sourceY >= 0 && sourceX < sourceWidth && sourceY < sourceHeight)
            {
                uint32_t color = *((uint32_t *)&sourceMemory[sourceY * sourceStride + sourceX * 4]);
                *((uint32_t *)&targetMemory[y * targetStride + x * 4]) = color;
            }
        }
    }
}

static uint32_t TGImageAverageColor(void *memory, const unsigned int width, const unsigned int height, const unsigned int stride)
{
    int32_t av0 = 0;
    int32_t av1 = 0;
    int32_t av2 = 0;
    
    for (unsigned int y = 0; y < height; y++)
    {
        for (unsigned int x = 0; x < width; x++)
        {
            uint32_t pixel = *((uint32_t *)(&memory[y * stride + x * 4]));
            av0 += pixel & 0xff;
            av1 += (pixel >> 8) & 0xff;
            av2 += (pixel >> 16) & 0xff;
        }
    }
    
    uint32_t norm = (width * height);
    av0 = av0 / norm;
    av1 = av1 / norm;
    av2 = av2 / norm;
    
    return 0xff000000 | av0 | (av1 << 8) | (av2 << 16);
}

static inline uint32_t alphaComposePremultipliedPixels(uint32_t a, uint32_t b)
{
    uint32_t a0 = ((a >> 24) & 0xff);
    uint32_t a1 = ((b >> 24) & 0xff);
    
    uint32_t r0 = (a >> 16) & 0xff;
    uint32_t g0 = (a >> 8) & 0xff;
    uint32_t b0 = a & 0xff;
    
    uint32_t r1 = (b >> 16) & 0xff;
    uint32_t g1 = (b >> 8) & 0xff;
    uint32_t b1 = b & 0xff;
    
    uint32_t ta = ((a0 * a0) >> 8) + ((a1 * (255 - ((a0 * a0) >> 8))) >> 8);
    uint32_t tr = ((r0 * a0) >> 8) + ((r1 * (255 - ((a0 * a0) >> 8))) >> 8);
    uint32_t tg = ((g0 * a0) >> 8) + ((g1 * (255 - ((a0 * a0) >> 8))) >> 8);
    uint32_t tb = ((b0 * a0) >> 8) + ((b1 * (255 - ((a0 * a0) >> 8))) >> 8);
    
    return (ta << 24) | (tr << 16) | (tg << 8) | tb;
}

static inline uint32_t premultipliedPixel(uint32_t rgb, uint32_t alpha)
{
    uint32_t r = (((rgb >> 16) & 0xff) * alpha) >> 8;
    uint32_t g = (((rgb >> 8) & 0xff) * alpha) >> 8;
    uint32_t b = ((rgb & 0xff) * alpha) >> 8;
    
    return (alpha << 24) | (r << 16) | (g << 8) | b;
}

static void addAttachmentImageCorners(void *memory, const unsigned int width, const unsigned int height, const unsigned int stride)
{
    const int scale = TGIsRetina() ? 2 : 1;
    
    const int shadowSize = 1;
    const int strokeWidth = scale >= 2 ? 3 : 2;
    const int radius = 13 * scale;
    
    const int contextWidth = radius * 2 + shadowSize * 2 + strokeWidth * 2;
    const int contextHeight = radius * 2 + shadowSize * 2 + strokeWidth * 2;
    const int contextStride = (4 * contextWidth + 15) & (~15);
    
    static uint8_t *contextMemory = NULL;
    static uint8_t *alphaMemory = NULL;

    const uint32_t shadowColorRaw = 0x44000000;
    const uint32_t shadowColorArgb = premultipliedPixel(shadowColorRaw & 0xffffff, ((shadowColorRaw >> 24) & 0xff) - 30);
    static uint32_t strokeColorArgb = 0xffffffff;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        contextMemory = malloc(contextStride * contextHeight);
        memset(contextMemory, 0, contextStride * contextHeight);
        
        alphaMemory = malloc(contextStride * contextHeight);
        
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGBitmapInfo bitmapInfo = kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Host;
        CGContextRef targetContext = CGBitmapContextCreate(contextMemory, contextWidth, contextHeight, 8, contextStride, colorSpace, bitmapInfo);
        CFRelease(colorSpace);
        
        CGContextSetFillColorWithColor(targetContext, [UIColor blackColor].CGColor);
        CGContextFillEllipseInRect(targetContext, CGRectMake(shadowSize + strokeWidth / 2.0f, shadowSize + strokeWidth / 2.0f, contextWidth - (shadowSize + strokeWidth / 2.0f) * 2.0f, contextHeight - (shadowSize + strokeWidth / 2.0f) * 2.0f));
        
        memcpy(alphaMemory, contextMemory, contextStride * contextHeight);
        
        memset(contextMemory, 0, contextStride * contextHeight);
        
        CGContextSetStrokeColorWithColor(targetContext, UIColorRGBA(shadowColorRaw, ((shadowColorRaw >> 24) & 0xff) / 255.0f).CGColor);
        CGContextSetLineWidth(targetContext, shadowSize);
        CGContextStrokeEllipseInRect(targetContext, CGRectMake(shadowSize / 2.0f, shadowSize / 2.0f, contextWidth - shadowSize, contextHeight - shadowSize));
        CGContextStrokeEllipseInRect(targetContext, CGRectMake(shadowSize / 2.0f + 0.5f, shadowSize / 2.0f - 0.5f, contextWidth - shadowSize, contextHeight - shadowSize));
        
        CGContextSetStrokeColorWithColor(targetContext, UIColorRGBA(shadowColorRaw, (((shadowColorRaw >> 24) & 0xff) / 255.0f) * 0.5f).CGColor);
        CGContextStrokeEllipseInRect(targetContext, CGRectMake(shadowSize / 2.0f - 0.2f, shadowSize / 2.0f + 0.2f, contextWidth - shadowSize, contextHeight - shadowSize));
        
        CGContextSetStrokeColorWithColor(targetContext, UIColorRGB(strokeColorArgb).CGColor);
        CGContextSetLineWidth(targetContext, strokeWidth);
        CGContextStrokeEllipseInRect(targetContext, CGRectMake(shadowSize + strokeWidth / 2.0f, shadowSize + strokeWidth / 2.0f, contextWidth - (shadowSize + strokeWidth / 2.0f) * 2.0f, contextHeight - (shadowSize + strokeWidth / 2.0f) * 2.0f));
        
        CGContextSetStrokeColorWithColor(targetContext, UIColorRGBA(strokeColorArgb, 0.4f).CGColor);
        CGContextStrokeEllipseInRect(targetContext, CGRectMake(shadowSize + strokeWidth / 2.0f + 0.5f, shadowSize + strokeWidth / 2.0f - 0.5f, contextWidth - (shadowSize + strokeWidth / 2.0f) * 2.0f, contextHeight - (shadowSize + strokeWidth / 2.0f) * 2.0f));
        
        CFRelease(targetContext);
    });
    
    const unsigned int radiusWithPadding = contextWidth / 2;
    const unsigned int rightRadius = width - radiusWithPadding;
    
    for (unsigned int y = 0; y < radiusWithPadding; y++)
    {
        for (unsigned int x = 0; x < radiusWithPadding; x++)
        {
            uint32_t alpha = alphaMemory[y * contextStride + x * 4 + 3];
            uint32_t pixel = *((uint32_t *)(&memory[y * stride + x * 4]));
            
            pixel = (alpha << 24) | (((((pixel >> 16) & 0xff) * alpha) >> 8) << 16) | (((((pixel >> 8) & 0xff) * alpha) >> 8) << 8) | (((((pixel >> 0) & 0xff) * alpha) >> 8) << 0);
            pixel = alphaComposePremultipliedPixels(*((uint32_t *)&contextMemory[y * contextStride + x * 4]), pixel);
            *((uint32_t *)(&memory[y * stride + x * 4])) = pixel;
        }
    }
    
    for (int y = 0; y < shadowSize; y++)
    {
        for (unsigned int x = radiusWithPadding; x < rightRadius; x++)
        {
            *((uint32_t *)(&memory[y * stride + x * 4])) = shadowColorArgb;
        }
    }
    
    for (int y = shadowSize; y < shadowSize + strokeWidth; y++)
    {
        for (unsigned int x = radiusWithPadding; x < rightRadius; x++)
        {
            *((uint32_t *)(&memory[y * stride + x * 4])) = strokeColorArgb;
        }
    }
    
    for (unsigned int y = 0; y < radiusWithPadding; y++)
    {
        for (unsigned int x = rightRadius; x < width; x++)
        {
            uint32_t alpha = alphaMemory[y * contextStride + (width - 1 - x) * 4 + 3];
            uint32_t pixel = *((uint32_t *)(&memory[y * stride + x * 4]));

            pixel = (alpha << 24) | (((((pixel >> 16) & 0xff) * alpha) >> 8) << 16) | (((((pixel >> 8) & 0xff) * alpha) >> 8) << 8) | (((((pixel >> 0) & 0xff) * alpha) >> 8) << 0);
            pixel = alphaComposePremultipliedPixels(*((uint32_t *)&contextMemory[y * contextStride + (width - 1 - x) * 4]), pixel);
            *((uint32_t *)(&memory[y * stride + x * 4])) = pixel;
        }
    }
    
    for (unsigned int y = radiusWithPadding; y < height - radiusWithPadding; y++)
    {
        for (int x = 0; x < shadowSize; x++)
        {
            *((uint32_t *)(&memory[y * stride + x * 4])) = shadowColorArgb;
        }

        for (int x = shadowSize; x < shadowSize + strokeWidth; x++)
        {
            *((uint32_t *)(&memory[y * stride + x * 4])) = strokeColorArgb;
        }
        
        for (unsigned int x = width - shadowSize - strokeWidth; x < width - shadowSize; x++)
        {
            *((uint32_t *)(&memory[y * stride + x * 4])) = strokeColorArgb;
        }
        
        for (unsigned int x = width - shadowSize; x < width; x++)
        {
            *((uint32_t *)(&memory[y * stride + x * 4])) = shadowColorArgb;
        }
    }
    
    for (unsigned int y = height - radiusWithPadding; y < height; y++)
    {
        for (unsigned int x = 0; x < radiusWithPadding; x++)
        {
            uint32_t alpha = alphaMemory[(height - 1 - y) * contextStride + x * 4 + 3];
            uint32_t pixel = *((uint32_t *)(&memory[y * stride + x * 4]));
            
            pixel = (alpha << 24) | (((((pixel >> 16) & 0xff) * alpha) >> 8) << 16) | (((((pixel >> 8) & 0xff) * alpha) >> 8) << 8) | (((((pixel >> 0) & 0xff) * alpha) >> 8) << 0);
            pixel = alphaComposePremultipliedPixels(*((uint32_t *)&contextMemory[(height - 1 - y) * contextStride + x * 4]), pixel);
            *((uint32_t *)(&memory[y * stride + x * 4])) = pixel;
        }
    }
    
    for (unsigned int y = height - shadowSize - strokeWidth; y < height - shadowSize; y++)
    {
        for (unsigned int x = radiusWithPadding; x < rightRadius; x++)
        {
            *((uint32_t *)(&memory[y * stride + x * 4])) = strokeColorArgb;
        }
    }
    
    for (unsigned int y = height - shadowSize; y < height; y++)
    {
        for (unsigned int x = radiusWithPadding; x < rightRadius; x++)
        {
            *((uint32_t *)(&memory[y * stride + x * 4])) = shadowColorArgb;
        }
    }
    
    for (unsigned int y = height - radiusWithPadding; y < height; y++)
    {
        for (unsigned int x = width - radiusWithPadding; x < width; x++)
        {
            uint32_t alpha = alphaMemory[(height - 1 - y) * contextStride + (width - 1 - x) * 4 + 3];
            uint32_t pixel = *((uint32_t *)(&memory[y * stride + x * 4]));

            pixel = (alpha << 24) | (((((pixel >> 16) & 0xff) * alpha) >> 8) << 16) | (((((pixel >> 8) & 0xff) * alpha) >> 8) << 8) | (((((pixel >> 0) & 0xff) * alpha) >> 8) << 0);
            pixel = alphaComposePremultipliedPixels(*((uint32_t *)&contextMemory[(height - 1 - y) * contextStride + (width - 1 - x) * 4]), pixel);
            *((uint32_t *)(&memory[y * stride + x * 4])) = pixel;
        }
    }
}

static int16_t *brightenMatrix(int32_t *outDivisor)
{
    static int16_t saturationMatrix[16];
    static const int32_t divisor = 256;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        CGFloat s = 2.6f;
        CGFloat offset = 0.02f;
        CGFloat factor = 1.3f;
        CGFloat satMatrix[] = {
            0.0722f + 0.9278f * s,  0.0722f - 0.0722f * s,  0.0722f - 0.0722f * s,  0,
            0.7152f - 0.7152f * s,  0.7152f + 0.2848f * s,  0.7152f - 0.7152f * s,  0,
            0.2126f - 0.2126f * s,  0.2126f - 0.2126f * s,  0.2126f + 0.7873f * s,  0,
            0.0f,                    0.0f,                    0.0f,  1,
        };
        CGFloat contrastMatrix[] = {
            factor, 0.0f, 0.0f, 0.0f,
            0.0f, factor, 0.0f, 0.0f,
            0.0f, 0.0f, factor, 0.0f,
            offset, offset, offset, 1.0f
        };
        CGFloat colorMatrix[16];
        matrixMul(satMatrix, contrastMatrix, colorMatrix);
        
        NSUInteger matrixSize = sizeof(colorMatrix) / sizeof(colorMatrix[0]);
        for (NSUInteger i = 0; i < matrixSize; ++i) {
            saturationMatrix[i] = (int16_t)roundf(colorMatrix[i] * divisor);
        }
    });
    
    if (outDivisor != NULL)
        *outDivisor = divisor;
    
    return saturationMatrix;
}

static int16_t *brightenTimestampMatrix(int32_t *outDivisor)
{
    static int16_t saturationMatrix[16];
    static const int32_t divisor = 256;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        CGFloat s = 1.1f;
        CGFloat offset = 0.1f;
        CGFloat factor = 1.2f;
        CGFloat satMatrix[] = {
            0.0722f + 0.9278f * s,  0.0722f - 0.0722f * s,  0.0722f - 0.0722f * s,  0,
            0.7152f - 0.7152f * s,  0.7152f + 0.2848f * s,  0.7152f - 0.7152f * s,  0,
            0.2126f - 0.2126f * s,  0.2126f - 0.2126f * s,  0.2126f + 0.7873f * s,  0,
            0.0f,                    0.0f,                    0.0f,  1,
        };
        CGFloat contrastMatrix[] = {
            factor, 0.0f, 0.0f, 0.0f,
            0.0f, factor, 0.0f, 0.0f,
            0.0f, 0.0f, factor, 0.0f,
            offset, offset, offset, 1.0f
        };
        CGFloat colorMatrix[16];
        matrixMul(satMatrix, contrastMatrix, colorMatrix);
        
        NSUInteger matrixSize = sizeof(colorMatrix) / sizeof(colorMatrix[0]);
        for (NSUInteger i = 0; i < matrixSize; ++i) {
            saturationMatrix[i] = (int16_t)roundf(colorMatrix[i] * divisor);
        }
    });
    
    if (outDivisor != NULL)
        *outDivisor = divisor;
    
    return saturationMatrix;
}

static int16_t *darkenTimestampMatrix(int32_t *outDivisor)
{
    static int16_t saturationMatrix[16];
    static const int32_t divisor = 256;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        CGFloat s = 1.7f;
        CGFloat offset = 0.0f;
        CGFloat factor = 1.1f;
        CGFloat satMatrix[] = {
            0.0722f + 0.9278f * s,  0.0722f - 0.0722f * s,  0.0722f - 0.0722f * s,  0,
            0.7152f - 0.7152f * s,  0.7152f + 0.2848f * s,  0.7152f - 0.7152f * s,  0,
            0.2126f - 0.2126f * s,  0.2126f - 0.2126f * s,  0.2126f + 0.7873f * s,  0,
            0.0f,                    0.0f,                    0.0f,  1,
        };
        CGFloat contrastMatrix[] = {
            factor, 0.0f, 0.0f, 0.0f,
            0.0f, factor, 0.0f, 0.0f,
            0.0f, 0.0f, factor, 0.0f,
            offset, offset, offset, 1.0f
        };
        CGFloat colorMatrix[16];
        matrixMul(satMatrix, contrastMatrix, colorMatrix);
        
        NSUInteger matrixSize = sizeof(colorMatrix) / sizeof(colorMatrix[0]);
        for (NSUInteger i = 0; i < matrixSize; ++i) {
            saturationMatrix[i] = (int16_t)roundf(colorMatrix[i] * divisor);
        }
    });
    
    if (outDivisor != NULL)
        *outDivisor = divisor;
    
    return saturationMatrix;
}

UIImage *TGAverageColorImage(UIColor *color)
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(1.0f, 1.0f), true, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, CGRectMake(0.0f, 0.0f, 1.0f, 1.0f));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

UIImage *TGAverageColorRoundImage(UIColor *color, CGSize size)
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(size.width, size.height), true, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, CGRectMake(0.0f, 0.0f, 1.0f, 1.0f));
    CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, size.width, size.height));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

UIImage *TGAverageColorAttachmentImage(UIColor *color)
{
    CGFloat scale = TGIsRetina() ? 2.0f : 1.0f;
    
    CGSize size = CGSizeMake(36.0f, 36.0f);
    
    const struct { int width, height; } targetContextSize = { (int)(size.width * scale), (int)(size.height * scale)};
    
    size_t targetBytesPerRow = ((4 * (int)targetContextSize.width) + 15) & (~15);
    
    void *targetMemory = malloc((int)(targetBytesPerRow * targetContextSize.height));
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Host;
    
    CGContextRef targetContext = CGBitmapContextCreate(targetMemory, (int)targetContextSize.width, (int)targetContextSize.height, 8, targetBytesPerRow, colorSpace, bitmapInfo);
    
    UIGraphicsPushContext(targetContext);
    CGContextTranslateCTM(targetContext, targetContextSize.width / 2.0f, targetContextSize.height / 2.0f);
    CGContextScaleCTM(targetContext, 1.0f, -1.0f);
    CGContextTranslateCTM(targetContext, -targetContextSize.width / 2.0f, -targetContextSize.height / 2.0f);
    CGContextScaleCTM(targetContext, scale, scale);
    
    CGColorSpaceRelease(colorSpace);
    
    CGContextSetBlendMode(targetContext, kCGBlendModeCopy);
    
    CGContextSetFillColorWithColor(targetContext, [color CGColor]);
    CGContextFillRect(targetContext, CGRectMake(0.0f, 0.0f, targetContextSize.width, targetContextSize.height));
    
    addAttachmentImageCorners(targetMemory, targetContextSize.width, targetContextSize.height, targetBytesPerRow);
    
    UIGraphicsPopContext();
    
    CGImageRef bitmapImage = CGBitmapContextCreateImage(targetContext);
    UIImage *image = [[[UIImage alloc] initWithCGImage:bitmapImage scale:scale orientation:UIImageOrientationUp] stretchableImageWithLeftCapWidth:(int)(targetContextSize.width / scale / 2) topCapHeight:(int)(targetContextSize.height / scale / 2)];
    CGImageRelease(bitmapImage);
    
    CGContextRelease(targetContext);
    free(targetMemory);
    
    /*CGFloat matrix[16];
    int32_t divisor = 256;
    int16_t *integerMatrix = brightenMatrix(&divisor);
    
    for (int i = 0; i < 16; i++)
    {
        matrix[i] = integerMatrix[i] / (CGFloat)divisor;
    }
    
    CGFloat vector[4];
    [color getRed:&vector[3] green:&vector[2] blue:&vector[1] alpha:&vector[0]];
    
    CGFloat resultColor[4];
    matrixVectorMul(matrix, vector, resultColor);
    
    UIImage *genericCircleImage = nil;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(50.0f, 50.0f), false, scale);
    CGContextRef circleContext = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(circleContext, [[UIColor alloc] initWithRed:vector[3] green:vector[2] blue:vector[1] alpha:vector[0]].CGColor);
    CGContextFillEllipseInRect(circleContext, CGRectMake(0.0f, 0.0f, 50.0f, 50.0f));
    genericCircleImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [image setActionCircleImage:genericCircleImage];*/
    
    return image;
}

static void modifyAndBlurImage(void *pixels, unsigned int width, unsigned int height, unsigned int stride, bool strongBlur, int16_t *matrix)
{
    unsigned int tempWidth = width / 6;
    unsigned int tempHeight = height / 6;
    unsigned int tempStride = ((4 * tempWidth + 15) & (~15));
    void *tempPixels = malloc(tempStride * tempHeight);
    
    vImage_Buffer srcBuffer;
    srcBuffer.width = width;
    srcBuffer.height = height;
    srcBuffer.rowBytes = stride;
    srcBuffer.data = pixels;
    
    vImage_Buffer dstBuffer;
    dstBuffer.width = tempWidth;
    dstBuffer.height = tempHeight;
    dstBuffer.rowBytes = tempStride;
    dstBuffer.data = tempPixels;
    
    vImageScale_ARGB8888(&srcBuffer, &dstBuffer, NULL, kvImageDoNotTile);
    
    fastBlurMore(tempWidth, tempHeight, tempStride, tempPixels);
    if (strongBlur)
        fastBlur(tempWidth, tempHeight, tempStride, tempPixels);
    
    int32_t divisor = 256;
    vImageMatrixMultiply_ARGB8888(&dstBuffer, &dstBuffer, matrix, divisor, NULL, NULL, kvImageDoNotTile);
    vImageScale_ARGB8888(&dstBuffer, &srcBuffer, NULL, kvImageDoNotTile);
    
    free(tempPixels);
}

static void brightenAndBlurImage(void *pixels, unsigned int width, unsigned int height, unsigned int stride, bool strongBlur)
{
    modifyAndBlurImage(pixels, width, height, stride, strongBlur, brightenMatrix(NULL));
}

TGStaticBackdropAreaData *createImageBackdropArea(uint8_t *sourceImageMemory, int sourceImageWidth, int sourceImageHeight, int sourceImageStride, CGSize originalSize, CGRect sourceImageRect)
{
    CGFloat scale = TGIsRetina() ? 2.0f : 1.0f;
    
    const struct { int width, height; } contextSize = { (int)(sourceImageRect.size.width / 2), (int)(sourceImageRect.size.height / 2) };
    size_t bytesPerRow = ((4 * (int)contextSize.width) + 15) & (~15);
    
    CGFloat scalingFactor = contextSize.width / sourceImageRect.size.width;
    
    void *memory = malloc((int)(bytesPerRow * contextSize.height));
    memset(memory, 0x00, (int)(bytesPerRow * contextSize.height));
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Host;
    CGContextRef context = CGBitmapContextCreate(memory, (int)contextSize.width, (int)contextSize.height, 8, bytesPerRow, colorSpace, bitmapInfo);
    CGColorSpaceRelease(colorSpace);
    UIGraphicsPushContext(context);
    
    CGContextTranslateCTM(context, contextSize.width / 2.0f, contextSize.height / 2.0f);
    CGContextScaleCTM(context, 1.0f, -1.0f);
    CGContextTranslateCTM(context, -contextSize.width / 2.0f, -contextSize.height / 2.0f);
    
    CGRect imageRect = CGRectMake(-sourceImageRect.origin.x * scalingFactor, -sourceImageRect.origin.y * scalingFactor, originalSize.width * scalingFactor, originalSize.height * scalingFactor);
    
    float luminance = 0.0f;
    float realLuminance = 0.0f;
    float variance = 0.0f;
    
    if (sourceImageMemory != NULL)
    {
        fastScaleImage(sourceImageMemory, sourceImageWidth, sourceImageHeight, sourceImageStride, memory, contextSize.width, contextSize.height, bytesPerRow, imageRect);
    }
    
    /*if (luminance > 0.8f)
        modifyAndBlurImage(memory, contextSize.width, contextSize.height, bytesPerRow, false, brightenTimestampMatrix(NULL));
    else
        modifyAndBlurImage(memory, contextSize.width, contextSize.height, bytesPerRow, false, darkenTimestampMatrix(NULL));*/
    
    fastBlur(contextSize.width, contextSize.height, bytesPerRow, memory);
    fastBlur(contextSize.width, contextSize.height, bytesPerRow, memory);
    computeImageVariance(memory, contextSize.width, contextSize.height, bytesPerRow, &variance, &luminance, &realLuminance);
    
    if ((variance >= 0.009f && realLuminance > 0.7f) || variance >= 0.05f)
    {
        uint32_t color = TGImageAverageColor(memory, contextSize.width, contextSize.height, bytesPerRow);
        //color = 0xff00ffff;
        CGContextSetFillColorWithColor(context, UIColorRGBA(color, 0.7f).CGColor);
        CGContextFillRect(context, CGRectMake(0, 0, contextSize.width, contextSize.height));
        
        uint32_t r = (color >> 16) & 0xff;
        uint32_t g = (color >> 8) & 0xff;
        uint32_t b = color & 0xff;
        
        uint32_t pixelLuminance = (uint8_t)((r * 299 + g * 587 + b * 114) / 1000);
        luminance = pixelLuminance / 255.0f;
        if (luminance < 0.85f)
            luminance = 0.0f;
    }
    
    CGImageRef bitmapImage = CGBitmapContextCreateImage(context);
    UIImage *image = [[UIImage alloc] initWithCGImage:bitmapImage scale:scale orientation:UIImageOrientationUp];
    CGImageRelease(bitmapImage);
    
    UIGraphicsPopContext();
    CFRelease(context);
    free(memory);
    
    TGStaticBackdropAreaData *backdropArea = [[TGStaticBackdropAreaData alloc] initWithBackground:image mappedRect:CGRectMake(sourceImageRect.origin.x / originalSize.width, sourceImageRect.origin.y / originalSize.height, sourceImageRect.size.width / originalSize.width, sourceImageRect.size.height / originalSize.height)];
    backdropArea.luminance = luminance;
    
    return backdropArea;
}

TGStaticBackdropAreaData *createTimestampBackdropArea(uint8_t *sourceImageMemory, int sourceImageWidth, int sourceImageHeight, int sourceImageStride, CGSize originalSize)
{
    const int extraRadius = 0.0f;
    const struct { int width, height; } unscaledSize = { 84 + extraRadius * 2, 18 };
    const struct { int right, bottom; } padding = { 6 - extraRadius, 6 };

    return createImageBackdropArea(sourceImageMemory, sourceImageWidth, sourceImageHeight, sourceImageStride, originalSize, CGRectMake(originalSize.width - padding.right - unscaledSize.width, originalSize.height - padding.bottom - unscaledSize.height, unscaledSize.width, unscaledSize.height));
}

TGStaticBackdropAreaData *createAdditionalDataBackdropArea(uint8_t *sourceImageMemory, int sourceImageWidth, int sourceImageHeight, int sourceImageStride, CGSize originalSize)
{
    const int extraRadius = 0.0f;
    const struct { int width, height; } unscaledSize = { 160 + extraRadius * 2, 18 };
    const struct { int left, top; } padding = { 6 - extraRadius, 6 };
    
    return createImageBackdropArea(sourceImageMemory, sourceImageWidth, sourceImageHeight, sourceImageStride, originalSize, CGRectMake(padding.left, padding.top, unscaledSize.width, unscaledSize.height));
}

UIImage *TGBlurredAttachmentImage(UIImage *source, CGSize size, uint32_t *averageColor)
{
    CGFloat scale = TGIsRetina() ? 2.0f : 1.0f;
    
    CGSize fittedSize = fitSize(size, CGSizeMake(90, 90));
    
    CGFloat actionCircleDiameter = 50.0f;
    
    const struct { int width, height; } blurredContextSize = { (int)fittedSize.width, (int)fittedSize.height };
    const struct { int width, height; } targetContextSize = { (int)(size.width * scale), (int)(size.height * scale)};
    const struct { int width, height; } actionCircleContextSize = { (int)(actionCircleDiameter * scale), (int)(actionCircleDiameter * scale) };
    
    size_t blurredBytesPerRow = ((4 * (int)blurredContextSize.width) + 15) & (~15);
    size_t targetBytesPerRow = ((4 * (int)targetContextSize.width) + 15) & (~15);
    size_t actionCircleBytesPerRow = ((4 * (int)actionCircleContextSize.width) + 15) & (~15);
    
    void *blurredMemory = malloc((int)(blurredBytesPerRow * blurredContextSize.height));
    void *targetMemory = malloc((int)(targetBytesPerRow * targetContextSize.height));
    void *actionCircleMemory = malloc(((int)(actionCircleBytesPerRow * actionCircleContextSize.height)));
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Host;
    
    CGContextRef blurredContext = CGBitmapContextCreate(blurredMemory, (int)blurredContextSize.width, (int)blurredContextSize.height, 8, blurredBytesPerRow, colorSpace, bitmapInfo);
    CGContextRef targetContext = CGBitmapContextCreate(targetMemory, (int)targetContextSize.width, (int)targetContextSize.height, 8, targetBytesPerRow, colorSpace, bitmapInfo);
    CGContextRef actionCircleContext = CGBitmapContextCreate(actionCircleMemory, (int)actionCircleContextSize.width, (int)actionCircleContextSize.height, 8, actionCircleBytesPerRow, colorSpace, bitmapInfo);
    
    CGColorSpaceRelease(colorSpace);
    
    UIGraphicsPushContext(blurredContext);
    CGContextTranslateCTM(blurredContext, blurredContextSize.width / 2.0f, blurredContextSize.height / 2.0f);
    CGContextScaleCTM(blurredContext, 1.0f, -1.0f);
    CGContextTranslateCTM(blurredContext, -blurredContextSize.width / 2.0f, -blurredContextSize.height / 2.0f);
    CGContextSetInterpolationQuality(blurredContext, kCGInterpolationLow);
    [source drawInRect:CGRectMake(0, 0, blurredContextSize.width, blurredContextSize.height) blendMode:kCGBlendModeCopy alpha:1.0f];
    UIGraphicsPopContext();
    
    fastBlur((int)blurredContextSize.width, (int)blurredContextSize.height, blurredBytesPerRow, blurredMemory);
    
    if (averageColor != NULL)
        *averageColor = TGImageAverageColor(blurredMemory, blurredContextSize.width, blurredContextSize.height, blurredBytesPerRow);
    
    vImage_Buffer srcBuffer;
    srcBuffer.width = blurredContextSize.width;
    srcBuffer.height = blurredContextSize.height;
    srcBuffer.rowBytes = blurredBytesPerRow;
    srcBuffer.data = blurredMemory;
    
    vImage_Buffer dstBuffer;
    dstBuffer.width = targetContextSize.width;
    dstBuffer.height = targetContextSize.height;
    dstBuffer.rowBytes = targetBytesPerRow;
    dstBuffer.data = targetMemory;
    
    vImageScale_ARGB8888(&srcBuffer, &dstBuffer, NULL, kvImageDoNotTile);
    
    CGContextRelease(blurredContext);
    free(blurredMemory);
    
    UIGraphicsPushContext(actionCircleContext);
    CGContextTranslateCTM(actionCircleContext, actionCircleContextSize.width / 2.0f, actionCircleContextSize.height / 2.0f);
    CGContextScaleCTM(actionCircleContext, 1.0f, -1.0f);
    CGContextTranslateCTM(actionCircleContext, -actionCircleContextSize.width / 2.0f, -actionCircleContextSize.height / 2.0f);
    
    CGContextSetInterpolationQuality(actionCircleContext, kCGInterpolationLow);
    CGContextSetBlendMode(actionCircleContext, kCGBlendModeCopy);
    
    [source drawInRect:CGRectMake((actionCircleContextSize.width - targetContextSize.width) / 2.0f, (actionCircleContextSize.height - targetContextSize.height) / 2.0f, targetContextSize.width, targetContextSize.height) blendMode:kCGBlendModeCopy alpha:1.0f];
    UIGraphicsPopContext();
    
    brightenAndBlurImage(actionCircleMemory, actionCircleContextSize.width, actionCircleContextSize.height, actionCircleBytesPerRow, scale < 2);
    
    CGContextBeginPath(actionCircleContext);
    CGContextAddRect(actionCircleContext, CGRectMake(0.0f, 0.0f, actionCircleContextSize.width, actionCircleContextSize.height));
    CGContextAddEllipseInRect(actionCircleContext, CGRectMake(0.0f, 0.0f, actionCircleContextSize.width, actionCircleContextSize.height));
    CGContextClosePath(actionCircleContext);
    
    CGContextSetFillColorWithColor(actionCircleContext, [UIColor clearColor].CGColor);
    CGContextEOFillPath(actionCircleContext);
    
    CGImageRef actionCircleBitmapImage = CGBitmapContextCreateImage(actionCircleContext);
    UIImage *actionCircleImage = [[UIImage alloc] initWithCGImage:actionCircleBitmapImage scale:scale orientation:UIImageOrientationUp];
    CGImageRelease(actionCircleBitmapImage);
    
    CGContextRelease(actionCircleContext);
    free(actionCircleMemory);
    
    TGStaticBackdropAreaData *timestampBackdropArea = createTimestampBackdropArea(targetMemory, targetContextSize.width, targetContextSize.height, targetBytesPerRow, CGSizeMake(size.width, size.height));
    TGStaticBackdropAreaData *additionalDataBackdropArea = createAdditionalDataBackdropArea(targetMemory, targetContextSize.width, targetContextSize.height, targetBytesPerRow, CGSizeMake(size.width, size.height));
    
    addAttachmentImageCorners(targetMemory, targetContextSize.width, targetContextSize.height, targetBytesPerRow);
    
    CGImageRef bitmapImage = CGBitmapContextCreateImage(targetContext);
    UIImage *image = [[UIImage alloc] initWithCGImage:bitmapImage];
    CGImageRelease(bitmapImage);
    
    CGContextRelease(targetContext);
    free(targetMemory);
    
    TGStaticBackdropImageData *backdropData = [[TGStaticBackdropImageData alloc] init];
    [backdropData setBackdropArea:[[TGStaticBackdropAreaData alloc] initWithBackground:actionCircleImage] forKey:TGStaticBackdropMessageActionCircle];
    
    [backdropData setBackdropArea:timestampBackdropArea forKey:TGStaticBackdropMessageTimestamp];
    [backdropData setBackdropArea:additionalDataBackdropArea forKey:TGStaticBackdropMessageAdditionalData];
    
    [image setStaticBackdropImageData:backdropData];
    
    return image;
}

UIImage *TGSecretBlurredAttachmentImage(UIImage *source, CGSize size, uint32_t *averageColor)
{
    CGFloat scale = TGIsRetina() ? 2.0f : 1.0f;
    
    CGSize fittedSize = fitSize(size, CGSizeMake(64, 64));
    
    CGFloat actionCircleDiameter = 50.0f;
    
    const struct { int width, height; } blurredContextSize = { (int)fittedSize.width, (int)fittedSize.height };
    const struct { int width, height; } targetContextSize = { (int)(size.width * scale), (int)(size.height * scale)};
    const struct { int width, height; } actionCircleContextSize = { (int)(actionCircleDiameter * scale), (int)(actionCircleDiameter * scale) };
    
    size_t blurredBytesPerRow = ((4 * (int)blurredContextSize.width) + 15) & (~15);
    size_t targetBytesPerRow = ((4 * (int)targetContextSize.width) + 15) & (~15);
    size_t actionCircleBytesPerRow = ((4 * (int)actionCircleContextSize.width) + 15) & (~15);
    
    void *blurredMemory = malloc((int)(blurredBytesPerRow * blurredContextSize.height));
    void *targetMemory = malloc((int)(targetBytesPerRow * targetContextSize.height));
    void *actionCircleMemory = malloc(((int)(actionCircleBytesPerRow * actionCircleContextSize.height)));
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Host;
    
    CGContextRef blurredContext = CGBitmapContextCreate(blurredMemory, (int)blurredContextSize.width, (int)blurredContextSize.height, 8, blurredBytesPerRow, colorSpace, bitmapInfo);
    CGContextRef targetContext = CGBitmapContextCreate(targetMemory, (int)targetContextSize.width, (int)targetContextSize.height, 8, targetBytesPerRow, colorSpace, bitmapInfo);
    CGContextRef actionCircleContext = CGBitmapContextCreate(actionCircleMemory, (int)actionCircleContextSize.width, (int)actionCircleContextSize.height, 8, actionCircleBytesPerRow, colorSpace, bitmapInfo);
    
    CGColorSpaceRelease(colorSpace);
    
    UIGraphicsPushContext(blurredContext);
    CGContextTranslateCTM(blurredContext, blurredContextSize.width / 2.0f, blurredContextSize.height / 2.0f);
    CGContextScaleCTM(blurredContext, 1.0f, -1.0f);
    CGContextTranslateCTM(blurredContext, -blurredContextSize.width / 2.0f, -blurredContextSize.height / 2.0f);
    CGContextSetInterpolationQuality(blurredContext, kCGInterpolationLow);
    [source drawInRect:CGRectMake(0, 0, blurredContextSize.width, blurredContextSize.height) blendMode:kCGBlendModeCopy alpha:1.0f];
    UIGraphicsPopContext();
    
    fastBlur((int)blurredContextSize.width, (int)blurredContextSize.height, blurredBytesPerRow, blurredMemory);
    
    if (averageColor != NULL)
        *averageColor = TGImageAverageColor(blurredMemory, blurredContextSize.width, blurredContextSize.height, blurredBytesPerRow);
    
    vImage_Buffer srcBuffer;
    srcBuffer.width = blurredContextSize.width;
    srcBuffer.height = blurredContextSize.height;
    srcBuffer.rowBytes = blurredBytesPerRow;
    srcBuffer.data = blurredMemory;
    
    vImage_Buffer dstBuffer;
    dstBuffer.width = targetContextSize.width;
    dstBuffer.height = targetContextSize.height;
    dstBuffer.rowBytes = targetBytesPerRow;
    dstBuffer.data = targetMemory;
    
    vImageScale_ARGB8888(&srcBuffer, &dstBuffer, NULL, kvImageDoNotTile);
    
    CGContextRelease(blurredContext);
    free(blurredMemory);
    
    UIGraphicsPushContext(actionCircleContext);
    CGContextTranslateCTM(actionCircleContext, actionCircleContextSize.width / 2.0f, actionCircleContextSize.height / 2.0f);
    CGContextScaleCTM(actionCircleContext, 1.0f, -1.0f);
    CGContextTranslateCTM(actionCircleContext, -actionCircleContextSize.width / 2.0f, -actionCircleContextSize.height / 2.0f);
    
    CGContextSetInterpolationQuality(actionCircleContext, kCGInterpolationLow);
    CGContextSetBlendMode(actionCircleContext, kCGBlendModeCopy);
    
    [source drawInRect:CGRectMake((actionCircleContextSize.width - targetContextSize.width) / 2.0f, (actionCircleContextSize.height - targetContextSize.height) / 2.0f, targetContextSize.width, targetContextSize.height) blendMode:kCGBlendModeCopy alpha:1.0f];
    UIGraphicsPopContext();
    
    brightenAndBlurImage(actionCircleMemory, actionCircleContextSize.width, actionCircleContextSize.height, actionCircleBytesPerRow, scale < 2);
    
    CGContextBeginPath(actionCircleContext);
    CGContextAddRect(actionCircleContext, CGRectMake(0.0f, 0.0f, actionCircleContextSize.width, actionCircleContextSize.height));
    CGContextAddEllipseInRect(actionCircleContext, CGRectMake(0.0f, 0.0f, actionCircleContextSize.width, actionCircleContextSize.height));
    CGContextClosePath(actionCircleContext);
    
    CGContextSetFillColorWithColor(actionCircleContext, [UIColor clearColor].CGColor);
    CGContextEOFillPath(actionCircleContext);
    
    CGImageRef actionCircleBitmapImage = CGBitmapContextCreateImage(actionCircleContext);
    UIImage *actionCircleImage = [[UIImage alloc] initWithCGImage:actionCircleBitmapImage scale:scale orientation:UIImageOrientationUp];
    CGImageRelease(actionCircleBitmapImage);
    
    CGContextRelease(actionCircleContext);
    free(actionCircleMemory);
    
    TGStaticBackdropAreaData *timestampBackdropArea = createTimestampBackdropArea(targetMemory, targetContextSize.width, targetContextSize.height, targetBytesPerRow, CGSizeMake(size.width, size.height));
    TGStaticBackdropAreaData *additionalDataBackdropArea = createAdditionalDataBackdropArea(targetMemory, targetContextSize.width, targetContextSize.height, targetBytesPerRow, CGSizeMake(size.width, size.height));
    
    addAttachmentImageCorners(targetMemory, targetContextSize.width, targetContextSize.height, targetBytesPerRow);
    
    CGImageRef bitmapImage = CGBitmapContextCreateImage(targetContext);
    UIImage *image = [[UIImage alloc] initWithCGImage:bitmapImage];
    CGImageRelease(bitmapImage);
    
    CGContextRelease(targetContext);
    free(targetMemory);
    
    TGStaticBackdropImageData *backdropData = [[TGStaticBackdropImageData alloc] init];
    [backdropData setBackdropArea:[[TGStaticBackdropAreaData alloc] initWithBackground:actionCircleImage] forKey:TGStaticBackdropMessageActionCircle];
    
    [backdropData setBackdropArea:timestampBackdropArea forKey:TGStaticBackdropMessageTimestamp];
    [backdropData setBackdropArea:additionalDataBackdropArea forKey:TGStaticBackdropMessageAdditionalData];
    
    [image setStaticBackdropImageData:backdropData];
    
    return image;
}

UIImage *TGBlurredFileImage(UIImage *source, CGSize size, uint32_t *averageColor)
{
    CGFloat scale = TGIsRetina() ? 2.0f : 1.0f;
    
    CGSize fittedSize = fitSize(size, CGSizeMake(90, 90));
    
    CGFloat actionCircleDiameter = 50.0f;
    
    const struct { int width, height; } blurredContextSize = { (int)fittedSize.width, (int)fittedSize.height };
    const struct { int width, height; } targetContextSize = { (int)(size.width * scale), (int)(size.height * scale)};
    const struct { int width, height; } actionCircleContextSize = { (int)(actionCircleDiameter * scale), (int)(actionCircleDiameter * scale) };
    
    size_t blurredBytesPerRow = ((4 * (int)blurredContextSize.width) + 15) & (~15);
    size_t targetBytesPerRow = ((4 * (int)targetContextSize.width) + 15) & (~15);
    size_t actionCircleBytesPerRow = ((4 * (int)actionCircleContextSize.width) + 15) & (~15);
    
    void *blurredMemory = malloc((int)(blurredBytesPerRow * blurredContextSize.height));
    void *targetMemory = malloc((int)(targetBytesPerRow * targetContextSize.height));
    void *actionCircleMemory = malloc(((int)(actionCircleBytesPerRow * actionCircleContextSize.height)));
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Host;
    
    CGContextRef blurredContext = CGBitmapContextCreate(blurredMemory, (int)blurredContextSize.width, (int)blurredContextSize.height, 8, blurredBytesPerRow, colorSpace, bitmapInfo);
    CGContextRef targetContext = CGBitmapContextCreate(targetMemory, (int)targetContextSize.width, (int)targetContextSize.height, 8, targetBytesPerRow, colorSpace, bitmapInfo);
    CGContextRef actionCircleContext = CGBitmapContextCreate(actionCircleMemory, (int)actionCircleContextSize.width, (int)actionCircleContextSize.height, 8, actionCircleBytesPerRow, colorSpace, bitmapInfo);
    
    CGColorSpaceRelease(colorSpace);
    
    UIGraphicsPushContext(blurredContext);
    CGContextTranslateCTM(blurredContext, blurredContextSize.width / 2.0f, blurredContextSize.height / 2.0f);
    CGContextScaleCTM(blurredContext, 1.0f, -1.0f);
    CGContextTranslateCTM(blurredContext, -blurredContextSize.width / 2.0f, -blurredContextSize.height / 2.0f);
    CGContextSetInterpolationQuality(blurredContext, kCGInterpolationLow);
    [source drawInRect:CGRectMake(0, 0, blurredContextSize.width, blurredContextSize.height) blendMode:kCGBlendModeCopy alpha:1.0f];
    UIGraphicsPopContext();
    
    fastBlur((int)blurredContextSize.width, (int)blurredContextSize.height, blurredBytesPerRow, blurredMemory);
    
    if (averageColor != NULL)
        *averageColor = TGImageAverageColor(blurredMemory, blurredContextSize.width, blurredContextSize.height, blurredBytesPerRow);
    
    vImage_Buffer srcBuffer;
    srcBuffer.width = blurredContextSize.width;
    srcBuffer.height = blurredContextSize.height;
    srcBuffer.rowBytes = blurredBytesPerRow;
    srcBuffer.data = blurredMemory;
    
    vImage_Buffer dstBuffer;
    dstBuffer.width = targetContextSize.width;
    dstBuffer.height = targetContextSize.height;
    dstBuffer.rowBytes = targetBytesPerRow;
    dstBuffer.data = targetMemory;
    
    vImageScale_ARGB8888(&srcBuffer, &dstBuffer, NULL, kvImageDoNotTile);
    
    CGContextRelease(blurredContext);
    free(blurredMemory);
    
    UIGraphicsPushContext(actionCircleContext);
    CGContextTranslateCTM(actionCircleContext, actionCircleContextSize.width / 2.0f, actionCircleContextSize.height / 2.0f);
    CGContextScaleCTM(actionCircleContext, 1.0f, -1.0f);
    CGContextTranslateCTM(actionCircleContext, -actionCircleContextSize.width / 2.0f, -actionCircleContextSize.height / 2.0f);
    
    CGContextSetInterpolationQuality(actionCircleContext, kCGInterpolationLow);
    CGContextSetBlendMode(actionCircleContext, kCGBlendModeCopy);
    
    [source drawInRect:CGRectMake((actionCircleContextSize.width - targetContextSize.width) / 2.0f, (actionCircleContextSize.height - targetContextSize.height) / 2.0f, targetContextSize.width, targetContextSize.height) blendMode:kCGBlendModeCopy alpha:1.0f];
    UIGraphicsPopContext();
    
    brightenAndBlurImage(actionCircleMemory, actionCircleContextSize.width, actionCircleContextSize.height, actionCircleBytesPerRow, scale < 2);
    
    CGContextBeginPath(actionCircleContext);
    CGContextAddRect(actionCircleContext, CGRectMake(0.0f, 0.0f, actionCircleContextSize.width, actionCircleContextSize.height));
    CGContextAddEllipseInRect(actionCircleContext, CGRectMake(0.0f, 0.0f, actionCircleContextSize.width, actionCircleContextSize.height));
    CGContextClosePath(actionCircleContext);
    
    CGContextSetFillColorWithColor(actionCircleContext, [UIColor clearColor].CGColor);
    CGContextEOFillPath(actionCircleContext);
    
    CGImageRef actionCircleBitmapImage = CGBitmapContextCreateImage(actionCircleContext);
    UIImage *actionCircleImage = [[UIImage alloc] initWithCGImage:actionCircleBitmapImage scale:scale orientation:UIImageOrientationUp];
    CGImageRelease(actionCircleBitmapImage);
    
    CGContextRelease(actionCircleContext);
    free(actionCircleMemory);
    
    TGStaticBackdropAreaData *timestampBackdropArea = createTimestampBackdropArea(targetMemory, targetContextSize.width, targetContextSize.height, targetBytesPerRow, CGSizeMake(size.width, size.height));
    TGStaticBackdropAreaData *additionalDataBackdropArea = createAdditionalDataBackdropArea(targetMemory, targetContextSize.width, targetContextSize.height, targetBytesPerRow, CGSizeMake(size.width, size.height));
    
    CGImageRef bitmapImage = CGBitmapContextCreateImage(targetContext);
    UIImage *image = [[UIImage alloc] initWithCGImage:bitmapImage];
    CGImageRelease(bitmapImage);
    
    CGContextRelease(targetContext);
    free(targetMemory);
    
    TGStaticBackdropImageData *backdropData = [[TGStaticBackdropImageData alloc] init];
    [backdropData setBackdropArea:[[TGStaticBackdropAreaData alloc] initWithBackground:actionCircleImage] forKey:TGStaticBackdropMessageActionCircle];
    
    [backdropData setBackdropArea:timestampBackdropArea forKey:TGStaticBackdropMessageTimestamp];
    [backdropData setBackdropArea:additionalDataBackdropArea forKey:TGStaticBackdropMessageAdditionalData];
    
    [image setStaticBackdropImageData:backdropData];
    
    return image;
}

UIImage *TGLoadedAttachmentImage(UIImage *source, CGSize size, uint32_t *averageColor)
{
    CGFloat scale = TGIsRetina() ? 2.0f : 1.0f;
    
    CGFloat actionCircleDiameter = 50.0f;
    
    const struct { int width, height; } targetContextSize = { (int)(size.width * scale), (int)(size.height * scale) };
    const struct { int width, height; } actionCircleContextSize = { (int)(actionCircleDiameter * scale), (int)(actionCircleDiameter * scale) };
    
    size_t targetBytesPerRow = ((4 * (int)targetContextSize.width) + 15) & (~15);
    size_t actionCircleBytesPerRow = ((4 * (int)actionCircleContextSize.width) + 15) & (~15);
    
    void *targetMemory = malloc((int)(targetBytesPerRow * targetContextSize.height));
    void *actionCircleMemory = malloc(((int)(actionCircleBytesPerRow * actionCircleContextSize.height)));
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Host;
    
    CGContextRef targetContext = CGBitmapContextCreate(targetMemory, (int)targetContextSize.width, (int)targetContextSize.height, 8, targetBytesPerRow, colorSpace, bitmapInfo);
    CGContextRef actionCircleContext = CGBitmapContextCreate(actionCircleMemory, (int)actionCircleContextSize.width, (int)actionCircleContextSize.height, 8, actionCircleBytesPerRow, colorSpace, bitmapInfo);
    
    CGColorSpaceRelease(colorSpace);
    
    UIGraphicsPushContext(actionCircleContext);
    CGContextTranslateCTM(actionCircleContext, actionCircleContextSize.width / 2.0f, actionCircleContextSize.height / 2.0f);
    CGContextScaleCTM(actionCircleContext, 1.0f, -1.0f);
    CGContextTranslateCTM(actionCircleContext, -actionCircleContextSize.width / 2.0f, -actionCircleContextSize.height / 2.0f);
    CGContextSetInterpolationQuality(actionCircleContext, kCGInterpolationLow);
    CGContextSetBlendMode(actionCircleContext, kCGBlendModeCopy);
    
    [source drawInRect:CGRectMake((actionCircleContextSize.width - targetContextSize.width) / 2.0f, (actionCircleContextSize.height - targetContextSize.height) / 2.0f, targetContextSize.width, targetContextSize.height) blendMode:kCGBlendModeCopy alpha:1.0f];
    brightenAndBlurImage(actionCircleMemory, actionCircleContextSize.width, actionCircleContextSize.height, actionCircleBytesPerRow, true);
    
    CGContextBeginPath(actionCircleContext);
    CGContextAddRect(actionCircleContext, CGRectMake(0.0f, 0.0f, actionCircleContextSize.width, actionCircleContextSize.height));
    CGContextAddEllipseInRect(actionCircleContext, CGRectMake(0.0f, 0.0f, actionCircleContextSize.width, actionCircleContextSize.height));
    CGContextClosePath(actionCircleContext);
    
    CGContextSetFillColorWithColor(actionCircleContext, [UIColor clearColor].CGColor);
    CGContextEOFillPath(actionCircleContext);
    
    UIGraphicsPopContext();
    
    CGImageRef actionCircleBitmapImage = CGBitmapContextCreateImage(actionCircleContext);
    UIImage *actionCircleImage = [[UIImage alloc] initWithCGImage:actionCircleBitmapImage scale:scale orientation:UIImageOrientationUp];
    CGImageRelease(actionCircleBitmapImage);
    
    CGContextRelease(actionCircleContext);
    free(actionCircleMemory);
    
    UIGraphicsPushContext(targetContext);
    CGContextTranslateCTM(targetContext, targetContextSize.width / 2.0f, targetContextSize.height / 2.0f);
    CGContextScaleCTM(targetContext, 1.0f, -1.0f);
    CGContextTranslateCTM(targetContext, -targetContextSize.width / 2.0f, -targetContextSize.height / 2.0f);
    [source drawInRect:CGRectMake(0, 0, targetContextSize.width, targetContextSize.height) blendMode:kCGBlendModeCopy alpha:1.0f];
    UIGraphicsPopContext();
    
    if (averageColor != NULL)
        *averageColor = TGImageAverageColor(targetMemory, targetContextSize.width, targetContextSize.height, targetBytesPerRow);
    
    TGStaticBackdropAreaData *timestampBackdropArea = createTimestampBackdropArea(targetMemory, targetContextSize.width, targetContextSize.height, targetBytesPerRow, CGSizeMake(size.width, size.height));
    TGStaticBackdropAreaData *additionalDataBackdropArea = createAdditionalDataBackdropArea(targetMemory, targetContextSize.width, targetContextSize.height, targetBytesPerRow, CGSizeMake(size.width, size.height));
    
    addAttachmentImageCorners(targetMemory, targetContextSize.width, targetContextSize.height, targetBytesPerRow);
    
    CGImageRef bitmapImage = CGBitmapContextCreateImage(targetContext);
    UIImage *image = [[UIImage alloc] initWithCGImage:bitmapImage scale:scale orientation:UIImageOrientationUp];
    CGImageRelease(bitmapImage);
    
    CGContextRelease(targetContext);
    free(targetMemory);
    
    TGStaticBackdropImageData *backdropData = [[TGStaticBackdropImageData alloc] init];
    [backdropData setBackdropArea:[[TGStaticBackdropAreaData alloc] initWithBackground:actionCircleImage] forKey:TGStaticBackdropMessageActionCircle];
    
    [backdropData setBackdropArea:timestampBackdropArea forKey:TGStaticBackdropMessageTimestamp];
    [backdropData setBackdropArea:additionalDataBackdropArea forKey:TGStaticBackdropMessageAdditionalData];
    
    [image setStaticBackdropImageData:backdropData];
    
    return image;
}

UIImage *TGAnimationFrameAttachmentImage(UIImage *source, CGSize size)
{
    CGFloat scale = TGIsRetina() ? 2.0f : 1.0f;
    
    const struct { int width, height; } targetContextSize = { (int)(size.width * scale), (int)(size.height * scale) };
    
    size_t targetBytesPerRow = ((4 * (int)targetContextSize.width) + 15) & (~15);
    
    void *targetMemory = malloc((int)(targetBytesPerRow * targetContextSize.height));
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Host;
    
    CGContextRef targetContext = CGBitmapContextCreate(targetMemory, (int)targetContextSize.width, (int)targetContextSize.height, 8, targetBytesPerRow, colorSpace, bitmapInfo);
    
    CGColorSpaceRelease(colorSpace);
    
    UIGraphicsPushContext(targetContext);
    CGContextTranslateCTM(targetContext, targetContextSize.width / 2.0f, targetContextSize.height / 2.0f);
    CGContextScaleCTM(targetContext, 1.0f, -1.0f);
    CGContextTranslateCTM(targetContext, -targetContextSize.width / 2.0f, -targetContextSize.height / 2.0f);
    
    CGContextSetFillColorWithColor(targetContext, [UIColor blackColor].CGColor);
    CGContextFillRect(targetContext, CGRectMake(0, 0, targetContextSize.width, targetContextSize.height));
    [source drawInRect:CGRectMake(0, 0, targetContextSize.width, targetContextSize.height) blendMode:kCGBlendModeNormal alpha:1.0f];
    UIGraphicsPopContext();
    
    addAttachmentImageCorners(targetMemory, targetContextSize.width, targetContextSize.height, targetBytesPerRow);
    
    CGImageRef bitmapImage = CGBitmapContextCreateImage(targetContext);
    UIImage *image = [[UIImage alloc] initWithCGImage:bitmapImage scale:scale orientation:UIImageOrientationUp];
    CGImageRelease(bitmapImage);
    
    CGContextRelease(targetContext);
    free(targetMemory);
    
    return image;
}

UIImage *TGLoadedFileImage(UIImage *source, CGSize size, uint32_t *averageColor)
{
    CGFloat scale = TGIsRetina() ? 2.0f : 1.0f;
    
    CGFloat actionCircleDiameter = 50.0f;
    
    const struct { int width, height; } targetContextSize = { (int)(size.width * scale), (int)(size.height * scale) };
    const struct { int width, height; } actionCircleContextSize = { (int)(actionCircleDiameter * scale), (int)(actionCircleDiameter * scale) };
    
    size_t targetBytesPerRow = ((4 * (int)targetContextSize.width) + 15) & (~15);
    size_t actionCircleBytesPerRow = ((4 * (int)actionCircleContextSize.width) + 15) & (~15);
    
    void *targetMemory = malloc((int)(targetBytesPerRow * targetContextSize.height));
    void *actionCircleMemory = malloc(((int)(actionCircleBytesPerRow * actionCircleContextSize.height)));
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Host;
    
    CGContextRef targetContext = CGBitmapContextCreate(targetMemory, (int)targetContextSize.width, (int)targetContextSize.height, 8, targetBytesPerRow, colorSpace, bitmapInfo);
    CGContextRef actionCircleContext = CGBitmapContextCreate(actionCircleMemory, (int)actionCircleContextSize.width, (int)actionCircleContextSize.height, 8, actionCircleBytesPerRow, colorSpace, bitmapInfo);
    
    CGColorSpaceRelease(colorSpace);
    
    UIGraphicsPushContext(actionCircleContext);
    CGContextTranslateCTM(actionCircleContext, actionCircleContextSize.width / 2.0f, actionCircleContextSize.height / 2.0f);
    CGContextScaleCTM(actionCircleContext, 1.0f, -1.0f);
    CGContextTranslateCTM(actionCircleContext, -actionCircleContextSize.width / 2.0f, -actionCircleContextSize.height / 2.0f);
    CGContextSetInterpolationQuality(actionCircleContext, kCGInterpolationLow);
    CGContextSetBlendMode(actionCircleContext, kCGBlendModeCopy);
    
    [source drawInRect:CGRectMake((actionCircleContextSize.width - targetContextSize.width) / 2.0f, (actionCircleContextSize.height - targetContextSize.height) / 2.0f, targetContextSize.width, targetContextSize.height) blendMode:kCGBlendModeCopy alpha:1.0f];
    brightenAndBlurImage(actionCircleMemory, actionCircleContextSize.width, actionCircleContextSize.height, actionCircleBytesPerRow, true);
    
    CGContextBeginPath(actionCircleContext);
    CGContextAddRect(actionCircleContext, CGRectMake(0.0f, 0.0f, actionCircleContextSize.width, actionCircleContextSize.height));
    CGContextAddEllipseInRect(actionCircleContext, CGRectMake(0.0f, 0.0f, actionCircleContextSize.width, actionCircleContextSize.height));
    CGContextClosePath(actionCircleContext);
    
    CGContextSetFillColorWithColor(actionCircleContext, [UIColor clearColor].CGColor);
    CGContextEOFillPath(actionCircleContext);
    
    UIGraphicsPopContext();
    
    CGImageRef actionCircleBitmapImage = CGBitmapContextCreateImage(actionCircleContext);
    UIImage *actionCircleImage = [[UIImage alloc] initWithCGImage:actionCircleBitmapImage scale:scale orientation:UIImageOrientationUp];
    CGImageRelease(actionCircleBitmapImage);
    
    CGContextRelease(actionCircleContext);
    free(actionCircleMemory);
    
    UIGraphicsPushContext(targetContext);
    CGContextTranslateCTM(targetContext, targetContextSize.width / 2.0f, targetContextSize.height / 2.0f);
    CGContextScaleCTM(targetContext, 1.0f, -1.0f);
    CGContextTranslateCTM(targetContext, -targetContextSize.width / 2.0f, -targetContextSize.height / 2.0f);
    [source drawInRect:CGRectMake(0, 0, targetContextSize.width, targetContextSize.height) blendMode:kCGBlendModeCopy alpha:1.0f];
    UIGraphicsPopContext();
    
    if (averageColor != NULL)
        *averageColor = TGImageAverageColor(targetMemory, targetContextSize.width, targetContextSize.height, targetBytesPerRow);
    
    TGStaticBackdropAreaData *timestampBackdropArea = createTimestampBackdropArea(targetMemory, targetContextSize.width, targetContextSize.height, targetBytesPerRow, CGSizeMake(size.width, size.height));
    TGStaticBackdropAreaData *additionalDataBackdropArea = createAdditionalDataBackdropArea(targetMemory, targetContextSize.width, targetContextSize.height, targetBytesPerRow, CGSizeMake(size.width, size.height));
    
    CGImageRef bitmapImage = CGBitmapContextCreateImage(targetContext);
    UIImage *image = [[UIImage alloc] initWithCGImage:bitmapImage scale:scale orientation:UIImageOrientationUp];
    CGImageRelease(bitmapImage);
    
    CGContextRelease(targetContext);
    free(targetMemory);
    
    TGStaticBackdropImageData *backdropData = [[TGStaticBackdropImageData alloc] init];
    [backdropData setBackdropArea:[[TGStaticBackdropAreaData alloc] initWithBackground:actionCircleImage] forKey:TGStaticBackdropMessageActionCircle];
    
    [backdropData setBackdropArea:timestampBackdropArea forKey:TGStaticBackdropMessageTimestamp];
    [backdropData setBackdropArea:additionalDataBackdropArea forKey:TGStaticBackdropMessageAdditionalData];
    
    [image setStaticBackdropImageData:backdropData];
    
    return image;
}

UIImage *TGReducedAttachmentImage(UIImage *source, CGSize originalSize)
{
    CGFloat scale = TGIsRetina() ? 2.0f : 1.0f;
    
    CGSize size = CGSizeMake(CGFloor(originalSize.width * 0.4f), CGFloor(originalSize.height * 0.4f));
    
    const struct { int width, height; } targetContextSize = { (int)(size.width * scale), (int)(size.height * scale) };
    const struct { int width, height; } targetContextOriginalSize = { (int)(originalSize.width * scale), (int)(originalSize.height * scale) };
    
    CGFloat padding = 32.0f;
    CGFloat scaledWidth = targetContextOriginalSize.width / ((targetContextOriginalSize.width - padding * 2.0f) / (targetContextSize.width - padding * 2.0f));
    CGFloat scaledHeight = targetContextOriginalSize.height / ((targetContextOriginalSize.height - padding * 2.0f) / (targetContextSize.height - padding * 2.0f));
    
    size_t targetBytesPerRow = ((4 * (int)targetContextSize.width) + 15) & (~15);
    
    void *targetMemory = malloc((int)(targetBytesPerRow * targetContextSize.height));
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Host;
    CGContextRef targetContext = CGBitmapContextCreate(targetMemory, (int)targetContextSize.width, (int)targetContextSize.height, 8, targetBytesPerRow, colorSpace, bitmapInfo);
    CGColorSpaceRelease(colorSpace);
    
    UIGraphicsPushContext(targetContext);
    
    CGContextSetInterpolationQuality(targetContext, kCGInterpolationMedium);
    
    CGContextSetFillColorWithColor(targetContext, [UIColor grayColor].CGColor);
    CGContextFillRect(targetContext, CGRectMake(0.0f, 0.0, targetContextSize.width, targetContextSize.height));
    
    CGContextTranslateCTM(targetContext, targetContextSize.width / 2.0f, targetContextSize.height / 2.0f);
    CGContextScaleCTM(targetContext, 1.0f, -1.0f);
    CGContextTranslateCTM(targetContext, -targetContextSize.width / 2.0f, -targetContextSize.height / 2.0f);
    
    CGContextSaveGState(targetContext);
    CGContextClipToRect(targetContext, CGRectMake(0.0f, 0.0f, padding, padding));
    [source drawInRect:CGRectMake(0, 0, targetContextOriginalSize.width, targetContextOriginalSize.height) blendMode:kCGBlendModeCopy alpha:1.0f];
    CGContextRestoreGState(targetContext);

    CGContextSaveGState(targetContext);
    CGContextClipToRect(targetContext, CGRectMake(targetContextSize.width - padding, 0.0f, padding, padding));
    [source drawInRect:CGRectMake(targetContextSize.width - targetContextOriginalSize.width, 0, targetContextOriginalSize.width, targetContextOriginalSize.height) blendMode:kCGBlendModeCopy alpha:1.0f];
    CGContextRestoreGState(targetContext);
    
    CGContextSaveGState(targetContext);
    CGContextClipToRect(targetContext, CGRectMake(0.0f, targetContextSize.height - padding, padding, padding));
    [source drawInRect:CGRectMake(0, targetContextSize.height - targetContextOriginalSize.height, targetContextOriginalSize.width, targetContextOriginalSize.height) blendMode:kCGBlendModeCopy alpha:1.0f];
    CGContextRestoreGState(targetContext);
    
    CGContextSaveGState(targetContext);
    CGContextClipToRect(targetContext, CGRectMake(targetContextSize.width - padding, targetContextSize.height - padding, padding, padding));
    [source drawInRect:CGRectMake(targetContextSize.width - targetContextOriginalSize.width, targetContextSize.height - targetContextOriginalSize.height, targetContextOriginalSize.width, targetContextOriginalSize.height) blendMode:kCGBlendModeCopy alpha:1.0f];
    CGContextRestoreGState(targetContext);
    
    CGContextSaveGState(targetContext);
    CGContextClipToRect(targetContext, CGRectMake(padding, 0.0f, targetContextSize.width - padding * 2, padding));
    [source drawInRect:CGRectMake((targetContextSize.width - scaledWidth) / 2.0f, 0, scaledWidth, targetContextOriginalSize.height) blendMode:kCGBlendModeCopy alpha:1.0f];
    CGContextRestoreGState(targetContext);
    
    CGContextSaveGState(targetContext);
    CGContextClipToRect(targetContext, CGRectMake(padding, targetContextSize.height - padding, targetContextSize.width - padding * 2, padding));
    [source drawInRect:CGRectMake((targetContextSize.width - scaledWidth) / 2.0f, targetContextSize.height - targetContextOriginalSize.height, scaledWidth, targetContextOriginalSize.height) blendMode:kCGBlendModeCopy alpha:1.0f];
    CGContextRestoreGState(targetContext);
    
    CGContextSaveGState(targetContext);
    CGContextClipToRect(targetContext, CGRectMake(0.0f, padding, padding, targetContextSize.height - padding * 2));
    [source drawInRect:CGRectMake(0, (targetContextSize.height - scaledHeight) / 2.0f, targetContextOriginalSize.width, scaledHeight) blendMode:kCGBlendModeCopy alpha:1.0f];
    CGContextRestoreGState(targetContext);
    
    CGContextSaveGState(targetContext);
    CGContextClipToRect(targetContext, CGRectMake(targetContextSize.width - padding, padding, padding, targetContextSize.height - padding * 2));
    [source drawInRect:CGRectMake(targetContextSize.width - targetContextOriginalSize.width, (targetContextSize.height - scaledHeight) / 2.0f, targetContextOriginalSize.width, scaledHeight) blendMode:kCGBlendModeCopy alpha:1.0f];
    CGContextRestoreGState(targetContext);
    
    CGContextClipToRect(targetContext, CGRectMake(padding, padding, targetContextSize.width - padding * 2, targetContextSize.height - padding * 2));
    [source drawInRect:CGRectMake((targetContextSize.width - scaledWidth) / 2.0f, (targetContextSize.height - scaledHeight) / 2.0f, scaledWidth, scaledHeight) blendMode:kCGBlendModeCopy alpha:1.0f];
    
    UIGraphicsPopContext();
    
    addAttachmentImageCorners(targetMemory, targetContextSize.width, targetContextSize.height, targetBytesPerRow);
    
    CGImageRef bitmapImage = CGBitmapContextCreateImage(targetContext);
    UIImage *image = [[UIImage alloc] initWithCGImage:bitmapImage scale:scale orientation:UIImageOrientationUp];
    CGImageRelease(bitmapImage);
    
    CGContextRelease(targetContext);
    free(targetMemory);
    
    //return image;
    return [image resizableImageWithCapInsets:UIEdgeInsetsMake(padding / scale, padding / scale, padding / scale, padding / scale) resizingMode:UIImageResizingModeStretch];
}

UIImage *TGBlurredBackgroundImage(UIImage *source, CGSize size)
{
    CGFloat scale = source.scale;
    
    const struct { int width, height; } targetContextSize = { (int)(size.width * scale), (int)(size.height * scale) };
    
    size_t targetBytesPerRow = ((4 * (int)targetContextSize.width) + 15) & (~15);
    
    void *targetMemory = malloc((int)(targetBytesPerRow * targetContextSize.height));
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Host;
    
    CGContextRef targetContext = CGBitmapContextCreate(targetMemory, (int)targetContextSize.width, (int)targetContextSize.height, 8, targetBytesPerRow, colorSpace, bitmapInfo);
    
    CGColorSpaceRelease(colorSpace);
    
    UIGraphicsPushContext(targetContext);
    CGContextTranslateCTM(targetContext, targetContextSize.width / 2.0f, targetContextSize.height / 2.0f);
    CGContextScaleCTM(targetContext, 1.0f, -1.0f);
    CGContextTranslateCTM(targetContext, -targetContextSize.width / 2.0f, -targetContextSize.height / 2.0f);
    [source drawInRect:CGRectMake(0, 0, targetContextSize.width, targetContextSize.height) blendMode:kCGBlendModeCopy alpha:1.0f];
    UIGraphicsPopContext();
    
    brightenAndBlurImage(targetMemory, targetContextSize.width, targetContextSize.height, targetBytesPerRow, false);
    
    CGImageRef bitmapImage = CGBitmapContextCreateImage(targetContext);
    UIImage *image = [[UIImage alloc] initWithCGImage:bitmapImage scale:scale orientation:UIImageOrientationUp];
    CGImageRelease(bitmapImage);
    
    CGContextRelease(targetContext);
    free(targetMemory);
    
    return image;
}

UIImage *TGRoundImage(UIImage *source, CGSize size)
{
    CGFloat scale = TGIsRetina() ? 2.0f : 1.0f;
    
    const struct { int width, height; } targetContextSize = { (int)(size.width * scale), (int)(size.height * scale) };
    
    size_t targetBytesPerRow = ((4 * (int)targetContextSize.width) + 15) & (~15);
    
    void *targetMemory = malloc((int)(targetBytesPerRow * targetContextSize.height));
    memset(targetMemory, 0, (int)(targetBytesPerRow * targetContextSize.height));
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Host;
    
    CGContextRef targetContext = CGBitmapContextCreate(targetMemory, (int)targetContextSize.width, (int)targetContextSize.height, 8, targetBytesPerRow, colorSpace, bitmapInfo);
    
    CGColorSpaceRelease(colorSpace);
    
    UIGraphicsPushContext(targetContext);
    CGContextTranslateCTM(targetContext, targetContextSize.width / 2.0f, targetContextSize.height / 2.0f);
    CGContextScaleCTM(targetContext, 1.0f, -1.0f);
    CGContextTranslateCTM(targetContext, -targetContextSize.width / 2.0f, -targetContextSize.height / 2.0f);
    
    CGContextBeginPath(targetContext);
    CGContextAddEllipseInRect(targetContext, CGRectMake(0.0f, 0.0f, targetContextSize.width, targetContextSize.height));
    CGContextClip(targetContext);
    
    [source drawInRect:CGRectMake(0, 0, targetContextSize.width, targetContextSize.height) blendMode:kCGBlendModeCopy alpha:1.0f];
    UIGraphicsPopContext();
    
    CGImageRef bitmapImage = CGBitmapContextCreateImage(targetContext);
    UIImage *image = [[UIImage alloc] initWithCGImage:bitmapImage scale:scale orientation:UIImageOrientationUp];
    CGImageRelease(bitmapImage);
    
    CGContextRelease(targetContext);
    free(targetMemory);
    
    return image;
}

void TGPlainImageAverageColor(UIImage *source, uint32_t *averageColor)
{
    CGFloat scale = source.scale;
    CGSize size = source.size;
    
    const struct { int width, height; } targetContextSize = { (int)(size.width * scale), (int)(size.height * scale) };
    
    size_t targetBytesPerRow = ((4 * (int)targetContextSize.width) + 15) & (~15);
    
    void *targetMemory = malloc((int)(targetBytesPerRow * targetContextSize.height));
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Host;
    
    CGContextRef targetContext = CGBitmapContextCreate(targetMemory, (int)targetContextSize.width, (int)targetContextSize.height, 8, targetBytesPerRow, colorSpace, bitmapInfo);
    
    CGColorSpaceRelease(colorSpace);
    
    UIGraphicsPushContext(targetContext);
    CGContextTranslateCTM(targetContext, targetContextSize.width / 2.0f, targetContextSize.height / 2.0f);
    CGContextScaleCTM(targetContext, 1.0f, -1.0f);
    CGContextTranslateCTM(targetContext, -targetContextSize.width / 2.0f, -targetContextSize.height / 2.0f);
    [source drawInRect:CGRectMake(0, 0, targetContextSize.width, targetContextSize.height) blendMode:kCGBlendModeCopy alpha:1.0f];
    UIGraphicsPopContext();
    
    if (averageColor != NULL)
        *averageColor = TGImageAverageColor(targetMemory, targetContextSize.width, targetContextSize.height, targetBytesPerRow);
    
    CGContextRelease(targetContext);
    free(targetMemory);
}
