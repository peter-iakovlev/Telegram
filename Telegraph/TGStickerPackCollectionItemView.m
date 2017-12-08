#import "TGStickerPackCollectionItemView.h"

#import <LegacyComponents/LegacyComponents.h>

#import <LegacyComponents/TGImageView.h>

#import "TGStickerPackStatusView.h"

#import "TGPresentation.h"

@interface TGStickerPackCollectionItemView ()
{
    UIImageView *_unreadView;
    TGImageView *_imageView;
    UILabel *_titleLabel;
    UILabel *_subtitleLabel;
    UIImageView *_reorderingControl;
    UIImageView *_checkView;
    
    TGStickerPackStatusView *_statusView;
    UIActivityIndicatorView *_activityIndicator;
}

@end

@implementation TGStickerPackCollectionItemView


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
        _titleLabel.font = TGBoldSystemFontOfSize(15.0f);
        [self.editingContentView addSubview:_titleLabel];
        
        _subtitleLabel = [[UILabel alloc] init];
        _subtitleLabel.backgroundColor = [UIColor clearColor];
        _subtitleLabel.font = TGSystemFontOfSize(14.0f);
        [self.editingContentView addSubview:_subtitleLabel];
        
        _reorderingControl = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 22.0f, 9.0f)];
        _reorderingControl.alpha = 0.0f;
        [self.contentView addSubview:_reorderingControl];
        
        self.separatorInset = 60.0f;
    }
    return self;
}

- (void)setPresentation:(TGPresentation *)presentation
{
    [super setPresentation:presentation];
    
    _titleLabel.textColor = presentation.pallete.collectionMenuTextColor;
    _subtitleLabel.textColor = presentation.pallete.collectionMenuVariantColor;
    _checkView.image = presentation.images.collectionMenuCheckImage;
    _reorderingControl.image = presentation.images.collectionMenuReorderIcon;
    _unreadView.image = presentation.images.collectionMenuUnreadIcon;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    [_imageView reset];
}

- (void)setSearchStatus:(TGStickerPackItemSearchStatus)searchStatus
{
    bool searching = searchStatus == TGStickerPackItemSearchStatusSearching;
    if (searching && _activityIndicator == nil)
    {
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _activityIndicator.color = UIColorRGB(0x7c828c);
        _activityIndicator.transform = CGAffineTransformMakeScale(0.85f, 0.85f);
        [self.contentView addSubview:_activityIndicator];
    }
    
    if (searching)
    {
        _activityIndicator.hidden = false;
        [_activityIndicator startAnimating];
    }
    else
    {
        [_activityIndicator stopAnimating];
        _activityIndicator.hidden = true;
    }
    
    if (searchStatus == TGStickerPackItemSearchStatusSearching)
    {
        _titleLabel.text = TGLocalized(@"Channel.Stickers.Searching");
        _subtitleLabel.text = nil;
        _titleLabel.textColor = self.presentation.pallete.collectionMenuTextColor;
        
        [_imageView reset];
    }
    else if (searchStatus == TGStickerPackItemSearchStatusFailed)
    {
        _titleLabel.text = TGLocalized(@"Channel.Stickers.NotFound");
        _titleLabel.textColor = self.presentation.pallete.collectionMenuDestructiveColor;
        _subtitleLabel.text = TGLocalized(@"Channel.Stickers.NotFoundHelp");
        
        [_imageView loadUri:@"embedded-image://" withOptions:@{TGImageViewOptionEmbeddedImage: [UIImage imageNamed:@"StickerPackNotFoundIcon"]}];
    }
    else
    {
        _titleLabel.textColor = self.presentation.pallete.collectionMenuTextColor;
    }
    
    [self setNeedsLayout];
}

- (void)setIsChecked:(bool)isChecked
{
    if (_checkView == nil)
    {
        _checkView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 14.0f, 11.0f)];
        _checkView.image = self.presentation.images.collectionMenuCheckImage;
        [self addSubview:_checkView];
    }
    _checkView.hidden = !isChecked;
}

