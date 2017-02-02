#import "TGSharedMediaItemView.h"

#import <SSignalKit/SSignalKit.h>

@class TGMessage;
@class TGModernTextViewModel;
@class TGWebPageMediaAttachment;

@interface TGSharedMediaLinkItemView : TGSharedMediaItemView

@property (nonatomic, weak) UIView *alertViewHost;

- (void)setMessage:(TGMessage *)message date:(int)date lastInSection:(bool)lastInSection textModel:(TGModernTextViewModel *)textModel imageSignal:(SSignal *)imageSignal links:(NSArray *)links webPage:(TGWebPageMediaAttachment *)webPage;

- (NSURL *)urlForLocation:(CGPoint)location;

@end
