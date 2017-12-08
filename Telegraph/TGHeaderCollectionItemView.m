#import "TGHeaderCollectionItemView.h"

#import <LegacyComponents/LegacyComponents.h>

#import "TGPresentation.h"

@interface TGHeaderCollectionItemView ()
{
    UILabel *_label;
}

@end

@implementation TGHeaderCollectionItemView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _label = [[UILabel alloc] init];
        _label.backgroundColor = [UIColor clearColor];
        _label.font = TGSystemFontOfSize(14.0f);
        _label.textAlignment = NSTextAlignmentLeft;
        _label.lineBreakMode = NSLineBreakByTruncatingTail;
        _label.numberOfLines = 1;
        [self addSubview:_label];
    }
    return self;
}

- (void)setPresentation:(TGPresentation *)presentation
{
    [super setPresentation:presentation];
    
    _label.textColor = presentation.pallete.collectionMenuCommentColor;
}

- (void)setTitle:(NSString *)title
{
    _label.text = title;
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGSize labelSize = [_label sizeThatFits:CGSizeMake(self.bounds.size.width - 30.0f, CGFLOAT_MAX)];
    _label.frame = CGRectMake(15.0f + self.safeAreaInset.left, 0.0f, labelSize.width, labelSize.height);
}

@end
