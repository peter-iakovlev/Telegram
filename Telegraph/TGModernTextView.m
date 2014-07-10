#import "TGModernTextView.h"

@interface TGModernTextView ()

@property (nonatomic, strong) NSString *viewIdentifier;
@property (nonatomic, strong) NSString *viewStateIdentifier;

@end

@implementation TGModernTextView

- (id)init
{
    self = [super init];
    if (self)
    {
    }
    return self;
}

- (void)willBecomeRecycled
{
}

@end
