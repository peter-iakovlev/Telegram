#import "TGPreviewAboutItemView.h"

#import "TGFont.h"

#import "TGWebPageMediaAttachment.h"
#import "TGLocationMediaAttachment.h"

const CGFloat TGPreviewAboutItemViewMargin = 21.0f;

@interface TGPreviewAboutItemView ()
{
    UIActivityIndicatorView *_indicatorView;
    UILabel *_titleLabel;
    UILabel *_subtitleLabel;
    
    bool _loading;
}
@end

@implementation TGPreviewAboutItemView

- (instancetype)init
{
    self = [super initWithType:TGMenuSheetItemTypeDefault];
    if (self != nil)
    {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = TGMediumSystemFontOfSize(17.0f);
        _titleLabel.numberOfLines = 2;
        _titleLabel.textColor = [UIColor blackColor];
        [self addSubview:_titleLabel];
        
        _subtitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _subtitleLabel.backgroundColor = [UIColor clearColor];
        _subtitleLabel.font = TGSystemFontOfSize(14.0f);
        _subtitleLabel.numberOfLines = 2;
        _subtitleLabel.textColor = UIColorRGB(0x8e8e93);
        [self addSubview:_subtitleLabel];
        
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self addSubview:_indicatorView];
    }
    return self;
}

- (instancetype)initWithWebPageAttachment:(TGWebPageMediaAttachment *)attachment
{
    self = [self init];
    if (self != nil)
    {
        _titleLabel.text = attachment.title;
        _subtitleLabel.text = attachment.pageDescription;
        
        if ([attachment.embedType isEqualToString:@"coub"])
        {
            if (attachment.title.length == 0)
            {
                [_indicatorView startAnimating];
                _loading = true;
            }
            else
            {
                _subtitleLabel.text = @" ";
                _subtitleLabel.alpha = 0.0f;
            }
        }
    }
    return self;
}

- (instancetype)initWithLocationAttachment:(TGLocationMediaAttachment *)attachment
{
    self = [self init];
    if (self != nil)
    {
        if (attachment.venue != nil)
        {
            _titleLabel.text = attachment.venue.title;
            _subtitleLabel.text = attachment.venue.address;
        }
    }
    return self;
}

- (instancetype)initWithDocumentAttachment:(TGDocumentMediaAttachment *)__unused attachment
{
    self = [self init];
    if (self != nil)
    {
        
    }
    return self;
}

- (void)setSingleLine:(bool)singleLine
{
    _singleLine = singleLine;
    _titleLabel.numberOfLines = 1;
    _subtitleLabel.numberOfLines = 1;
}

- (void)setTitle:(NSString *)title subtitle:(NSString *)subtitle
{
    _loading = false;
    [_indicatorView stopAnimating];
    
    _titleLabel.text = title;
    _subtitleLabel.text = subtitle;
    [self _updateHeightAnimated:true];
    
    if (_subtitleLabel.alpha < FLT_EPSILON)
    {
        [UIView animateWithDuration:0.2 animations:^
        {
            _subtitleLabel.alpha = 1.0f;
        }];
    }
}

- (CGFloat)preferredHeightForWidth:(CGFloat)width screenHeight:(CGFloat)__unused screenHeight
{
    if (_loading)
        return 71.0f;
    
    [UIView performWithoutAnimation:^
    {
        _titleLabel.frame = CGRectMake(TGPreviewAboutItemViewMargin, 15.0f, width - TGPreviewAboutItemViewMargin * 2, 0);
        [_titleLabel sizeToFit];
        
        _subtitleLabel.frame = CGRectMake(TGPreviewAboutItemViewMargin, CGRectGetMaxY(_titleLabel.frame) + 3.0f, width - TGPreviewAboutItemViewMargin * 2, 0);
        [_subtitleLabel sizeToFit];
    }];
    
    return ceil(CGRectGetMaxY(_subtitleLabel.frame) + 15.0f);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _indicatorView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
}

@end
