#import <Foundation/Foundation.h>

@interface TGExternalImageSearchResult : NSObject

@property (nonatomic, strong, readonly) NSString *url;
@property (nonatomic, strong, readonly) NSString *originalUrl;
@property (nonatomic, strong, readonly) NSString *thumbnailUrl;
@property (nonatomic, strong, readonly) NSString *title;
@property (nonatomic, readonly) CGSize size;

- (instancetype)initWithUrl:(NSString *)url originalUrl:(NSString *)originalUrl thumbnailUrl:(NSString *)thumbnailUrl title:(NSString *)title size:(CGSize)size;

@end
