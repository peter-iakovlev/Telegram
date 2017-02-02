#import "TGOpenInAppItem.h"

@interface TGOpenInLocationItem : TGOpenInAppItem

+ (NSArray *)appItemsForLocationAttachment:(TGLocationMediaAttachment *)location directions:(bool)directions;

@end
