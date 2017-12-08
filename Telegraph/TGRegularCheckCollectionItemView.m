#import "TGRegularCheckCollectionItemView.h"

#import <LegacyComponents/LegacyComponents.h>

#import "TGPresentation.h"

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

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    
    _label.frame = CGRectMake(15.0f + self.safeAreaInset.left, CGFloor((bounds.size.height - 26) / 2), bounds.size.width - 44.0f - 15.0f - self.safeAreaInset.left - self.safeAreaInset.right, 26);
    
    CGSize checkSize = _checkView.frame.size;
    _checkView.frame = CGRectMake(bounds.size.width - 27.0f - self.safeAreaInset.right, 16.0f, checkSize.width, checkSize.height);
}

@end
