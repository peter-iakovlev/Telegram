#import "TGMenuSheetItemView.h"
#import <SSignalKit/SSignalKit.h>
#import "TGPIPAblePlayerView.h"
#import "TGEmbedPlayerController.h"
#import "TGEmbedPlayerView.h"

@class TGViewController;
@class TGWebPageMediaAttachment;
@class TGDocumentMediaAttachment;

@interface TGEmbedItemView : TGMenuSheetItemView <TGPIPAblePlayerContainerView, TGEmbedPlayerWrapperView>

@property (nonatomic, weak) TGViewController *parentController;
@property (nonatomic, assign) bool hasNoAboutInformation;

@property (nonatomic, copy) void (^onMetadataLoaded)(NSString *title, NSString *subtitle);

- (instancetype)initWithWebPageAttachment:(TGWebPageMediaAttachment *)attachment preview:(bool)preview peerId:(int64_t)peerId messageId:(int32_t)messageId;
- (instancetype)initWithWebPageAttachment:(TGWebPageMediaAttachment *)attachment preview:(bool)preview thumbnailSignal:(SSignal *)thumbnailSignal peerId:(int64_t)peerId messageId:(int32_t)messageId;
- (instancetype)initWithDocumentAttachment:(TGDocumentMediaAttachment *)attachment preview:(bool)preview thumbnailSignal:(SSignal *)thumbnailSignal peerId:(int64_t)peerId messageId:(int32_t)messageId;

@end
