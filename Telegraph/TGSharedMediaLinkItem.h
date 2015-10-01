#import "TGSharedMediaItem.h"

#import <SSignalKit/SSignalKit.h>

@class TGMessage;
@class TGModernTextViewModel;
@class TGWebPageMediaAttachment;

@interface TGSharedMediaLinkItem : NSObject <TGSharedMediaItem>

@property (nonatomic, strong, readonly) TGMessage *message;

- (instancetype)initWithMessage:(TGMessage *)message messageId:(int32_t)messageId date:(NSTimeInterval)date incoming:(bool)incoming;

- (TGModernTextViewModel *)textModel;
- (SSignal *)imageSignal;
- (TGWebPageMediaAttachment *)webPage;
- (NSArray *)links;

@end
