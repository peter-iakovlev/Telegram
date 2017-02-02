#import <Foundation/Foundation.h>

#import "TGInstantPage.h"
#import "TL/TLMetaScheme.h"

@interface TGInstantPage (TG)

+ (TGInstantPage *)parse:(TLPage *)pageDescription;

@end
