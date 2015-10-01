#import <SSignalKit/SSignalKit.h>

@interface TGUploadFileSignals : NSObject

+ (SSignal *)uploadedFileWithData:(NSData *)data;

@end
