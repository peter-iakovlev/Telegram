#import <Foundation/Foundation.h>

@interface TGWeakReference : NSObject

@property (nonatomic, weak) id object;

- (instancetype)initWithObject:(id)object;

@end
