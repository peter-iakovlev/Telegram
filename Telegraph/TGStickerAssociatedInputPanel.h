#import "TGModernConversationAssociatedInputPanel.h"

@class TGDocumentMediaAttachment;

@interface TGStickerAssociatedInputPanel : TGModernConversationAssociatedInputPanel

@property (nonatomic, copy) void (^documentSelected)(TGDocumentMediaAttachment *);

- (NSArray *)documentList;
- (void)setDocumentList:(NSArray *)documentList;
- (void)setTargetOffset:(CGFloat)targetOffset;

@end
