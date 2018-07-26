#import "TGModernGalleryPIPHeaderView.h"
#import <LegacyComponents/TGModernButton.h>
#import <LegacyComponents/TGImageUtils.h>

#import "TGPresentation.h"

@interface TGModernGalleryPIPHeaderView () {
    TGModernButton *_button;
}

@end

@implementation TGModernGalleryPIPHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        self.tag = 0xbeef;
        
        _button = [[TGModernButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 50.0f, 44.0f)];
        _button.hidden = true;
        [_button setImage:TGPresentation.current.images.videoPlayerPIPIcon forState:UIControlStateNormal];
        [_button addTarget:self action:@selector(buttonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_button];
    }
    return self;
}

- (void)setPictureInPictureHidden:(bool)hidden
{
    _button.hidden = hidden;
}

- (void)setPictureInPictureEnabled:(bool)enabled
{
    _button.enabled = enabled;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    if (!_button.hidden && CGRectContainsPoint(_button.frame, point))
        return true;
    
    return [super pointInside:point withEvent:event];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _button.frame = CGRectMake(self.frame.size.width + 26.0f, -1.0f, _button.frame.size.width, _button.frame.size.height);
}

- (void)buttonPressed {
    if (_pipPressed != nil) {
        _pipPressed();
    }
}

@end
