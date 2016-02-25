#import <Foundation/Foundation.h>

@interface TGHolder : NSObject

@end

@interface TGHolderSet : NSObject

@property (nonatomic, copy) void (^emptyStateChanged)(bool);

- (void)addHolder:(TGHolder *)holder;
- (void)removeHolder:(TGHolder *)holder;

- (bool)isEmpty;

@end
