#import "TGModernConversationKeyboardView.h"
#import <SSignalKit/SSignalKit.h>
#import <LegacyComponents/TGStickerKeyboardTabPanel.h>

@class TGViewController;
@class TGDocumentMediaAttachment;

@interface TGStickerKeyboardView : UIView <TGModernConversationKeyboardView>

@property (nonatomic, assign) CGFloat keyboardHeight;
@property (nonatomic) bool enableAnimation;

@property (nonatomic, strong) SSignal *channelInfoSignal;

@property (nonatomic, readonly) bool isGif;

@property (nonatomic, weak) TGViewController *parentViewController;
@property (nonatomic, copy) void (^stickerSelected)(TGDocumentMediaAttachment *);
@property (nonatomic, copy) void (^gifSelected)(TGDocumentMediaAttachment *);
@property (nonatomic, copy) void (^gifTabActive)(bool active);

@property (nonatomic, copy) void (^requestedExpand)(bool expand);
@property (nonatomic, copy) void (^expandInteraction)(CGFloat offset);

- (instancetype)initWithFrame:(CGRect)frame style:(TGStickerKeyboardViewStyle)style;

- (void)sizeToFitForWidth:(CGFloat)width;
- (void)updateIfNeeded;
- (void)showTabPanel;

- (void)updateExpanded;

+ (CGFloat)preferredHeight:(bool)landscape;

@end
