//
//  GDParentOperation.h
//  
//
//  Created by Graham Dennis on 6/07/13.
//
//

#import <Foundation/Foundation.h>

extern NSError *GDOperationCancelledError;

@interface GDParentOperation : NSOperation

- (void)addChildOperation:(NSOperation *)operation;

- (void)finish;

@property (nonatomic) dispatch_queue_t successCallbackQueue;
@property (nonatomic) dispatch_queue_t failureCallbackQueue;

@end
