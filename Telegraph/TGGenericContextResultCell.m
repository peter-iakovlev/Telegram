#import "TGGenericContextResultCell.h"

#import "TGBotContextExternalResult.h"
#import "TGBotContextDocumentResult.h"
#import "TGBotContextImageResult.h"

#import "TGImageUtils.h"
#import "TGFont.h"
#import "TGImageView.h"

#import "TGSharedMediaUtils.h"
#import "TGSharedPhotoSignals.h"
#import "TGSharedMediaSignals.h"

#import "TGMessageImageViewOverlayView.h"

@interface TGTruncatedLabel: UIView

@property (nonatomic, strong) NSAttributedString *attributedText;

@end

@implementation TGTruncatedLabel

- (void)setAttributedText:(NSAttributedString *)attributedText {
    _attributedText = attributedText;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)__unused rect {
    [_attributedText drawWithRect:self.bounds options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine context:nil];
}

@end

@interface TGGenericContextResultCellContent () {
    TGTruncatedLabel *_titleLabel;
    TGTruncatedLabel *_textLabel;
    
    TGImageView *_imageView;
    TGMessageImageViewOverlayView *_overlayView;
    UIImageView *_alternativeImageBackgroundView;
    UILabel *_alternativeImageLabel;
    
    UIButton *_imageButton;
    
    NSString *_previewUrl;
    bool _isEmbed;
    CGSize _embedSize;
}

@property (nonatomic, copy) void (^preview)(NSString *url, bool embed, CGSize embedSize);

@end

@implementation TGGenericContextResultCellContent

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        static UIImage *alternativeImageBackground = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^ {
            CGFloat diameter = 4.0;
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(diameter, diameter), false, 0.0);
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSetFillColorWithColor(context, UIColorRGB(0xdfdfdf).CGColor);
            CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, diameter, diameter));
            alternativeImageBackground = [UIGraphicsGetImageFromCurrentImageContext() stretchableImageWithLeftCapWidth:(NSInteger)(diameter / 2.0) topCapHeight:(NSInteger)(diameter / 2.0)];
            UIGraphicsEndImageContext();
        });
        
        _alternativeImageBackgroundView = [[UIImageView alloc] initWithImage:alternativeImageBackground];
        [self addSubview:_alternativeImageBackgroundView];
        _alternativeImageLabel = [[UILabel alloc] init];
        _alternativeImageLabel.backgroundColor = [UIColor clearColor];
        _alternativeImageLabel.font = TGSystemFontOfSize(25.0f);
        _alternativeImageLabel.textColor = [UIColor whiteColor];
        [self addSubview:_alternativeImageLabel];
        
        _imageView = [[TGImageView alloc] initWithFrame:CGRectMake(16.0f, 9.0f, 50.0f, 50.0f)];
        [self addSubview:_imageView];
        
        _overlayView = [[TGMessageImageViewOverlayView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 25.0f, 25.0f)];
        [_overlayView setRadius:25.0f];
        [_overlayView setPlay];
        [_imageView addSubview:_overlayView];
        _overlayView.center = CGPointMake(25.0f, 25.0f);
        _overlayView.hidden = true;
        
        _imageButton = [[UIButton alloc] initWithFrame:_imageView.frame];
        [_imageButton addTarget:self action:@selector(imageTapped) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_imageButton];
        
        _titleLabel = [[TGTruncatedLabel alloc] init];
        _titleLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_titleLabel];
        
        _textLabel = [[TGTruncatedLabel alloc] init];
        _textLabel.backgroundColor = [UIColor clearColor];
        _textLabel.contentMode = UIViewContentModeRedraw;
        [self addSubview:_textLabel];
    }
    return self;
}

- (void)prepareForReuse {
    [_imageView reset];
    _previewUrl = nil;
    _isEmbed = false;
    _embedSize = CGSizeZero;
    _result = nil;
}

