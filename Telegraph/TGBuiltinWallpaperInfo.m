/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGBuiltinWallpaperInfo.h"

@interface TGBuiltinWallpaperInfo ()
{
    int _builtinId;
    int _tintColor;
    
    CGFloat _systemAlpha;
    CGFloat _buttonsAlpha;
    CGFloat _highlightedButtonAlpha;
    CGFloat _progressAlpha;
}

@end

@implementation TGBuiltinWallpaperInfo

- (instancetype)initWithBuiltinId:(int)builtinId
{
    return [self initWithBuiltinId:builtinId tintColor:0x000000 systemAlpha:0.25f buttonsAlpha:0.35f highlightedButtonAlpha:0.50f progressAlpha:0.35f];
}

- (instancetype)initWithBuiltinId:(int)builtinId tintColor:(int)tintColor systemAlpha:(CGFloat)systemAlpha buttonsAlpha:(CGFloat)buttonsAlpha highlightedButtonAlpha:(CGFloat)highlightedButtonAlpha progressAlpha:(CGFloat)progressAlpha
{
    self = [super init];
    if (self != nil)
    {
        _builtinId = builtinId;
        _tintColor = tintColor;
        _systemAlpha = systemAlpha;
        _buttonsAlpha = buttonsAlpha;
        _highlightedButtonAlpha = highlightedButtonAlpha;
        _progressAlpha = progressAlpha;
    }
    return self;
}

- (BOOL)isDefault
{
    return _builtinId == 0;
}

- (NSString *)thumbnailUrl
{
    return [[NSString alloc] initWithFormat:@"builtin-wallpaper://?id=%d&size=thumbnail", _builtinId];
}

- (NSString *)fullscreenUrl
{
    return [[NSString alloc] initWithFormat:@"builtin-wallpaper://?id=%d", _builtinId];
}

- (int)tintColor
{
    return _tintColor;
}

- (CGFloat)systemAlpha
{
    return _systemAlpha;
}

- (CGFloat)buttonsAlpha
{
    return _buttonsAlpha;
}

- (CGFloat)highlightedButtonAlpha
{
    return _highlightedButtonAlpha;
}

- (CGFloat)progressAlpha
{
    return _progressAlpha;
}

- (UIImage *)image
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:[[NSString alloc] initWithFormat:@"%@builtin-wallpaper-%d", [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad ? @"pad-" : @"", _builtinId] ofType:@"jpg"];
    
    return [[UIImage alloc] initWithContentsOfFile:filePath];
}

- (NSData *)imageData
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:[[NSString alloc] initWithFormat:@"%@builtin-wallpaper-%d", [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad ? @"pad-" : @"", _builtinId] ofType:@"jpg"];
    
    return [[NSData alloc] initWithContentsOfFile:filePath];
}

- (bool)hasData
{
    return true;
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[TGBuiltinWallpaperInfo class]])
    {
        if (((TGBuiltinWallpaperInfo *)object)->_builtinId == _builtinId &&
            ((TGBuiltinWallpaperInfo *)object)->_tintColor == _tintColor)
        {
            return true;
        }
    }
    
    return false;
}

- (NSDictionary *)infoDictionary
{
    return @{
         @"_className": NSStringFromClass([self class]),
         @"builtinId": @(_builtinId),
         @"tintColor": @(_tintColor),
         @"systemAlpha": @(_systemAlpha),
         @"buttonsAlpha": @(_buttonsAlpha),
         @"highlightedButtonAlpha": @(_highlightedButtonAlpha),
         @"progressAlpha": @(_progressAlpha)
    };
}

+ (TGWallpaperInfo *)infoWithDictionary:(NSDictionary *)dict
{
    return [[TGBuiltinWallpaperInfo alloc] initWithBuiltinId:[dict[@"builtinId"] intValue] tintColor:[dict[@"tintColor"] intValue] systemAlpha:[dict[@"systemAlpha"] floatValue] buttonsAlpha:[dict[@"buttonsAlpha"] floatValue] highlightedButtonAlpha:[dict[@"highlightedButtonAlpha"] floatValue] progressAlpha:[dict[@"progressAlpha"] floatValue]];
}

@end
