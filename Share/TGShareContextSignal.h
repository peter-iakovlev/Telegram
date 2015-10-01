#import <Foundation/Foundation.h>

#import <SSignalKit/SSignalKit.h>

#import "TGShareContext.h"

@interface TGEncryptedShareContext : NSObject

@property (nonatomic, readonly) bool simplePassword;
@property (nonatomic, copy, readonly) bool (^verifyPassword)(NSString *);

@end

@interface TGShareContextSignal : NSObject

+ (SSignal *)shareContext;

@end
