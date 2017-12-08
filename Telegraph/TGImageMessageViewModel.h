/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGMessageViewModel.h"
#import <CoreText/CoreText.h>

#import "TGMessageGroupedLayout.h"

@class TGImageInfo;
@class TGUser;
@class TGImageMediaAttachment;
@class TGModernViewContext;

@class TGModernButtonViewModel;
@class TGMessageImageViewModel;
@class TGModernFlatteningViewModel;
@class TGInlineVideoModel;
@class TGTextMessageBackgroundViewModel;
@class TGModernTextViewModel;
@class TGWebPageMediaAttachment;
@class TGInvoiceMediaAttachment;

@interface TGImageMessageViewModel : TGMessageViewModel
{
    @protected
    TGMessage *_message;
    
    bool _mediaIsAvailable;
    TGModernFlatteningViewModel *_contentModel;
    bool _canDownload;
    TGTextMessageBackgroundViewModel *_backgroundModel;
    TGModernTextViewModel *_textModel;
    TGModernTextViewModel *_adminModel;
    
    bool _ignoreMessageLifetime;
    
    NSString *_nextCaption;
    bool _ignoreEditing;
    CTFontRef _captionFont;
}

@property (nonatomic, strong) TGMessageImageViewModel *imageModel;

@property (nonatomic) bool previewEnabled;
@property (nonatomic) bool isSecret;

- (instancetype)initWithMessage:(TGMessage *)message imageInfo:(TGImageInfo *)imageInfo authorPeer:(id)authorPeer context:(TGModernViewContext *)context forwardPeer:(id)forwardPeer forwardAuthor:(id)forwardAuthor forwardMessageId:(int32_t)forwardMessageId replyHeader:(TGMessage *)replyHeader replyAuthor:(id)replyAuthor viaUser:(TGUser *)viaUser;
- (instancetype)initWithMessage:(TGMessage *)message imageInfo:(TGImageInfo *)imageInfo authorPeer:(id)authorPeer context:(TGModernViewContext *)context forwardPeer:(id)forwardPeer forwardAuthor:(id)forwardAuthor forwardMessageId:(int32_t)forwardMessageId replyHeader:(TGMessage *)replyHeader replyAuthor:(id)replyAuthor viaUser:(TGUser *)viaUser caption:(NSString *)caption textCheckingResults:(NSArray *)textCheckingResults;
- (instancetype)initWithMessage:(TGMessage *)message imageInfo:(TGImageInfo *)imageInfo authorPeer:(id)authorPeer context:(TGModernViewContext *)context forwardPeer:(id)forwardPeer forwardAuthor:(id)forwardAuthor forwardMessageId:(int32_t)forwardMessageId replyHeader:(TGMessage *)replyHeader replyAuthor:(id)replyAuthor viaUser:(TGUser *)viaUser caption:(NSString *)caption textCheckingResults:(NSArray *)textCheckingResults webPage:(TGWebPageMediaAttachment *)webPage;

+ (void)calculateImageSizesForImageSize:(in CGSize)imageSize thumbnailSize:(out CGSize *)thumbnailSize renderSize:(out CGSize *)renderSize squareAspect:(bool)squareAspect;
+ (void)calculateImageSizesForImageSize:(in CGSize)imageSize thumbnailSize:(out CGSize *)thumbnailSize renderSize:(out CGSize *)renderSize squareAspect:(bool)squareAspect larger:(bool)larger;


- (CGSize)contentSizeForContainerSize:(CGSize)containerSize needsContentsUpdate:(bool *)needsContentsUpdate infoWidth:(CGFloat)infoWidth;

- (void)updateImageInfo:(TGImageInfo *)imageInfo;
- (void)setAuthorNameColor:(UIColor *)authorNameColor;

- (void)setWebPageFooter:(TGWebPageMediaAttachment *)webPage invoice:(TGInvoiceMediaAttachment *)invoice viewStorage:(TGModernViewStorage *)viewStorage;

- (UIImage *)dateBackground;
- (UIColor *)dateColor;
- (UIImage *)checkPartialImage;
- (UIImage *)checkCompleteImage;
- (int)clockProgressType;
- (CGPoint)dateOffset;
- (bool)instantPreviewGesture;
- (void)activateMedia;
- (void)activateMedia:(bool)instant;
- (int)defaultOverlayActionType;
- (TGMessageGroupPositionFlags)visiblePositionFlags;

- (void)enableInstantPreview;
- (NSString *)defaultAdditionalDataString;

- (void)updateImageOverlay:(bool)animated;
- (void)updateImage;

- (bool)isInstant;

@end
