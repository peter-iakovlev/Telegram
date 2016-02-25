#import <Foundation/Foundation.h>

@interface TGGifKeyboardBalancedPartition : NSObject

+ (NSArray *)linearPartitionForSequence:(NSArray *)sequence numberOfPartitions:(NSInteger)numberOfPartitions;

@end
