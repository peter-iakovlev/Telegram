#import <UIKit/UIKit.h>

@class TGViewController;
@class TGDocumentMediaAttachment;

@class TGModernConversationAssociatedInputPanel;

@protocol TGNotificationReplyPanelDelegate;

@interface TGNotificationReplyPanelView : UIView

@property (nonatomic, weak) id<TGNotificationReplyPanelDelegate> delegate;
@property (nonatomic, readonly) NSString *text;

- (instancetype)initWithFrame:(CGRect)frame;
- (CGFloat)heightForWidth:(CGFloat)width;

- (void)setAssociatedStickerList:(NSDictionary *)stickerList;
- (void)setAssociatedPanel:(TGModernConversationAssociatedInputPanel *)associatedPanel animated:(bool)animated;
- (TGModernConversationAssociatedInputPanel *)associatedPanel;

- (void)replaceMention:(NSString *)mention;
- (void)replaceHashtag:(NSString *)hashtag;

- (bool)hasUnsavedData;
- (bool)isIdle;

- (void)refreshHeight;

- (void)localizationUpdated;
- (void)reset;

@end


@protocol TGNotificationReplyPanelDelegate <NSObject>

- (bool)inputPanelShouldBecomeFirstResponder:(TGNotificationReplyPanelView *)inputPanel;
- (void)inputPanelRequestedSendText:(TGNotificationReplyPanelView *)inputPanel text:(NSString *)text;
- (void)inputPanelMentionEntered:(TGNotificationReplyPanelView *)inputTextPanel mention:(NSString *)mention startOfLine:(bool)startOfLine;
- (void)inputPanelHashtagEntered:(TGNotificationReplyPanelView *)inputTextPanel hashtag:(NSString *)hashtag;
- (void)inputPanelRequestedSendSticker:(TGNotificationReplyPanelView *)inputTextPanel sticker:(TGDocumentMediaAttachment *)sticker;
- (void)inputPanelRequestedSendGif:(TGNotificationReplyPanelView *)inputTextPanel document:(TGDocumentMediaAttachment *)document;
- (void)inputPanelWillChangeHeight:(TGNotificationReplyPanelView *)inputPanel height:(CGFloat)height duration:(NSTimeInterval)duration animationCurve:(int)animationCurve;
- (TGViewController *)inputPanelParentViewController:(TGNotificationReplyPanelView *)inputTextPanel;

@optional
- (void)inputPanelTextChanged:(TGNotificationReplyPanelView *)inputTextPanel text:(NSString *)text;

@end

