/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGAudioSliderButton.h"

@interface TGAudioSliderButton ()
{
    UIView *_handleView;
}

@end

@implementation TGAudioSliderButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {        
        _handleView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 1.5f, frame.size.height)];
        _handleView.backgroundColor = [UIColor blueColor];
        _handleView.userInteractionEnabled = false;
        [self addSubview:_handleView];
    }
    return self;
}

- (void)setColor:(UIColor *)color
{
    _handleView.backgroundColor = color;
}

@end
