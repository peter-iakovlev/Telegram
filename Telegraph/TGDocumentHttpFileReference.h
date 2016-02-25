#import <Foundation/Foundation.h>

#import "TGDocumentFileReference.h"

@interface TGDocumentHttpFileReference : NSObject <TGDocumentFileReference>

@property (nonatomic, strong, readonly) NSString *url;

- (instancetype)initWithUrl:(NSString *)url;

@end
