#import <SSignalKit/SSignalKit.h>

#import "TGTelegramNetworking.h"

@interface TGUploadFileSignals : NSObject

+ (SSignal *)uploadedFileWithData:(NSData *)data mediaTypeTag:(TGNetworkMediaTypeTag)mediaTypeTag;

@end
