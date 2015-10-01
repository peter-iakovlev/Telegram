#import "TGProfilePhotoController.h"

#import "WKInterfaceGroup+Signals.h"
#import "TGBridgeMediaSignals.h"

NSString *const TGProfilePhotoControllerIdentifier = @"TGProfilePhotoController";

@implementation TGProfilePhotoControllerContext

- (instancetype)initWithImageUrl:(NSString *)imageUrl;
{
    self = [super init];
    if (self != nil)
    {
        _imageUrl = imageUrl;
    }
    return self;
}

@end

@interface TGProfilePhotoController ()
{
    TGProfilePhotoControllerContext *_context;
}
@end

@implementation TGProfilePhotoController

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        
    }
    return self;
}

- (void)configureWithContext:(TGProfilePhotoControllerContext *)context
{
    _context = context;
    
    self.title = TGLocalized(@"PhotoView.Title");

    __weak TGProfilePhotoController *weakSelf = self;
    [self.imageGroup setBackgroundImageSignal:[[TGBridgeMediaSignals avatarWithUrl:_context.imageUrl type:TGBridgeMediaAvatarTypeLarge] onNext:^(id next)
    {
        __strong TGProfilePhotoController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        if (next != nil)
        {
            strongSelf.imageGroup.alpha = 0.0f;
            strongSelf.activityIndicator.hidden = true;
            [strongSelf animateWithDuration:0.25f animations:^
            {
                strongSelf.imageGroup.alpha = 1.0f;
            }];
        }
    }] isVisible:^bool
    {
        __strong TGProfilePhotoController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return false;
        
        return strongSelf.isVisible;
    }];
}

- (void)willActivate
{
    [super willActivate];
    
    [self.imageGroup updateIfNeeded];
}

- (void)didDeactivate
{
    [super didDeactivate];
}

+ (NSString *)identifier
{
    return TGProfilePhotoControllerIdentifier;
}

@end
