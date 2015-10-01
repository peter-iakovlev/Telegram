#import "TGModernFlatteningView.h"

#import <QuartzCore/QuartzCore.h>

#import "TGModernFlatteningViewModel.h"

@interface TGModernFlatteningViewLayer : CALayer

@end

@implementation TGModernFlatteningViewLayer

- (id<CAAction>)actionForKey:(NSString *)event
{
    if ([event isEqualToString:@"contents"])
    {
        return nil;
    }
    return [super actionForKey:event];
}

@end

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

+ (Class)layerClass
{
    return [TGModernFlatteningViewLayer class];
}

- (void)willBecomeRecycled
{
    self.layer.contents = nil;
}

@end
