#import "TGGenericContextResultCell.h"

#import "TGBotContextExternalResult.h"
#import "TGBotContextMediaResult.h"

#import "TGImageUtils.h"
#import "TGFont.h"
#import "TGImageView.h"

#import "TGSharedMediaUtils.h"
#import "TGSharedPhotoSignals.h"
#import "TGSharedMediaSignals.h"

#import "TGMessageImageViewOverlayView.h"

#import "TGBotContextResultSendMessageGeo.h"

#import "TGMessage.h"

#import "TGDocumentMessageIconView.h"
#import "TGMessageImageView.h"

#import "TGLetteredAvatarView.h"

#import "TGBotContextResultSendMessageContact.h"

#import "TGMusicPlayer.h"
#import "TGTelegraph.h"
#import "TGGenericPeerPlaylistSignals.h"

@interface TGTruncatedLabel: UIView

@property (nonatomic, strong) NSAttributedString *attributedText;

@end

@implementation TGTruncatedLabel

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        self.contentMode = UIViewContentModeRedraw;
    }
    return self;
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    _attributedText = attributedText;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)__unused rect {
    [_attributedText drawWithRect:self.bounds options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine context:nil];
}

@end

@interface TGGenericContextResultCellContent () <TGMessageImageViewDelegate> {
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
    
    TGDocumentMessageIconView *_iconView;
    TGLetteredAvatarView *_avatarView;
    
    id<SDisposable> _musicStatusDisposable;
    TGBotContextResult *_result;
    TGMusicPlayerStatus *_playerStatus;
}

@property (nonatomic, copy) void (^preview)(TGBotContextResult *result);

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
        
        _imageView = [[TGImageView alloc] initWithFrame:CGRectMake(12.0f, 10.0f, 55.0f, 55.0f)];
        [self addSubview:_imageView];
        
        _iconView = [[TGDocumentMessageIconView alloc] initWithFrame:CGRectMake(18.0, 9.0f, 44.0f, 44.0f)];
        [_iconView setIncoming:true];
        [self addSubview:_iconView];
        _iconView.delegate = self;
        [_iconView setOverlayType:TGMessageImageViewOverlayPlayMedia];
        
        _avatarView = [[TGLetteredAvatarView alloc] initWithFrame:CGRectMake(18.0, 9.0f, 44.0f, 44.0f)];
        [_avatarView setSingleFontSize:18.0f doubleFontSize:18.0f useBoldFont:true];
        [self addSubview:_avatarView];
        
        _overlayView = [[TGMessageImageViewOverlayView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 25.0f, 25.0f)];
        [_overlayView setRadius:25.0f];
        [_overlayView setPlay];
        [_imageView addSubview:_overlayView];
        _overlayView.center = CGPointMake(27.5f, 27.5f);
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

- (void)dealloc {
    [_musicStatusDisposable dispose];
}

