#import <UIKit/UIKit.h>
#import "TGNotificationReplyHeaderView.h"
#import "TGNotificationForwardHeaderView.h"

@class TGMessage;
@class TGConversation;
@class TGMediaAttachment;
@class TGModernViewInlineMediaContext;

@interface TGNotificationPreviewView : UIView
{
    int64_t _conversationId;
    int32_t _messageId;
    id _activeRequestMediaId;
    
    UIImageView *_lockIcon;
    UILabel *_titleLabel;
    UIImageView *_mediaIcon;
    UILabel *_textLabel;
 
    TGNotificationReplyHeaderView *_replyHeader;
    TGNotificationForwardHeaderView *_forwardHeader;
    CGFloat _headerHeight;
    
    CGFloat _textHeight;
    CGFloat _collapsedTextHeight;
    CGSize _currentContainerSize;
    
    CGFloat _titleStartPos;
    CGFloat _titleEndPos;
    CGFloat _textStartPos;
    CGFloat _textEndPos;
    
    CGFloat _expandProgress;
    
    bool _hasExtraContent;
    bool _isPanable;
    bool _isIdle;
}

@property (nonatomic, readonly) id activeRequestMediaId;

@property (nonatomic, copy) id (^requestMedia)(TGMediaAttachment *attachment, int64_t cid, int32_t mid);
@property (nonatomic, copy) void (^cancelMedia)(id mediaId);
@property (nonatomic, copy) void (^playMedia)(TGMediaAttachment *attachment, int64_t cid, int32_t mid);
@property (nonatomic, copy) TGModernViewInlineMediaContext *(^mediaContext)(int64_t cid, int32_t mid);

- (instancetype)initWithMessage:(TGMessage *)message conversation:(TGConversation *)conversation peers:(NSDictionary *)peers;

- (void)setIcon:(UIImage *)icon text:(NSString *)text;
- (void)setExpandProgress:(CGFloat)progress;
@property (nonatomic, readonly) bool isExpandable;
@property (nonatomic, readonly) bool isPanable;

- (bool)isPanableAtPoint:(CGPoint)point;

@property (nonatomic, readonly) bool isIdle;

- (CGFloat)maxContentHeight;

- (void)_updateExpandProgress:(CGFloat)progress hideText:(bool)hideText;

- (void)imageDataInvalidated:(NSString *)imageUrl;
- (void)updateMediaAvailability:(bool)mediaIsAvailable;
- (void)updateProgress:(bool)progressVisible progress:(float)progress animated:(bool)animated;
- (void)updateInlineMediaContext;

- (CGFloat)expandedHeightForContainerSize:(CGSize)containerSize;

- (void)_layoutText;
- (void)_layoutHeaders;

@end

extern const UIEdgeInsets TGNotificationPreviewContentInset;
