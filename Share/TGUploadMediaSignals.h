#import <Foundation/Foundation.h>

#import <SSignalKit/SSignalKit.h>

#import "TGShareContext.h"

@interface TGUploadMediaSignals : NSObject

+ (SSignal *)uploadPhotoWithContext:(TGShareContext *)context data:(NSData *)data;
+ (SSignal *)uploadFileWithContext:(TGShareContext *)context data:(NSData *)data name:(NSString *)name mimeType:(NSString *)mimeType attributes:(NSArray *)attributes;

@end
