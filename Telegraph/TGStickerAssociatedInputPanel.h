#import "TGModernConversationAssociatedInputPanel.h"

@class TGViewController;
@class TGDocumentMediaAttachment;

@interface TGStickerAssociatedInputPanel : TGModernConversationAssociatedInputPanel

@property (nonatomic, weak) TGViewController *controller;
@property (nonatomic, copy) void (^documentSelected)(TGDocumentMediaAttachment *);

- (NSArray *)documentList;
- (void)setDocumentList:(NSDictionary *)dictionary;
- (void)setTargetOffset:(CGFloat)targetOffset;

@end
