/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGDataResource.h"

@interface TGDataResource ()
{
    NSData *_data;
    NSInputStream *_stream;
    UIImage *_image;
    bool _imageDecoded;
}

@end

@implementation TGDataResource

- (instancetype)initWithData:(NSData *)data
{
    self = [super init];
    if (self != nil)
    {
        _data = data;
    }
    return self;
}

- (instancetype)initWithInputStream:(NSInputStream *)stream
{
    self = [super init];
    if (self != nil)
    {
        _stream = stream;
    }
    return self;
}

- (instancetype)initWithImage:(UIImage *)image decoded:(bool)decoded
{
    self = [super init];
    if (self != nil)
    {
        _image = image;
        _imageDecoded = decoded;
    }
    return self;
}

- (void)dealloc
{
    [_stream close];
}

- (NSData *)data
{
    return _data;
}

- (NSInputStream *)stream
{
    return _stream;
}

- (UIImage *)image
{
    return _image;
}

- (bool)isImageDecoded
{
    return _imageDecoded;
}

@end
