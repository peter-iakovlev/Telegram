#import <Foundation/Foundation.h>
#import <SSignalKit/SSignalKit.h>

#import "MediaResource.h"
#import "MediaBoxContexts.h"

@interface MediaBox : NSObject

- (_Nonnull instancetype)initWithBasePath:(NSString * _Nonnull)basePath;
- (void)setFetchResource:(SSignal * _Nonnull (^ _Nonnull)(id<MediaResource> _Nonnull, NSRange))fetchResource;
- (SSignal * _Nonnull)resourceStatus:(id<MediaResource> _Nonnull)resource;
- (SSignal * _Nonnull)resourceData:(id<MediaResource> _Nonnull)resource pathExtension:(NSString * _Nullable)pathExtension;
- (SSignal * _Nonnull)fetchedResource:(id<MediaResource> _Nonnull)resource;
- (void)cancelInteractiveResourceFetch:(id<MediaResource> _Nonnull)resource;

@end