- (void)prepareForReuse {
    [_imageView reset];
    _previewUrl = nil;
    _isEmbed = false;
    _embedSize = CGSizeZero;
    _result = nil;
    [_musicStatusDisposable dispose];
    _musicStatusDisposable = nil;
    _result = nil;
    _playerStatus = nil;
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
    NSString *imageUrl = nil;
    _overlayView.hidden = true;
    _avatarView.highlighted = true;
    _iconView.hidden = true;
    bool isAudio = false;
    bool isContact = false;
    
    _result = result;
    
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
        
        if ([concreteResult.type isEqualToString:@"audio"] || [concreteResult.type isEqualToString:@"voice"]) {
            isAudio = true;
        }
        
        if ([concreteResult.type isEqualToString:@"contact"]) {
            isContact = true;
        }
        
        _imageView.hidden = false;
        
        if (concreteResult.thumbUrl.length != 0) {
            imageSignal = [TGSharedPhotoSignals cachedExternalThumbnail:concreteResult.thumbUrl size:CGSizeMake(48.0f, 48.0f) pixelProcessingBlock:[TGSharedMediaSignals pixelProcessingBlockForRoundCornersOfRadius:4.0f] cacheVariantKey:@"genericContextCell" threadPool:[TGSharedMediaUtils sharedMediaImageProcessingThreadPool] memoryCache:[TGSharedMediaUtils sharedMediaMemoryImageCache] diskCache:[TGSharedMediaUtils sharedMediaTemporaryPersistentCache]];
        } else if ([result.sendMessage isKindOfClass:[TGBotContextResultSendMessageGeo class]]) {
            TGBotContextResultSendMessageGeo *concreteMessage = (TGBotContextResultSendMessageGeo *)result.sendMessage;
            CGSize mapImageSize = CGSizeMake(75.0f, 75.0f);
            NSString *mapUri = [[NSString alloc] initWithFormat:@"map-thumbnail://?latitude=%f&longitude=%f&width=%d&height=%d&flat=1&cornerRadius=4", concreteMessage.location.latitude, concreteMessage.location.longitude, (int)mapImageSize.width, (int)mapImageSize.height];
            imageUrl = mapUri;
        }
    } else if ([result isKindOfClass:[TGBotContextMediaResult class]]) {
        TGBotContextMediaResult *concreteResult = (TGBotContextMediaResult *)result;
        
        if (concreteResult.photo != nil) {
            imageSignal = [TGSharedPhotoSignals cachedRemoteThumbnail:concreteResult.photo.imageInfo size:CGSizeMake(48.0f, 48.0f) pixelProcessingBlock:[TGSharedMediaSignals pixelProcessingBlockForRoundCornersOfRadius:4.0f] cacheVariantKey:@"genericContextCell" threadPool:[TGSharedMediaUtils sharedMediaImageProcessingThreadPool] memoryCache:[TGSharedMediaUtils sharedMediaMemoryImageCache] diskCache:[TGSharedMediaUtils sharedMediaTemporaryPersistentCache]];
        } else if (concreteResult.document != nil) {
            imageSignal = [TGSharedPhotoSignals cachedRemoteDocumentThumbnail:concreteResult.document size:CGSizeMake(48.0f, 48.0f) pixelProcessingBlock:[TGSharedMediaSignals pixelProcessingBlockForRoundCornersOfRadius:4.0f] cacheVariantKey:@"genericContextCell" threadPool:[TGSharedMediaUtils sharedMediaImageProcessingThreadPool] memoryCache:[TGSharedMediaUtils sharedMediaMemoryImageCache] diskCache:[TGSharedMediaUtils sharedMediaTemporaryPersistentCache]];
        }
        
        if ([concreteResult.type isEqualToString:@"video"]) {
            _overlayView.hidden = false;
        }
        
        if ([concreteResult.type isEqualToString:@"audio"] || [concreteResult.type isEqualToString:@"voice"]) {
            isAudio = true;
        }
        
        if ([concreteResult.type isEqualToString:@"contact"]) {
            isContact = true;
        }
        
        title = concreteResult.title;
        text = concreteResult.resultDescription;
    }
    
    if (isAudio || isContact) {
        [_imageView setSignal:nil];
        _alternativeImageBackgroundView.hidden = true;
        _alternativeImageLabel.hidden = true;
        _imageView.hidden = true;
        _imageButton.hidden = true;
        
        if (isAudio) {
            _iconView.hidden = false;
        } else if (isContact) {
            _avatarView.hidden = false;
            
            if ([result.sendMessage isKindOfClass:[TGBotContextResultSendMessageContact class]]) {
                TGBotContextResultSendMessageContact *contact = (TGBotContextResultSendMessageContact *)result.sendMessage;
                [_avatarView loadUserPlaceholderWithSize:CGSizeMake(44.0f, 44.0f) uid:0 firstName:contact.contact.firstName lastName:contact.contact.lastName placeholder:nil];
            } else {
                [_avatarView loadUserPlaceholderWithSize:CGSizeMake(44.0f, 44.0f) uid:0 firstName:title lastName:@"" placeholder:nil];
            }
        }
    } else {
        _iconView.hidden = true;
        _avatarView.hidden = true;
        _imageButton.hidden = false;
        
        if (imageSignal != nil) {
            [_imageView setSignal:imageSignal];
            _alternativeImageBackgroundView.hidden = true;
            _alternativeImageLabel.hidden = true;
            _imageView.hidden = false;
        } else if (imageUrl.length != 0) {
            [_imageView loadUri:imageUrl withOptions:@{}];
            _alternativeImageBackgroundView.hidden = true;
            _alternativeImageLabel.hidden = true;
            _imageView.hidden = false;
        } else {
            [_imageView setSignal:nil];
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
    }
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 0.0f;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    
    _titleLabel.attributedText = [[NSAttributedString alloc] initWithString:title == nil ? @"" : title attributes:@{NSFontAttributeName: TGBoldSystemFontOfSize(16.0f), NSParagraphStyleAttributeName: paragraphStyle}];
    
    _textLabel.attributedText = [[NSAttributedString alloc] initWithString:text == nil ? @"" : text attributes:@{NSFontAttributeName: TGSystemFontOfSize(15.0f), NSParagraphStyleAttributeName: paragraphStyle, NSForegroundColorAttributeName: UIColorRGB(0x8e8e93)}];
    
    [self setNeedsLayout];
    
    if (isAudio) {
        [_musicStatusDisposable dispose];
        
        __weak TGGenericContextResultCellContent *weakSelf = self;
        _musicStatusDisposable = [[[TGTelegraphInstance.musicPlayer playingStatus] deliverOn:[SQueue mainQueue]] startWithNext:^(TGMusicPlayerStatus *status) {
            __strong TGGenericContextResultCellContent *strongSelf = weakSelf;
            if (strongSelf != nil) {
                if ([strongSelf->_result.resultId isEqual:status.item.key]) {
                    [strongSelf setPlayerStatus:status];
                } else {
                    [strongSelf setPlayerStatus:nil];
                }
            }
        }];
    } else {
        [_musicStatusDisposable dispose];
        _musicStatusDisposable = nil;
    }
}

