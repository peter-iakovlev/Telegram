#import <Foundation/Foundation.h>

#import <SSignalKit/SSignalKit.h>

#import "TGShareContext.h"

@interface TGUploadMediaSignals : NSObject

+ (SSignal *)uploadPhotoWithContext:(TGShareContext *)context data:(NSData *)data;
+ (SSignal *)uploadFileWithContext:(TGShareContext *)context data:(NSData *)data name:(NSString *)name mimeType:(NSString *)mimeType attributes:(NSArray *)attributes;
+ (SSignal *)uploadVideoWithContext:(TGShareContext *)context data:(NSData *)data thumbData:(NSData *)thumbData duration:(int32_t)duration width:(int32_t)width height:(int32_t)height mimeType:(NSString *)mimeType;

@end
