#import "TGStickerPackCollectionItemView.h"

#import "TGImageView.h"
#import "TGFont.h"
#import "TGStringUtils.h"
#import "TGImageUtils.h"

#import "TGDocumentMediaAttachment.h"

#import "TGStickerPackStatusView.h"

@interface TGStickerPackCollectionItemView ()
{
    UIImageView *_unreadView;
    TGImageView *_imageView;
    UILabel *_titleLabel;
    UILabel *_subtitleLabel;
    UIImageView *_reorderingControl;
    
    TGStickerPackStatusView *_statusView;
}

@end

@implementation TGStickerPackCollectionItemView

- (UIImage *)reorderingControlImage
{
    static UIImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(22.0f, 9.0f), false, 0.0f);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, UIColorRGB(0xc7c7cc).CGColor);
        CGContextFillRect(context, CGRectMake(0.0f, 0.0f, 22.0f, 2.0f - TGRetinaPixel));
        CGContextFillRect(context, CGRectMake(0.0f, 4.0f - TGRetinaPixel, 22.0f, 2.0f - TGRetinaPixel));
        CGContextFillRect(context, CGRectMake(0.0f, 7.0f, 22.0f, 2.0f - TGRetinaPixel));
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    });
    return image;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _imageView = [[TGImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.editingContentView addSubview:_imageView];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.font = TGBoldSystemFontOfSize(15.0f);
        [self.editingContentView addSubview:_titleLabel];
        
        _subtitleLabel = [[UILabel alloc] init];
        _subtitleLabel.backgroundColor = [UIColor clearColor];
        _subtitleLabel.textColor = UIColorRGB(0x808080);
        _subtitleLabel.font = TGSystemFontOfSize(14.0f);
        [self.editingContentView addSubview:_subtitleLabel];
        
        _reorderingControl = [[UIImageView alloc] initWithImage:[self reorderingControlImage]];
        _reorderingControl.alpha = 0.0f;
        [self.contentView addSubview:_reorderingControl];
        
        self.separatorInset = 60.0f;
    }
    return self;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    [_imageView reset];
}

- (void)setStickerPack:(TGStickerPack *)stickerPack
{
    NSString *title = stickerPack.title;
    if ([stickerPack.packReference isKindOfClass:[TGStickerPackBuiltinReference class]])
        title = TGLocalized(@"StickerPack.BuiltinPackName");
    _titleLabel.text = title;
    
    _subtitleLabel.text = [[NSString alloc] initWithFormat:TGLocalized([TGStringUtils integerValueFormat:@"StickerPack.StickerCount_" value:stickerPack.documents.count]), [[NSString alloc] initWithFormat:@"%d", (int)stickerPack.documents.count]];
    
    if (false && stickerPack.hidden) {
        [self setOptionText:TGLocalized(@"StickerSettings.ContextShow")];
        [self setIndicatorMode:TGEditableCollectionItemViewIndicatorAdd];
    } else {
        if (((TGStickerPackIdReference *)stickerPack.packReference).shortName.length == 0) {
            [self setOptionText:TGLocalized(@"StickerSettings.ContextHide")];
        } else {
            [self setOptionText:TGLocalized(@"Common.Delete")];
        }
        [self setIndicatorMode:TGEditableCollectionItemViewIndicatorDelete];
    }
    
    _titleLabel.alpha = (false && stickerPack.hidden) ? 0.4f : 1.0f;
    _subtitleLabel.alpha = _titleLabel.alpha;
    _imageView.alpha = _titleLabel.alpha;
    
    if (stickerPack.documents.count != 0)
    {
        TGDocumentMediaAttachment *documentMedia = stickerPack.documents[0];
        NSMutableString *uri = [[NSMutableString alloc] initWithString:@"sticker-preview://?"];
        if (documentMedia.documentId != 0)
            [uri appendFormat:@"documentId=%" PRId64 "", documentMedia.documentId];
        else
            [uri appendFormat:@"localDocumentId=%" PRId64 "", documentMedia.localDocumentId];
        [uri appendFormat:@"&accessHash=%" PRId64 "", documentMedia.accessHash];
        [uri appendFormat:@"&datacenterId=%" PRId32 "", (int32_t)documentMedia.datacenterId];
        
        NSString *legacyThumbnailUri = [documentMedia.thumbnailInfo imageUrlForLargestSize:NULL];
        if (legacyThumbnailUri != nil)
            [uri appendFormat:@"&legacyThumbnailUri=%@", [TGStringUtils stringByEscapingForURL:legacyThumbnailUri]];
        
        [uri appendFormat:@"&width=68&height=68"];
        [uri appendFormat:@"&highQuality=1"];
        [_imageView loadUri:uri withOptions:@{}];
    }
    
    [self setNeedsLayout];
}