- (void)setStickerPack:(TGStickerPack *)stickerPack
{
    NSString *title = stickerPack.title;
    if ([stickerPack.packReference isKindOfClass:[TGStickerPackBuiltinReference class]])
        title = TGLocalized(@"StickerPack.BuiltinPackName");
    _titleLabel.text = title;
    
    _subtitleLabel.text = [[NSString alloc] initWithFormat:TGLocalized([TGStringUtils integerValueFormat:@"StickerPack.StickerCount_" value:stickerPack.documents.count]), [[NSString alloc] initWithFormat:@"%d", (int)stickerPack.documents.count]];
    
    if (((TGStickerPackIdReference *)stickerPack.packReference).shortName.length == 0) {
        [self setOptionText:TGLocalized(@"StickerSettings.ContextHide")];
    } else {
        [self setOptionText:TGLocalized(@"Common.Delete")];
    }
    [self setIndicatorMode:TGEditableCollectionItemViewIndicatorDelete];
    
    _titleLabel.alpha = 1.0f;
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
                _unreadView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 6.0f, 6.0f)];
                _unreadView.image = self.presentation.images.collectionMenuUnreadIcon;
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
    
    CGFloat leftInset = (self.showsDeleteIndicator ? 38.0f : 0.0f) + self.safeAreaInset.left;
    CGFloat rightInset = (self.showsDeleteIndicator ? 38.0f : 0.0f) + self.safeAreaInset.right;
    self.separatorInset = 60.0f + leftInset;
    
    [super layoutSubviews];
    
    _imageView.frame = CGRectMake(13.0f + leftInset , CGFloor((self.frame.size.height - 34.0f) / 2.0f), 34.0f, 34.0f);
    _activityIndicator.center = _imageView.center;
    
    CGFloat titleSubtitleSpacing = 2.0f;
    CGFloat titleInset = 0.0f;
    if (_unreadView != nil) {
        titleInset = 11.0f;
    }
    
    CGSize titleSize = [_titleLabel.text sizeWithFont:_titleLabel.font];
    titleSize.width = MIN(self.frame.size.width - leftInset - 60.0f - 8.0f - rightInset - titleInset, titleSize.width);
    CGSize subtitleSize = [_subtitleLabel.text sizeWithFont:_subtitleLabel.font];
    
    CGFloat verticalOrigin = _subtitleLabel.text.length > 0 ? CGFloor((self.frame.size.height - titleSize.height - subtitleSize.height - titleSubtitleSpacing) / 2.0f) : CGFloor((self.frame.size.height - titleSize.height) / 2.0f);
    
    if (_unreadView != nil) {
        titleInset = 11.0f;
        _unreadView.frame = CGRectMake(leftInset + 60.0f + 1.0f, verticalOrigin + 7.0f, 6.0f, 6.0f);
    }
    
    _titleLabel.frame = CGRectMake(leftInset + 60.0f + titleInset, verticalOrigin, titleSize.width, titleSize.height);
    _subtitleLabel.frame = CGRectMake(leftInset + 60.0f, verticalOrigin + 1.0f + titleSize.height + titleSubtitleSpacing, subtitleSize.width, subtitleSize.height);
    
    _reorderingControl.alpha = self.showsDeleteIndicator ? 1.0f : 0.0f;
    _reorderingControl.frame = CGRectMake(self.contentView.frame.size.width - 15.0f - _reorderingControl.frame.size.width - self.safeAreaInset.right, CGFloor((self.contentView.frame.size.height - _reorderingControl.frame.size.height) / 2.0f), _reorderingControl.frame.size.width, _reorderingControl.frame.size.height);
    
    if (_statusView != nil) {
        _statusView.frame = CGRectMake(bounds.size.width - _statusView.frame.size.width - self.safeAreaInset.right, CGFloor((bounds.size.height - _statusView.frame.size.height) / 2.0f), _statusView.frame.size.width, _statusView.frame.size.height);
    }
    
    if (_checkView != nil) {
        CGSize checkSize = _checkView.frame.size;
        _checkView.frame = CGRectMake(bounds.size.width - 15.0f - checkSize.width - self.safeAreaInset.right, 24.0f, checkSize.width, checkSize.height);
    }
}

- (void)deleteAction
{
    if (_deleteStickerPack)
        _deleteStickerPack();
}

@end
