#import <LegacyComponents/LegacyComponents.h>

#import <LegacyComponents/ASWatcher.h>

@class TGPresentation;

@interface TGWallpaperListController : TGViewController <ASWatcher>

@property (nonatomic, strong) ASHandle *actionHandle;

@property (nonatomic, strong) TGPresentation *presentation;

@end
