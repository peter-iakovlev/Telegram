#import "TGModernAnimatedImagePlayer.h"

#import "FLAnimatedImage.h"

@interface TGModernAnimatedImagePlayer ()
{
    FLAnimatedImage *_image;
}

@end

@implementation TGModernAnimatedImagePlayer

- (instancetype)initWithPath:(NSString *)path
{
    self = [super init];
    if (self != nil)
    {
        NSData *data = [[NSData alloc] initWithContentsOfFile:path];
        _image = [[FLAnimatedImage alloc] initWithAnimatedGIFData:data];
        
    }
    return self;
}

- (void)play
{
    
}

- (void)stop
{
    
}

- (void)pause
{
    
}

@end
