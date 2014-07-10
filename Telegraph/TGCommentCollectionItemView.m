/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGCommentCollectionItemView.h"
#import "TGFont.h"

@interface TGCommentCollectionItemView ()
{
    UILabel *_label;
}

@end

@implementation TGCommentCollectionItemView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _label = [[UILabel alloc] init];
        _label.backgroundColor = [UIColor clearColor];
        _label.textColor = UIColorRGB(0x6d6d72);
        _label.font = TGSystemFontOfSize(14.0f);
        if (iosMajorVersion() >= 7)
            _label.textAlignment = NSTextAlignmentNatural;
        _label.lineBreakMode = NSLineBreakByWordWrapping;
        _label.numberOfLines = 0;
        [self addSubview:_label];
    }
    return self;
}

- (void)setText:(NSString *)text
{
    _label.text = text;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _label.frame = CGRectMake(15.0f, 7.0f, self.bounds.size.width - 30.0f, self.bounds.size.height - 7.0f - 7.0f);
}

@end
