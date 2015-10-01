#import <SSignalKit/SSignalKit.h>

#import "TL/TLMetaScheme.h"

@interface TGRemoteFileDataEvent : NSObject

@property (nonatomic, strong, readonly) NSData *data;

- (instancetype)initWithData:(NSData *)data;

@end

@interface TGRemoteFileProgressEvent : NSObject

@property (nonatomic, readonly) CGFloat progress;

- (instancetype)initWithProgress:(CGFloat)progress;

@end

@interface TGRemoteFileSignal : NSObject

/**
 @abstract returns signal of TGRemoteFileEvent, reperesenting file parts
 */
+ (SSignal *)partsForLocation:(TLInputFileLocation *)location datacenterId:(NSInteger)datacenterId size:(NSUInteger)size;
+ (SSignal *)dataForLocation:(TLInputFileLocation *)location datacenterId:(NSInteger)datacenterId size:(NSUInteger)size reportProgress:(bool)reportProgress;

@end
