#import "DrawingContext.h"

#import "TGImageUtils.h"

static void DrawingContextDataProviderReleaseDataCallback(void *info, __unused const void *data, __unused size_t size) {
    free(info);
}

@interface DrawingContext () {
    CGSize _size;
    CGSize _scaledSize;
    CGBitmapInfo _bitmapInfo;
    int32_t _length;
    CGDataProviderRef _provider;
    
    CGContextRef _context;
}

@end

@implementation DrawingContext

- (instancetype)initWithSize:(CGSize)size scale:(CGFloat)scale clear:(bool)clear {
    self = [super init];
    if (self != nil) {
        _size = size;
        _scale = scale == 0.0f ? TGScreenScaling() : scale;
        _scaledSize = CGSizeMake(size.width * _scale, size.height * _scale);
        
        _bytesPerRow = (4 * ((int32_t)(_scaledSize.width)) + 15) & (~15);
        _length = _bytesPerRow * ((int32_t)(_scaledSize.height));
        
        _bitmapInfo = kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst;
        
        _bytes = malloc(_length);
        if (clear) {
            memset(_bytes, 0, _length);
        }
        _provider = CGDataProviderCreateWithData(_bytes, _bytes, _length, &DrawingContextDataProviderReleaseDataCallback);
    }
    return self;
}

- (void)dealloc {
    if (_context != nil) {
        CGContextRelease(_context);
    }
    if (_provider != nil) {
        CGDataProviderRelease(_provider);
    }
}

- (void)withContext:(void (^)(CGContextRef))f {
    if (_context == nil) {
        static CGColorSpaceRef deviceColorSpace = NULL;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            deviceColorSpace = CGColorSpaceCreateDeviceRGB();
        });
        _context = CGBitmapContextCreate(_bytes, (int32_t)_scaledSize.width, (int32_t)_scaledSize.height, 8, _bytesPerRow, deviceColorSpace, _bitmapInfo);
        if (_context != nil) {
            CGContextScaleCTM(_context, _scale, _scale);
        }
    }
    if (_context != nil) {
        CGContextTranslateCTM(_context, _size.width / 2.0f, _size.height / 2.0f);
        CGContextScaleCTM(_context, 1.0f, -1.0f);
        CGContextTranslateCTM(_context, -_size.width / 2.0f, -_size.height / 2.0f);
        
        if (f) {
            f(_context);
        }
        
        CGContextTranslateCTM(_context, _size.width / 2.0f, _size.height / 2.0f);
        CGContextScaleCTM(_context, 1.0f, -1.0f);
        CGContextTranslateCTM(_context, -_size.width / 2.0f, -_size.height / 2.0f);
    }
}

- (void)withFlippedContext:(void (^)(CGContextRef))f {
    if (_context == nil) {
        static CGColorSpaceRef deviceColorSpace = NULL;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            deviceColorSpace = CGColorSpaceCreateDeviceRGB();
        });
        _context = CGBitmapContextCreate(_bytes, (int32_t)_scaledSize.width, (int32_t)_scaledSize.height, 8, _bytesPerRow, deviceColorSpace, _bitmapInfo);
        if (_context != nil) {
            CGContextScaleCTM(_context, _scale, _scale);
        }
    }
    if (_context != nil) {
        if (f) {
            f(_context);
        }
    }
}

- (UIImage *)generateImage {
    static CGColorSpaceRef deviceColorSpace = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        deviceColorSpace = CGColorSpaceCreateDeviceRGB();
    });
    CGImageRef image = CGImageCreate((int32_t)_scaledSize.width, (int32_t)_scaledSize.height, 8, 32, _bytesPerRow, deviceColorSpace, _bitmapInfo, _provider, nil, false, kCGRenderingIntentDefault);
    if (image != nil) {
        UIImage *uiImage = [[UIImage alloc] initWithCGImage:image scale:_scale orientation:UIImageOrientationUp];
        CGImageRelease(image);
        return uiImage;
    } else {
        return nil;
    }
}

@end
