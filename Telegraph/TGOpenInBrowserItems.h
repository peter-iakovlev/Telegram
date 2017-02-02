#import "TGOpenInAppItem.h"

@interface TGOpenInBrowserItem : TGOpenInAppItem

+ (NSArray *)appItemsForURL:(NSURL *)url suppressSafariItem:(bool)suppressSafariItem;

@end
