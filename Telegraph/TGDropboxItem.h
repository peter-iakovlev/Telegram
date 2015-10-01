#import <Foundation/Foundation.h>

@interface TGDropboxItem : NSObject

@property (nonatomic, readonly) NSString *fileId;
@property (nonatomic, readonly) NSURL *fileUrl;
@property (nonatomic, readonly) NSURL *previewUrl;
@property (nonatomic, readonly) CGSize previewSize;

@property (nonatomic, readonly) NSString *fileName;
@property (nonatomic, readonly) NSUInteger fileSize;

+ (instancetype)dropboxItemWithDictionary:(NSDictionary *)dictionary;

@end