- (void)setPlayerStatus:(TGMusicPlayerStatus *)status {
    _playerStatus = status;
    if (status == nil) {
        [_iconView setOverlayType:TGMessageImageViewOverlayPlayMedia];
    } else {
        if (status.downloadedStatus.downloading) {
            if (_iconView.overlayType != TGMessageImageViewOverlayProgress) {
                [_iconView setOverlayType:TGMessageImageViewOverlayProgress];
                [_iconView setProgress:status.downloadedStatus.progress animated:false];
            } else {
                [_iconView setProgress:status.downloadedStatus.progress animated:true];
            }
        } else {
            if (status.paused) {
                [_iconView setOverlayType:TGMessageImageViewOverlayPlayMedia];
            } else {
                [_iconView setOverlayType:TGMessageImageViewOverlayPauseMedia];
            }
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    
    _alternativeImageBackgroundView.frame = _imageView.frame;
    _alternativeImageLabel.frame = CGRectMake(_imageView.frame.origin.x + CGFloor((_imageView.frame.size.width - _alternativeImageLabel.frame.size.width) / 2.0f), _imageView.frame.origin.y + CGFloor((_imageView.frame.size.height - _alternativeImageLabel.frame.size.height) / 2.0f), _alternativeImageLabel.frame.size.width, _alternativeImageLabel.frame.size.height);
    
    UIEdgeInsets insets = UIEdgeInsetsMake(8.0f, 79.0f, 8.0f, 8.0f);
    
    CGFloat maxTextWidth = bounds.size.width - insets.left - insets.right;
    
    static UIFont *titleFont = nil;
    static UIFont *textFont = nil;
    static CGFloat maxTitleHeight = 0.0f;
    static CGFloat maxTitleHeightSingle = 0.0f;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        titleFont = TGBoldSystemFontOfSize(16.0f);
        textFont = TGSystemFontOfSize(15.0f);
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = 0.0f;
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        
        maxTitleHeight = [[[NSAttributedString alloc] initWithString:@" \n " attributes:@{NSFontAttributeName: titleFont, NSParagraphStyleAttributeName: paragraphStyle}] boundingRectWithSize:CGSizeMake(1000.0f, 1000.0f) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.height;
        maxTitleHeightSingle = [[[NSAttributedString alloc] initWithString:@" " attributes:@{NSFontAttributeName: titleFont, NSParagraphStyleAttributeName: paragraphStyle}] boundingRectWithSize:CGSizeMake(1000.0f, 1000.0f) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.height;
    });
    
    if (!_iconView.hidden) {
        CGSize titleSize = [_titleLabel.attributedText boundingRectWithSize:CGSizeMake(bounds.size.width - insets.left - insets.right, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
        
        titleSize.width = CGCeil(MIN(maxTextWidth, titleSize.width));
        titleSize.height = CGCeil(MIN(maxTitleHeightSingle, titleSize.height));
        _titleLabel.frame = CGRectMake(insets.left, insets.top + 3.0f, titleSize.width, titleSize.height);
        
        CGSize textSize = CGSizeMake(maxTextWidth, bounds.size.height - CGRectGetMaxY(_titleLabel.frame) - 1.0f);
        _textLabel.frame = CGRectMake(insets.left, CGRectGetMaxY(_titleLabel.frame) + 1.0f, textSize.width, textSize.height);
    } else {
        CGSize titleSize = [_titleLabel.attributedText boundingRectWithSize:CGSizeMake(bounds.size.width - insets.left - insets.right, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
        
        titleSize.width = CGCeil(MIN(maxTextWidth, titleSize.width));
        titleSize.height = CGCeil(MIN(maxTitleHeight, titleSize.height));
        _titleLabel.frame = CGRectMake(insets.left, insets.top, titleSize.width, titleSize.height);
        
        CGSize textSize = CGSizeMake(maxTextWidth, bounds.size.height - CGRectGetMaxY(_titleLabel.frame) - 1.0f);
        _textLabel.frame = CGRectMake(insets.left, CGRectGetMaxY(_titleLabel.frame) + 1.0f, textSize.width, textSize.height);
    }
}

- (void)imageTapped {
    if (_preview != nil)
        _preview(_result);
}

- (void)messageImageViewActionButtonPressed:(TGMessageImageView *)__unused messageImageView withAction:(TGMessageImageViewActionType)action {
    if ([_result.type isEqualToString:@"audio"] || [_result.type isEqualToString:@"voice"]) {
        if (action == TGMessageImageViewActionPlay) {
            if (_playerStatus != nil) {
                if (_playerStatus.paused) {
                    [TGTelegraphInstance.musicPlayer controlPlay];
                } else {
                    [TGTelegraphInstance.musicPlayer controlPause];
                }
            } else {
                TGMusicPlayerItem *item = [TGMusicPlayerItem itemWithBotContextResult:_result];
                if (item != nil) {
                    [TGTelegraphInstance.musicPlayer setPlaylist:[TGGenericPeerPlaylistSignals playlistForItem:item voice:[_result.type isEqualToString:@"voice"]] initialItemKey:item.key metadata:nil];
                }
            }
        } else if (action == TGMessageImageViewActionCancelDownload) {
            [TGTelegraphInstance.musicPlayer setPlaylist:nil initialItemKey:nil metadata:nil];
        }
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
    _result = result;
    
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
