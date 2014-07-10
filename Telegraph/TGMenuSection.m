#import "TGMenuSection.h"

@implementation TGMenuSection

@synthesize tag = _tag;
@synthesize title = _title;
@synthesize items = _items;

- (id)init
{
    self = [super init];
    if (self != nil)
    {
        _items = [[NSMutableArray alloc] init];
    }
    return self;
}

@end
