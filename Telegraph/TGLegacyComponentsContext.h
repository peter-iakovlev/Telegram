#import <Foundation/Foundation.h>

#import <LegacyComponents/LegacyComponents.h>

@interface TGLegacyComponentsContext : NSObject <LegacyComponentsContext>

+ (TGLegacyComponentsContext *)shared;

@end
