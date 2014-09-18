#import "TGMediaAttachment.h"

@implementation TGMediaAttachment

@synthesize type = _type;
@synthesize isMeta = _isMeta;

- (void)serialize:(NSMutableData *)__unused data
{
    TGLog(@"***** TGMediaAttachment: default implementation not provided");
}

@end
