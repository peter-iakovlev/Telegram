#import <SSignalKit/SSignalKit.h>
#import <LegacyComponents/TGPassportAttachMenu.h>

@interface TGPassportICloud : NSObject

+ (SSignal *)fetchICloudFileWith:(NSURL *)url;

@end
