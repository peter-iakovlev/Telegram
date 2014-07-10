#import "TGModernFlatteningView.h"

#import <QuartzCore/QuartzCore.h>

#import "TGModernFlatteningViewModel.h"

@interface TGModernFlatteningView ()

@property (nonatomic, strong) NSString *viewIdentifier;
@property (nonatomic, strong) NSString *viewStateIdentifier;

@end

@implementation TGModernFlatteningView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        self.backgroundColor = nil;
        self.opaque = false;
    }
    return self;
}

- (void)willBecomeRecycled
{
    self.layer.contents = nil;
}

@end