- (void)setUnread:(bool)unread {
    if ((_unreadView != nil) != unread) {
        if (unread) {
            if (_unreadView == nil) {
                static UIImage *dotImage = nil;
                static dispatch_once_t onceToken;
                dispatch_once(&onceToken, ^{
                    UIGraphicsBeginImageContextWithOptions(CGSizeMake(6.0f, 6.0f), false, 0.0f);
                    CGContextRef context = UIGraphicsGetCurrentContext();
                    
                    CGContextSetFillColorWithColor(context, UIColorRGB(0x0f94f3).CGColor);
                    CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, 6.0f, 6.0f));
                    
                    dotImage = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                });
                _unreadView = [[UIImageView alloc] initWithImage:dotImage];
                [self addSubview:_unreadView];
            }
        } else {
            [_unreadView removeFromSuperview];
            _unreadView = nil;
        }
        [self setNeedsLayout];
    }
}

- (void)setStatus:(TGStickerPackItemStatus)status {
    if (status == TGStickerPackItemStatusNone) {
        [_statusView removeFromSuperview];
        _statusView = nil;
    } else {
        if (_statusView == nil) {
            _statusView = [[TGStickerPackStatusView alloc] init];
            __weak TGStickerPackCollectionItemView *weakSelf = self;
            _statusView.install = ^{
                __strong TGStickerPackCollectionItemView *strongSelf = weakSelf;
                if (strongSelf != nil && strongSelf->_addStickerPack) {
                    strongSelf->_addStickerPack();
                }
            };
            [self addSubview:_statusView];
        }
        [_statusView setStatus:status];
    }
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    CGRect bounds = self.bounds;
    
    CGFloat leftInset = self.showsDeleteIndicator ? 38.0f : 0.0f;
    CGFloat rightInset = self.showsDeleteIndicator ? 38.0f : 0.0f;
    self.separatorInset = 60.0f + leftInset;
    
    [super layoutSubviews];
    
    _imageView.frame = CGRectMake(13.0f + leftInset, CGFloor((self.frame.size.height - 34.0f) / 2.0f), 34.0f, 34.0f);
    
    CGFloat titleSubtitleSpacing = 2.0f;
    CGFloat titleInset = 0.0f;
    if (_unreadView != nil) {
        titleInset = 11.0f;
    }
    
    CGSize titleSize = [_titleLabel.text sizeWithFont:_titleLabel.font];
    titleSize.width = MIN(self.frame.size.width - leftInset - 60.0f - 8.0f - rightInset - titleInset, titleSize.width);
    CGSize subtitleSize = [_subtitleLabel.text sizeWithFont:_subtitleLabel.font];
    
    CGFloat verticalOrigin = CGFloor((self.frame.size.height - titleSize.height - subtitleSize.height - titleSubtitleSpacing) / 2.0f);
    
    if (_unreadView != nil) {
        titleInset = 11.0f;
        _unreadView.frame = CGRectMake(leftInset + 60.0f + 1.0f, verticalOrigin + 7.0f, 6.0f, 6.0f);
    }
    
    _titleLabel.frame = CGRectMake(leftInset + 60.0f + titleInset, verticalOrigin, titleSize.width, titleSize.height);
    _subtitleLabel.frame = CGRectMake(leftInset + 60.0f, verticalOrigin + 2.0f + titleSize.height + titleSubtitleSpacing, subtitleSize.width, subtitleSize.height);
    
    _reorderingControl.alpha = self.showsDeleteIndicator ? 1.0f : 0.0f;
    _reorderingControl.frame = CGRectMake(self.contentView.frame.size.width - 15.0f - _reorderingControl.frame.size.width, CGFloor((self.contentView.frame.size.height - _reorderingControl.frame.size.height) / 2.0f), _reorderingControl.frame.size.width, _reorderingControl.frame.size.height);
    
    if (_statusView != nil) {
        _statusView.frame = CGRectMake(bounds.size.width - _statusView.frame.size.width, CGFloor((bounds.size.height - _statusView.frame.size.height) / 2.0f), _statusView.frame.size.width, _statusView.frame.size.height);
    }
}

- (void)deleteAction
{
    if (_deleteStickerPack)
        _deleteStickerPack();
}

@end
