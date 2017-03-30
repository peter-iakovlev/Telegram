#import "TGCallAudioRouteButtonItemView.h"
#import "TGImageUtils.h"

@interface TGCallAudioRouteButtonItemView ()
{
    UIImageView *_iconView;
    UIImageView *_checkView;
}
@end

@implementation TGCallAudioRouteButtonItemView

- (instancetype)initWithTitle:(NSString *)title icon:(UIImage *)icon selected:(bool)selected action:(void (^)(void))action
{
    self = [super initWithTitle:title type:TGMenuSheetButtonTypeDefault action:action];
    if (self != nil)
    {
        if (icon != nil)
        {
            _iconView = [[UIImageView alloc] initWithImage:icon];
            [self addSubview:_iconView];
        }
        
        if (selected)
        {
            _checkView = [[UIImageView alloc] initWithImage:TGTintedImage([UIImage imageNamed:@"ModernMenuCheck"], TGAccentColor())];
            [self addSubview:_checkView];
        }
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _iconView.frame = CGRectMake(12.0f, floor((self.frame.size.height - _iconView.frame.size.height) / 2.0f), _iconView.frame.size.width, _iconView.frame.size.height);
    _checkView.frame = CGRectMake(self.frame.size.width - _checkView.frame.size.width - 13.0f, 23.0f, _checkView.frame.size.width, _checkView.frame.size.height);
}

@end
