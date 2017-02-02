#import "TGUploadedMessageContentText.h"

@implementation TGUploadedMessageContentText

- (instancetype)initWithText:(NSString *)text
{
    self = [super init];
    if (self != nil)
    {
        _text = text;
    }
    return self;
}

@end
