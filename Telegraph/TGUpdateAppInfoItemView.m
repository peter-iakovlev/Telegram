#import "TGUpdateAppInfoItemView.h"
#import "TGCollectionStaticMultilineTextItemView.h"

#import <LegacyComponents/LegacyComponents.h>

#import "TGPresentation.h"

#import "TGModernTextViewModel.h"

@interface TGUpdateAppInfoItemView ()
{
    TGImageView *_imageView;
    UIImageView *_cornersView;
    
    UILabel *_titleLabel;
    TGCollectionStaticMultilineTextItemViewTextView *_textContentView;
}
@end

@implementation TGUpdateAppInfoItemView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        self.selectionInsets = UIEdgeInsetsMake(TGScreenPixel, 0.0f, 0.0f, 0.0f);
        
        _imageView = [[TGImageView alloc] initWithFrame:CGRectMake(10.0f, 14.0f, 60.0f, 60.0f)];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_imageView];
        
        UIImage *appIcon = [UIImage imageNamed: [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIconFiles"] objectAtIndex:0]];
        _imageView.image = appIcon;
        
        _cornersView = [[UIImageView alloc] init];
        _cornersView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _cornersView.frame = _imageView.frame;
        [self addSubview:_cornersView];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = TGBoldSystemFontOfSize(17.0f);
        [self.contentView addSubview:_titleLabel];
        
        _textContentView = [[TGCollectionStaticMultilineTextItemViewTextView alloc] init];
        _textContentView.userInteractionEnabled = true;
        [self.contentView addSubview:_textContentView];
    }
    return self;
}

- (void)setPresentation:(TGPresentation *)presentation
{
    [super setPresentation:presentation];
    
    _titleLabel.backgroundColor = presentation.pallete.collectionMenuCellBackgroundColor;
    _titleLabel.textColor = presentation.pallete.collectionMenuTextColor;
    
    CGFloat radius = 16.0f;
    CGRect rect = CGRectMake(0, 0, radius * 2 + 1.0f, radius * 2 + 1.0f);
    
    UIGraphicsBeginImageContextWithOptions(rect.size, false, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(context);
    
    CGContextSetFillColorWithColor(context, presentation.pallete.collectionMenuCellBackgroundColor.CGColor);
    CGContextFillRect(context, rect);
    
    CGContextSetBlendMode(context, kCGBlendModeClear);
    
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextFillEllipseInRect(context, rect);
    
    CGContextRestoreGState(context);
    
    CGContextSetStrokeColorWithColor(context, presentation.pallete.collectionMenuSeparatorColor.CGColor);
    CGContextSetLineWidth(context, 0.5f);
    CGContextStrokeEllipseInRect(context, CGRectInset(rect, 0.5f, 0.5f));
    
    _cornersView.image = [UIGraphicsGetImageFromCurrentImageContext() resizableImageWithCapInsets:UIEdgeInsetsMake(radius, radius, radius, radius)];
    
    UIGraphicsEndImageContext();
}

- (void)setTitle:(NSString *)title
{
    _titleLabel.text = title;
    [_titleLabel sizeToFit];
    [self setNeedsLayout];
}

- (void)setTextModel:(TGModernTextViewModel *)textModel
{
    _textContentView.textModel = textModel;
    [self setNeedsLayout];
}

+ (CGFloat)heightForWidth:(CGFloat)__unused width textModel:(TGModernTextViewModel *)textModel
{
    CGSize textSize = textModel.frame.size;
    
    textSize.width = CGCeil(textSize.width);
    textSize.height = CGCeil(textSize.height);
    
    return textSize.height + 9.0f + 14.0f;
}

- (void)setFollowLink:(void (^)(NSString *))followLink {
    _textContentView.followLink = followLink;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = CGRectMake(14.0f, 75.0f + 8.0f, _textContentView.textModel.frame.size.width + 2.0f, _textContentView.textModel.frame.size.height + 2.0f);
    
    _imageView.frame = CGRectMake(14.0f, 14.0f, _imageView.frame.size.width, _imageView.frame.size.height);
    _cornersView.frame = _imageView.frame;
    
    _titleLabel.frame = CGRectMake(CGRectGetMaxX(_imageView.frame) + 14.0f, TGScreenPixelFloor(CGRectGetMidY(_imageView.frame) - _titleLabel.frame.size.height / 2.0f), _titleLabel.frame.size.width, _titleLabel.frame.size.height);
    
    if (!CGSizeEqualToSize(_textContentView.frame.size, frame.size))
    {
        _textContentView.frame = frame;
        [_textContentView setNeedsDisplay];
    }
}

@end
