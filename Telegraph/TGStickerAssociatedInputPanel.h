#import "TGModernConversationAssociatedInputPanel.h"

@class TGViewController;
@class TGDocumentMediaAttachment;

@interface TGStickerAssociatedInputPanel : TGModernConversationAssociatedInputPanel

@property (nonatomic, weak) TGViewController *controller;
@property (nonatomic, copy) void (^documentSelected)(TGDocumentMediaAttachment *);

- (NSArray *)documentList;
- (void)setDocumentList:(NSArray *)documentList;
- (void)setTargetOffset:(CGFloat)targetOffset;

@end