- (void)setResult:(TGBotContextResult *)result {
    _result = result;
    
    NSString *title = @"";
    NSString *text = @"";
    NSString *link = @"";
    _previewUrl = nil;
    _isEmbed = false;
    _embedSize = CGSizeZero;
    
    SSignal *imageSignal = nil;
    _overlayView.hidden = true;
    
    if ([result isKindOfClass:[TGBotContextExternalResult class]]) {
        TGBotContextExternalResult *concreteResult = (TGBotContextExternalResult *)result;
        title = concreteResult.title;
        text = concreteResult.pageDescription;
        link = concreteResult.url;
        if (link.length == 0) {
            link = concreteResult.originalUrl;
        }
        if ([concreteResult.type isEqualToString:@"video"] && concreteResult.size.width > FLT_EPSILON && concreteResult.size.height > FLT_EPSILON) {
            _previewUrl = concreteResult.originalUrl;
            _isEmbed = true;
            _embedSize = concreteResult.size;
            _overlayView.hidden = false;
        } else {
            _previewUrl = concreteResult.originalUrl == nil ? concreteResult.url : concreteResult.originalUrl;
        }
        
        if (concreteResult.thumbUrl.length != 0) {
            imageSignal = [TGSharedPhotoSignals cachedExternalThumbnail:concreteResult.thumbUrl size:CGSizeMake(48.0f, 48.0f) pixelProcessingBlock:[TGSharedMediaSignals pixelProcessingBlockForRoundCornersOfRadius:4.0f] cacheVariantKey:@"genericContextCell" threadPool:[TGSharedMediaUtils sharedMediaImageProcessingThreadPool] memoryCache:[TGSharedMediaUtils sharedMediaMemoryImageCache] diskCache:[TGSharedMediaUtils sharedMediaTemporaryPersistentCache]];
        }
    }
    
    [_imageView setSignal:imageSignal];
    if (imageSignal != nil) {
        _alternativeImageBackgroundView.hidden = true;
        _alternativeImageLabel.hidden = true;
        _imageView.hidden = false;
    } else {
        _alternativeImageBackgroundView.hidden = false;
        _alternativeImageLabel.hidden = false;
        _imageView.hidden = true;
        
        NSString *host = nil;
        if (link.length != 0)
        {
            NSURL *url = [NSURL URLWithString:link];
            if (url != nil)
            {
                host = url.host;
                NSRange lastDot = [host rangeOfString:@"." options:NSBackwardsSearch];
                if (lastDot.location != NSNotFound)
                {
                    NSRange previousDot = [host rangeOfString:@"." options:NSBackwardsSearch range:NSMakeRange(0, lastDot.location - 1)];
                    if (previousDot.location == NSNotFound)
                        host = [host substringToIndex:lastDot.location];
                    else
                    {
                        host = [host substringWithRange:NSMakeRange(previousDot.location + 1, lastDot.location - previousDot.location - 1)];
                    }
                }
            }
        } else if (title.length != 0) {
            host = title;
        }
        
        if (host.length >= 1)
            _alternativeImageLabel.text = [[host substringToIndex:1] uppercaseString];
        else
            _alternativeImageLabel.text = @"";
        [_alternativeImageLabel sizeToFit];
    }
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 0.0f;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    
    _titleLabel.attributedText = [[NSAttributedString alloc] initWithString:title == nil ? @"" : title attributes:@{NSFontAttributeName: TGBoldSystemFontOfSize(14.0f), NSParagraphStyleAttributeName: paragraphStyle}];
    
    _textLabel.attributedText = [[NSAttributedString alloc] initWithString:text == nil ? @"" : text attributes:@{NSFontAttributeName: TGSystemFontOfSize(14.0f), NSParagraphStyleAttributeName: paragraphStyle}];
    
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    
    _alternativeImageBackgroundView.frame = _imageView.frame;
    _alternativeImageLabel.frame = CGRectMake(_imageView.frame.origin.x + CGFloor((_imageView.frame.size.width - _alternativeImageLabel.frame.size.width) / 2.0f), _imageView.frame.origin.y + CGFloor((_imageView.frame.size.height - _alternativeImageLabel.frame.size.height) / 2.0f), _alternativeImageLabel.frame.size.width, _alternativeImageLabel.frame.size.height);
    
    UIEdgeInsets insets = UIEdgeInsetsMake(8.0f, 78.0f, 8.0f, 8.0f);
    
    CGFloat maxTextWidth = bounds.size.width - insets.left - insets.right;
    
    static UIFont *titleFont = nil;
    static UIFont *textFont = nil;
    static CGFloat maxTitleHeight = 0.0f;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        titleFont = TGBoldSystemFontOfSize(14.0f);
        textFont = TGSystemFontOfSize(14.0f);
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = 0.0f;
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        
        maxTitleHeight = [[[NSAttributedString alloc] initWithString:@" \n " attributes:@{NSFontAttributeName: titleFont, NSParagraphStyleAttributeName: paragraphStyle}] boundingRectWithSize:CGSizeMake(1000.0f, 1000.0f) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.height;
    });
    
    CGSize titleSize = [_titleLabel.attributedText boundingRectWithSize:CGSizeMake(bounds.size.width - insets.left - insets.right, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    
    titleSize.width = CGCeil(MIN(maxTextWidth, titleSize.width));
    titleSize.height = CGCeil(MIN(maxTitleHeight, titleSize.height));
    _titleLabel.frame = CGRectMake(insets.left, insets.top, titleSize.width, titleSize.height);
    
    CGSize textSize = CGSizeMake(maxTextWidth, bounds.size.height - CGRectGetMaxY(_titleLabel.frame) - 1.0f);
    _textLabel.frame = CGRectMake(insets.left, CGRectGetMaxY(_titleLabel.frame) + 1.0f, textSize.width, textSize.height);
}

- (void)imageTapped {
    if (_preview && _previewUrl.length != 0) {
        _preview(_previewUrl, _isEmbed, _embedSize);
    }
}

@end

@interface TGGenericContextResultCell () {
    TGGenericContextResultCellContent *_content;
}

@end

@implementation TGGenericContextResultCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self != nil) {
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    [_content prepareForReuse];
}

- (void)setResult:(TGBotContextResult *)result {
    if (_content == nil) {
        _content = [[TGGenericContextResultCellContent alloc] initWithFrame:self.bounds];
        _content.preview = _preview;
        [self.contentView addSubview:_content];
    }
    [_content setResult:result];
}

- (TGGenericContextResultCellContent *)_takeContent {
    TGGenericContextResultCellContent *content = _content;
    [content removeFromSuperview];
    _content = nil;
    return content;
}

- (void)_putContent:(TGGenericContextResultCellContent *)content {
    if (_content != nil) {
        [_content removeFromSuperview];
        _content = nil;
    }
    
    _content = content;
    if (_content != nil) {
        _content.preview = _preview;
        _content.frame = self.bounds;
        [self.contentView addSubview:_content];
    }
}

- (bool)hasContent {
    return _content != nil;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _content.frame = self.bounds;
}

@end
