#import "TGLiveLocationElapsedViewModel.h"

#import <LegacyComponents/TGLocationLiveElapsedView.h>

@interface TGLocationLiveElapsedModelView : TGLocationLiveElapsedView <TGModernView>
{
    
}

@property (nonatomic, strong) NSString *viewIdentifier;
@property (nonatomic, strong) NSString *viewStateIdentifier;

@end

@interface TGLiveLocationElapsedViewModel ()
{
    UIColor *_color;
    int32_t _remaining;
    int32_t _period;
}
@end

@implementation TGLiveLocationElapsedViewModel

- (instancetype)initWithColor:(UIColor *)color
{
    self = [super init];
    if (self != nil)
    {
        _color = color;
    }
    return self;
}

- (Class)viewClass
{
    return [TGLocationLiveElapsedModelView class];
}

- (void)bindViewToContainer:(UIView *)container viewStorage:(TGModernViewStorage *)viewStorage
{
    [super bindViewToContainer:container viewStorage:viewStorage];
    
    TGLocationLiveElapsedModelView *view = (TGLocationLiveElapsedModelView *)[self boundView];
    [view setColor:_color];
    [view setRemaining:_remaining period:_period];
}

- (void)unbindView:(TGModernViewStorage *)viewStorage
{
    [super unbindView:viewStorage];
}

- (void)setRemaining:(int32_t)remaining period:(int32_t)period
{
    _remaining = remaining;
    _period = period;
    
    if (self.boundView != nil)
    {
        TGLocationLiveElapsedModelView *view = (TGLocationLiveElapsedModelView *)self.boundView;
        [view setRemaining:remaining period:period];
    }
}

@end
      
@implementation TGLocationLiveElapsedModelView
    
- (void)willBecomeRecycled
{
        
}
      
@end
