#import <Foundation/Foundation.h>

#import "TGWebSearchResult.h"

@interface TGExternalGifSearchResult : NSObject <TGWebSearchResult>

@property (nonatomic, strong, readonly) NSString *url;
@property (nonatomic, strong, readonly) NSString *originalUrl;
@property (nonatomic, strong, readonly) NSString *thumbnailUrl;
@property (nonatomic, readonly) CGSize size;

- (instancetype)initWithUrl:(NSString *)url originalUrl:(NSString *)originalUrl thumbnailUrl:(NSString *)thumbnailUrl size:(CGSize)size;

@end
