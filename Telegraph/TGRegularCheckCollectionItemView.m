/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGRegularCheckCollectionItemView.h"

#import "TGImageUtils.h"
#import "TGFont.h"

@interface TGRegularCheckCollectionItemView ()
{
    UIImageView *_checkView;
    UILabel *_label;
}

@end

@implementation TGRegularCheckCollectionItemView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _label = [[UILabel alloc] init];
        _label.textColor = [UIColor blackColor];
        _label.backgroundColor = [UIColor clearColor];
        _label.font = TGSystemFontOfSize(17);
        [self addSubview:_label];
        
        _checkView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ModernMenuCheck.png"]];
        [self addSubview:_checkView];
    }
    return self;
}

- (void)setTitle:(NSString *)title
{
    _label.text = title;
    [self setNeedsLayout];
}

- (void)setIsChecked:(bool)isChecked
{
    _checkView.hidden = !isChecked;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    
    _label.frame = CGRectMake(15.0f, CGFloor((bounds.size.height - 26) / 2), bounds.size.width - 44.0f - 15.0f, 26);
    
    CGSize checkSize = _checkView.frame.size;
    _checkView.frame = CGRectMake(bounds.size.width - 27.0f, 16.0f, checkSize.width, checkSize.height);
}

@end
