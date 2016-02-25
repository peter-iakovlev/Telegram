#import "TGModernConversationInputPanel.h"

@class TGDataItem;
@class TGLiveUploadActorData;
@class TGModernConversationAssociatedInputPanel;
@class TGAudioWaveform;

@interface TGModernConversationAudioPreviewInputPanel : TGModernConversationInputPanel

@property (nonatomic, copy) void (^playbackDidBegin)();

- (instancetype)initWithDataItem:(TGDataItem *)dataItem duration:(NSTimeInterval)duration liveUploadActorData:(TGLiveUploadActorData *)liveUploadActorData waveform:(TGAudioWaveform *)waveform cancel:(void (^)())cancel send:(void (^)(TGDataItem *, NSTimeInterval, TGLiveUploadActorData *, TGAudioWaveform *))send;
- (void)stop;

- (void)setPrimaryExtendedPanel:(TGModernConversationAssociatedInputPanel *)extendedPanel animated:(bool)animated;
- (void)setPrimaryExtendedPanel:(TGModernConversationAssociatedInputPanel *)extendedPanel animated:(bool)animated skipHeightAnimation:(bool)skipHeightAnimation;
- (void)setSecondaryExtendedPanel:(TGModernConversationAssociatedInputPanel *)extendedPanel animated:(bool)animated;

@end
