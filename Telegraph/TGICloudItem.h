#import <Foundation/Foundation.h>

@interface TGICloudItem : NSObject

@property (nonatomic, readonly) NSString *fileId;
@property (nonatomic, readonly) NSURL *fileUrl;

@property (nonatomic, readonly) NSString *fileName;
@property (nonatomic, readonly) NSUInteger fileSize;

@end

@interface TGICloudItemRequest : NSObject

@property (nonatomic, readonly) bool completed;

+ (instancetype)requestICloudItemWithUrl:(NSURL *)url completion:(void(^)(TGICloudItem *item))completion;

@end
