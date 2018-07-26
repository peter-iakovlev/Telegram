#import "TGUploadedMessageContentMedia.h"

@implementation TGUploadedMessageContentMedia

- (instancetype)initWithInputMedia:(Api82_InputMedia *)inputMedia
{
    self = [super init];
    if (self != nil)
    {
        _inputMedia = inputMedia;
    }
    return self;
}

@end
