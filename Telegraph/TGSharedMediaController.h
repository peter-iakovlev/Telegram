#import "TGViewController.h"

typedef enum {
    TGSharedMediaControllerModeAll,
    TGSharedMediaControllerModePhoto,
    TGSharedMediaControllerModeVideo,
    TGSharedMediaControllerModeFile,
    TGSharedMediaControllerModeLink,
    TGSharedMediaControllerModeAudio,
    TGSharedMediaControllerModeVoiceRound
} TGSharedMediaControllerMode;

@interface TGSharedMediaController : TGViewController

@property (nonatomic) bool channelAllowDelete;
@property (nonatomic) bool isChannelGroup;

@property (nonatomic, readonly) int64_t peerId;
@property (nonatomic, assign) TGSharedMediaControllerMode mode;

- (instancetype)initWithPeerId:(int64_t)peerId accessHash:(int64_t)accessHash important:(bool)important;
- (instancetype)initWithPeerId:(int64_t)peerId accessHash:(int64_t)accessHash mode:(TGSharedMediaControllerMode)mode important:(bool)important;

+ (NSArray *)thumbnailColorsForFileName:(NSString *)fileName;

@end
