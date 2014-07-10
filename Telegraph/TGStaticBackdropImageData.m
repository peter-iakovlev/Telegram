/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGStaticBackdropImageData.h"

NSString *TGStaticBackdropMessageActionCircle = @"TGStaticBackdropMessageActionCircle";
NSString *TGStaticBackdropMessageTimestamp = @"TGStaticBackdropMessageTimestamp";
NSString *TGStaticBackdropMessageAdditionalData = @"TGStaticBackdropMessageAdditionalData";

@interface TGStaticBackdropImageData ()
{
    NSMutableDictionary *_areas;
}

@end

@implementation TGStaticBackdropImageData

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        _areas = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (TGStaticBackdropAreaData *)backdropAreaForKey:(NSString *)key
{
    if (key == nil)
        return nil;
    
    return _areas[key];
}

- (void)setBackdropArea:(TGStaticBackdropAreaData *)backdropArea forKey:(NSString *)key
{
    if (key != nil)
    {
        if (backdropArea == nil)
            [_areas removeObjectForKey:key];
        else
            _areas[key] = backdropArea;
    }
}

@end
