#import <LegacyComponents/LegacyComponents.h>

#import <LegacyComponents/ASWatcher.h>

@interface TGWallpaperListController : TGViewController <ASWatcher>

@property (nonatomic, strong) ASHandle *actionHandle;

@end
