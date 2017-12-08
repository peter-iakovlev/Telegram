#import "TGCollectionMenuController.h"

typedef enum {
    TGAutoDownloadSettingsModePhotos,
    TGAutoDownloadSettingsModeVideos,
    TGAutoDownloadSettingsModeDocuments,
    TGAutoDownloadSettingsModeVoiceMessages,
    TGAutoDownloadSettingsModeVideoMessages,
    TGAutoDownloadSettingsModeSaveIncomingPhotos,
} TGAutoDownloadSettingsMode;

@interface TGAutoDownloadSettingsController : TGCollectionMenuController

@property (nonatomic, copy) void (^settingsUpdated)(void);

- (instancetype)initWithMode:(TGAutoDownloadSettingsMode)mode;

@end
