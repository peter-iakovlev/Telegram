#import <LegacyComponents/LegacyComponents.h>

#import <LegacyComponents/ASWatcher.h>

@class TGWallpaperInfo;
@class TGLegacyWallpaperController;
@class TGPresentation;

@protocol TGLegacyWallpaperControllerDelegate <NSObject>

@optional

- (void)wallpaperController:(TGLegacyWallpaperController *)wallpaperController didSelectWallpaperWithInfo:(TGWallpaperInfo *)wallpaperInfo;

@end

@interface TGLegacyWallpaperController : TGViewController <ASWatcher>

@property (nonatomic, strong) ASHandle *actionHandle;

@property (nonatomic, weak) id<TGLegacyWallpaperControllerDelegate> delegate;
@property (nonatomic) bool enableWallpaperAdjustment;
@property (nonatomic, strong) TGPresentation *presentation;

- (instancetype)initWithWallpaperInfo:(TGWallpaperInfo *)wallpaperInfo thumbnailImage:(UIImage *)thumbnailImage;

@end
