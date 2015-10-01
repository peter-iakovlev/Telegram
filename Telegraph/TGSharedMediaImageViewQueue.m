#import "TGSharedMediaImageViewQueue.h"

#import "TGImageView.h"

@interface TGSharedMediaImageViewWithUri : NSObject

@property (nonatomic, strong, readonly) TGImageView *imageView;
@property (nonatomic, strong) NSString *uri;

@end

@implementation TGSharedMediaImageViewWithUri

- (instancetype)initWithImageView:(TGImageView *)imageView uri:(NSString *)uri
{
    self = [super init];
    if (self != nil)
    {
        _imageView = imageView;
        _uri = uri;
    }
    return self;
}

@end

@interface TGSharedMediaImageViewQueue ()
{
    NSMutableArray *_imageViewsAndUris;
}

@end

@implementation TGSharedMediaImageViewQueue

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        _imageViewsAndUris = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)enqueueImageView:(TGImageView *)imageView forUri:(NSString *)uri
{
    if (imageView != nil)
        [_imageViewsAndUris addObject:[[TGSharedMediaImageViewWithUri alloc] initWithImageView:imageView uri:uri]];
}

- (TGImageView *)dequeueImageViewForUri:(NSString *)uri
{
    NSInteger index = -1;
    for (TGSharedMediaImageViewWithUri *record in _imageViewsAndUris)
    {
        index++;
        if (TGStringCompare(record.uri, uri))
        {
            TGImageView *imageView = record.imageView;
            [_imageViewsAndUris removeObjectAtIndex:index];
            return imageView;
        }
    }
    
    TGImageView *imageView = [[TGImageView alloc] init];
    if (uri != nil)
        [imageView loadUri:uri withOptions:@{}];
    return imageView;
}

- (void)resetEnqueuedImageViews
{
    for (TGSharedMediaImageViewWithUri *record in _imageViewsAndUris)
    {
        [record.imageView reset];
        record.uri = nil;
    }
}

@end
