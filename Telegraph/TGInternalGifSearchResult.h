#import <Foundation/Foundation.h>

#import <LegacyComponents/LegacyComponents.h>

#import "TGWebSearchResult.h"

@interface TGInternalGifSearchResult : NSObject <TGWebSearchResult>

@property (nonatomic, strong, readonly) NSString *url;
@property (nonatomic, strong, readonly) TGDocumentMediaAttachment *document;
@property (nonatomic, strong, readonly) TGImageMediaAttachment *photo;

- (instancetype)initWithUrl:(NSString *)url document:(TGDocumentMediaAttachment *)document photo:(TGImageMediaAttachment *)photo;

@end
