/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGWallpaperManager.h"

#import "ActionStage.h"

#import "TGWallpaperInfo.h"
#import "TGColorWallpaperInfo.h"
#import "TGBuiltinWallpaperInfo.h"

#import "TGImageUtils.h"
#import "TGViewController.h"

#import "TGAppDelegate.h"

@interface TGWallpaperManager ()
{
    bool _infoLoaded;
    dispatch_once_t _infoLoadToken;
    
    TGWallpaperInfo *_wallpaperInfo;
    NSData *_wallpaperImageData;
    UIImage *_wallpaperImage;
}

@end

@implementation TGWallpaperManager

+ (instancetype)instance
{
    static TGWallpaperManager *singleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        singleton = [[TGWallpaperManager alloc] init];
    });
    
    return singleton;
}

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
    }
    return self;
}

- (NSString *)_currentWallpaperPath
{
    NSString *documentsDirectory = [TGAppDelegate documentsPath];
    NSString *wallpapersPath = [documentsDirectory stringByAppendingPathComponent:[@"wallpaper-data" stringByAppendingString:[[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone ? @"" : @"-pad"]];
    
    [[NSFileManager defaultManager] createDirectoryAtPath:wallpapersPath withIntermediateDirectories:true attributes:nil error:nil];
    
    return [wallpapersPath stringByAppendingPathComponent:[NSString stringWithFormat:@"_currentWallpaper%@.jpg", [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone ? @"" : @"-pad"]];
}

- (NSString *)_currentWallpaperInfoKey
{
    return @"_currentWallpaperInfo";
}

- (void)_loadInfoIfNecessary:(bool)preloadImage
{
    if (!_infoLoaded)
    {
        dispatch_once(&_infoLoadToken, ^
        {
            NSString *fileName = [self _currentWallpaperPath];
            
            NSDictionary *infoDict = [[NSUserDefaults standardUserDefaults] objectForKey:[self _currentWallpaperInfoKey]];
            TGWallpaperInfo *wallpaperInfo = [TGWallpaperInfo infoWithDictionary:infoDict];
            
            if ([wallpaperInfo hasData])
            {
                _wallpaperImageData = [[NSData alloc] initWithContentsOfFile:fileName options:NSDataReadingMappedIfSafe error:nil];
                
                if (_wallpaperImageData != nil)
                {
                    NSDictionary *infoDict = [[NSUserDefaults standardUserDefaults] objectForKey:[self _currentWallpaperInfoKey]];
                    _wallpaperInfo = [TGWallpaperInfo infoWithDictionary:infoDict];
                }
                
                if ([_wallpaperInfo isKindOfClass:[TGBuiltinWallpaperInfo class]] && ((TGBuiltinWallpaperInfo *)_wallpaperInfo).isDefault && ((TGBuiltinWallpaperInfo *)_wallpaperInfo).version < TGBuilitinWallpaperCurrentVersion)
                    [self setCurrentWallpaperWithInfo:[self builtinWallpaperList][0] force:true];
                else if (_wallpaperInfo == nil)
                    [self setCurrentWallpaperWithInfo:[self builtinWallpaperList][0]];
            }
            else
            {
                _wallpaperImageData = nil;
                _wallpaperInfo = wallpaperInfo;
                
                if (_wallpaperInfo == nil)
                    [self setCurrentWallpaperWithInfo:[self builtinWallpaperList][0]];
                
                _wallpaperImage = [wallpaperInfo image];
            }
            
            _infoLoaded = true;
            
            if (preloadImage && _wallpaperImage == nil && _wallpaperImageData != nil)
            {
                UIImage *rawImage = [[UIImage alloc] initWithData:_wallpaperImageData];
                if (rawImage != nil)
                {
                    _wallpaperImage = TGScaleImageToPixelSize(rawImage, CGSizeMake(rawImage.size.width * rawImage.scale, rawImage.size.height * rawImage.scale));
                }
            }
        });
    }
}

- (void)_storeInfo
{
    if (_wallpaperInfo != nil && (![_wallpaperInfo hasData] || _wallpaperImageData != nil))
    {
        NSDictionary *infoDict = [_wallpaperInfo infoDictionary];
        
        NSString *fileName = [self _currentWallpaperPath];
        
        if (![_wallpaperInfo hasData] || [_wallpaperImageData writeToFile:fileName atomically:true])
        {
            [[NSUserDefaults standardUserDefaults] setObject:infoDict forKey:[self _currentWallpaperInfoKey]];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        else
            TGLog(@"Couldn't write wallpaper image data to file");
    }
}

- (CGSize)preferredWallpaperPixelSize
{
    if (TGIsPad())
    {
        CGSize wallpaperSize = CGSizeMake(634.0f, 1024.0f);
        CGFloat screenScale = [UIScreen mainScreen].scale;
        wallpaperSize.width *= screenScale;
        wallpaperSize.height *= screenScale;
        
        return wallpaperSize;
    }
    else
    {
        CGSize screenSize = [TGViewController screenSizeForInterfaceOrientation:UIInterfaceOrientationPortrait];
        CGFloat screenScale = [UIScreen mainScreen].scale;
        screenSize.width *= screenScale;
        screenSize.height *= screenScale;
        
        return screenSize;
    }
}

- (void)setCurrentWallpaperWithInfo:(TGWallpaperInfo *)wallpaperInfo
{
    [self setCurrentWallpaperWithInfo:wallpaperInfo force:false];
}

- (void)setCurrentWallpaperWithInfo:(TGWallpaperInfo *)wallpaperInfo force:(bool)force
{
    if (force || ![_wallpaperInfo isEqual:wallpaperInfo])
    {
        if ([wallpaperInfo hasData])
        {
            NSData *imageData = [wallpaperInfo imageData];
            
            UIImage *image = [wallpaperInfo image];
            if (image != nil)
            {
                CGSize wallpaperPixelSize = [self preferredWallpaperPixelSize];
                
                CGFloat screenSide = MAX(wallpaperPixelSize.width, wallpaperPixelSize.height);
                CGSize scaledImageSize = CGSizeMake(image.size.width * image.scale, image.size.height * image.scale);
                CGSize desiredImageSize = TGCropSize(TGFillSize(scaledImageSize, wallpaperPixelSize), CGSizeMake(screenSide, screenSide));
                
                if (scaledImageSize.width > desiredImageSize.width + FLT_EPSILON || scaledImageSize.height > desiredImageSize.height + FLT_EPSILON)
                {
                    UIImage *croppedImage = TGFixOrientationAndCrop(image, CGRectMake(CGFloor((scaledImageSize.width - desiredImageSize.width) / 2.0f), CGFloor((scaledImageSize.height - desiredImageSize.height) / 2.0f), desiredImageSize.width, desiredImageSize.height), desiredImageSize);
                    if (croppedImage != nil)
                        imageData = UIImageJPEGRepresentation(croppedImage, 0.98f);
                }
            }
            
            _wallpaperImageData = imageData;
        }
        else
        {
            _wallpaperImageData = nil;
        }
        
        _wallpaperInfo = wallpaperInfo;
        _wallpaperImage = nil;
        
        [self _storeInfo];
        
        [ActionStageInstance() dispatchResource:@"/tg/assets/currentWallpaperInfo" resource:wallpaperInfo];
    }
}

- (UIImage *)currentWallpaperImage
{
    [self _loadInfoIfNecessary:true];
    
    if (_wallpaperImage == nil)
    {
        if ([_wallpaperInfo hasData])
        {
            UIImage *rawImage = [[UIImage alloc] initWithData:_wallpaperImageData];
            if (rawImage != nil)
            {
                _wallpaperImage = TGScaleImageToPixelSize(rawImage, CGSizeMake(rawImage.size.width * rawImage.scale, rawImage.size.height * rawImage.scale));
            }
        }
        else
            _wallpaperImage = [_wallpaperInfo image];
    }
    
    return _wallpaperImage;
}

- (TGWallpaperInfo *)currentWallpaperInfo
{
    [self _loadInfoIfNecessary:false];
    
    return _wallpaperInfo;
}

- (NSArray *)builtinWallpaperList
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < (TGIsPad() ? 3 : 5); i++)
    {
        bool isBlue = i == 0 || i == 4;
        
        int tintColor = isBlue ? 0x748391 : 0x000000;
        CGFloat systemAlpha = 0.25f;
        CGFloat buttonsAlpha = 0.35f;
        CGFloat highlightedButtonAlpha = 0.50f;
        CGFloat progressAlpha = 0.35f;
        if (isBlue)
        {
            systemAlpha = 0.45f;
            buttonsAlpha = 0.6f;
            highlightedButtonAlpha = 0.75f;
            progressAlpha = 0.6f;
        }
     
        if (false && i == 0 && TGIsPad())
        {
            [array addObject:[[TGColorWallpaperInfo alloc] initWithColor:0xffdde3e9 tintColor:tintColor systemAlpha:systemAlpha buttonsAlpha:buttonsAlpha highlightedButtonAlpha:highlightedButtonAlpha progressAlpha:progressAlpha]];
        }
        else
        {
            [array addObject:[[TGBuiltinWallpaperInfo alloc] initWithBuiltinId:i tintColor:tintColor systemAlpha:systemAlpha buttonsAlpha:buttonsAlpha highlightedButtonAlpha:highlightedButtonAlpha progressAlpha:progressAlpha version:TGBuilitinWallpaperCurrentVersion]];
        }
    }
    
    return array;
}

@end
