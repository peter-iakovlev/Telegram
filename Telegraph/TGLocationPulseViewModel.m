#import "TGLocationPulseViewModel.h"
#import "TGModernView.h"
#import <LegacyComponents/TGLocationPulseView.h>

@interface TGLocationPulseModelView: TGLocationPulseView <TGModernView>
{

}

@property (nonatomic, strong) NSString *viewIdentifier;
@property (nonatomic, strong) NSString *viewStateIdentifier;

@end

@interface TGLocationPulseModelView ()

@end

@implementation TGLocationPulseViewModel

- (Class)viewClass
{
    return [TGLocationPulseModelView class];
}

- (void)bindViewToContainer:(UIView *)container viewStorage:(TGModernViewStorage *)viewStorage
{
    [super bindViewToContainer:container viewStorage:viewStorage];
    
    TGLocationPulseModelView *view = (TGLocationPulseModelView *)[self boundView];
    view.transform = CGAffineTransformMakeScale(0.7f, 0.7f);
    [view start];
}

- (void)unbindView:(TGModernViewStorage *)viewStorage
{
    [super unbindView:viewStorage];
    [(TGLocationPulseModelView *)self.boundView stop];
}

- (void)resume
{
    [(TGLocationPulseModelView *)self.boundView start];
}

@end


@implementation TGLocationPulseModelView

- (void)willBecomeRecycled
{
    
}

@end
