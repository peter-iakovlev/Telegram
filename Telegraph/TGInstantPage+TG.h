#import <Foundation/Foundation.h>

#import <LegacyComponents/LegacyComponents.h>

#import "TL/TLMetaScheme.h"

@interface TGInstantPage (TG)

+ (TGInstantPage *)parse:(TLPage *)pageDescription webpageUrl:(NSString *)webpageUrl;

@end
