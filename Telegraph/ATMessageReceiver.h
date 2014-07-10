#import <Foundation/Foundation.h>

@protocol ATMessageReceiver <NSObject>

- (void)receiveMessage:(id)message sender:(id<ATMessageReceiver>)sender;

@end
