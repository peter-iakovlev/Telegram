#import "TGTextCheckingResult.h"

@implementation TGTextCheckingResult

- (instancetype)initWithRange:(NSRange)range type:(TGTextCheckingResultType)type contents:(NSString *)contents
{
    if (self != nil)
    {
        _range = range;
        _type = type;
        _contents = contents;
    }
    return self;
}

@end
