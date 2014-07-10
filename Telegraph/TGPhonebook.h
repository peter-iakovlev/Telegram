#import <Foundation/Foundation.h>

@class RACSignal;

@interface TGPhonebook : NSObject

- (RACSignal *)entries;
- (void)requestEntries:(void (^)(NSArray *))completion;

@end
