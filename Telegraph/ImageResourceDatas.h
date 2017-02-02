#import <Foundation/Foundation.h>

@interface ImageResourceDatas : NSObject

@property (nonatomic, strong, readonly) NSData *thumbnail;
@property (nonatomic, strong, readonly) NSData *fullSize;
@property (nonatomic, readonly) bool complete;

- (instancetype)initWithThumbnail:(NSData *)thumbnail fullSize:(NSData *)fullSize complete:(bool)complete;

@end

@interface FileResourceDatas : NSObject

@property (nonatomic, strong, readonly) NSData *thumbnail;
@property (nonatomic, strong, readonly) NSString *fullSizePath;

- (instancetype)initWithThumbnail:(NSData *)thumbnail fullSizePath:(NSString *)fullSizePath;

@end
