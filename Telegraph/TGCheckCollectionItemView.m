#import "TGCheckCollectionItemView.h"

#import <LegacyComponents/LegacyComponents.h>

#import "TGPresentation.h"

@interface TGCheckCollectionItemView ()
{
    UIImageView *_checkView;
    UILabel *_label;
}

@end

@implementation TGCheckCollectionItemView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        self.separatorInset = 44.0f;
        
        _label = [[UILabel alloc] init];
        _label.textAlignment = NSTextAlignmentLeft;
        _label.textColor = [UIColor blackColor];
        _label.backgroundColor = [UIColor clearColor];
        _label.font = TGSystemFontOfSize(17);
        [self addSubview:_label];
        
        _checkView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 14.0f, 11.0f)];
        [self addSubview:_checkView];
    }
    return self;
}

- (void)setPresentation:(TGPresentation *)presentation
{
    [super setPresentation:presentation];
    
    _label.textColor = presentation.pallete.collectionMenuTextColor;
    _checkView.image = presentation.images.collectionMenuCheckImage;
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

- (void)setDrawsFullSeparator:(bool)drawsFullSeparator
{
    _drawsFullSeparator = drawsFullSeparator;
    self.separatorInset = drawsFullSeparator ? 0.0f : (_alignToRight ? 15.0f : 44.0f);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    
    if (_drawsFullSeparator)
    {
        CGFloat separatorHeight = TGScreenPixel;
        _topStripeView.frame = CGRectMake(self.separatorInset, 0.0f, self.frame.size.width - self.separatorInset, separatorHeight * 2.0f);
    }
    
    if (_alignToRight)
    {
        _label.frame = CGRectMake(15.0f + self.safeAreaInset.left, CGFloor((bounds.size.height - 26) / 2), bounds.size.width - 44.0f - 16.0f - self.safeAreaInset.left - self.safeAreaInset.right, 26);
        
        CGSize checkSize = _checkView.frame.size;
        _checkView.frame = CGRectMake(bounds.size.width - 15.0f - checkSize.width - self.safeAreaInset.right, 16.0f, checkSize.width, checkSize.height);
    }
    else
    {
        _label.frame = CGRectMake(44.0f + self.safeAreaInset.left, CGFloor((bounds.size.height - 26) / 2), bounds.size.width - 44.0f - 16.0f - self.safeAreaInset.left - self.safeAreaInset.right, 26);
        
        CGSize checkSize = _checkView.frame.size;
        _checkView.frame = CGRectMake(15.0f + self.safeAreaInset.left, 16.0f, checkSize.width, checkSize.height);
    }
}

@end
