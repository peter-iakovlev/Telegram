#import "ImageResourceDatas.h"

@implementation ImageResourceDatas

- (instancetype)initWithThumbnail:(NSData *)thumbnail fullSize:(NSData *)fullSize complete:(bool)complete {
    self = [super init];
    if (self != nil) {
        _thumbnail = thumbnail;
        _fullSize = fullSize;
        _complete = complete;
    }
    return self;
}

@end

@implementation FileResourceDatas

- (instancetype)initWithThumbnail:(NSData *)thumbnail fullSizePath:(NSString *)fullSizePath {
    self = [super init];
    if (self != nil) {
        _thumbnail = thumbnail;
        _fullSizePath = fullSizePath;
    }
    return self;
}

@end
