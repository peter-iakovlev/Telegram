#import <Foundation/Foundation.h>

@protocol MediaResourceId <NSObject, NSCopying>

- (NSString *)uniqueId;

@end

@protocol MediaResource <NSObject>

- (id<MediaResourceId>)resourceId;
- (NSNumber *)size;
- (id)mediaType;

@end

@protocol CachedMediaResourceRepresentation <NSObject, NSCopying>

- (NSString *)uniqueId;

@end

