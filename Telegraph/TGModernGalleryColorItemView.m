/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGModernGalleryColorItemView.h"

#import "TGModernGalleryColorItem.h"

#import "TGModernGalleryZoomableScrollView.h"

@interface TGModernGalleryColorItemView ()
{
    UILabel *_label;
    UIView *_colorView;
}

@end

@implementation TGModernGalleryColorItemView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _colorView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 300.0f, 300.0f)];
        _colorView.backgroundColor = [UIColor blueColor];
        [self.scrollView addSubview:_colorView];
        
        _label = [[UILabel alloc] init];
        _label.backgroundColor = [UIColor clearColor];
        _label.textColor = [UIColor whiteColor];
        _label.font = [UIFont boldSystemFontOfSize:40.0f];
        [_colorView addSubview:_label];
    }
    return self;
}

- (void)setItem:(TGModernGalleryColorItem *)item
{
    [super setItem:item];
    
    _label.text = [[NSString alloc] initWithFormat:@"%d", item.number];
    [_label sizeToFit];
    _label.frame = CGRectMake(CGFloor((_colorView.frame.size.width - _label.frame.size.width) / 2.0f), CGFloor((_colorView.frame.size.height - _label.frame.size.height) / 2.0f), _label.frame.size.width, _label.frame.size.height);
}

- (CGSize)contentSize
{
    return CGSizeMake(300, 300);
}

- (UIView *)contentView
{
    return _colorView;
}

@end
