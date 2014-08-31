#import "TGMediaUsageController.h"

#import "TGDatabase.h"

@interface TGMediaUsageData : NSObject

@property (nonatomic) NSUInteger photoCount;
@property (nonatomic) NSUInteger photoSize;

@property (nonatomic) NSUInteger videoCount;
@property (nonatomic) NSUInteger videoSize;

@property (nonatomic) NSUInteger audioCount;
@property (nonatomic) NSUInteger audioSize;

@property (nonatomic) NSUInteger fileCount;
@property (nonatomic) NSUInteger fileSize;

@end

@implementation TGMediaUsageData

@end

@interface TGMediaUsageItem : NSObject

@property (nonatomic, strong) TGMediaUsageData *usageData;

@end

@implementation TGMediaUsageItem

@end

@interface TGMediaUsageController ()
{
    NSMutableArray *_isCancelled;
}

@end

@implementation TGMediaUsageController

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        self.title = TGLocalized(@"DiskUsage.Title");
        
        _isCancelled = [[NSMutableArray alloc] init];
        NSMutableArray *isCancelled = _isCancelled;
        __weak TGMediaUsageController *weakSelf = self;
        [TGDatabaseInstance() findAllMediaMessages:^(NSArray *messages)
        {
            [TGMediaUsageController lookupUsageDataWithMessages:messages completion:^(NSArray *usageDataArray)
            {
                __strong TGMediaUsageController *strongSelf = weakSelf;
                [strongSelf _updateUsageData:usageDataArray];
            } isCancelled:^bool
            {
                return isCancelled.count != 0;
            }];
            __strong TGMediaUsageController *strongSelf = weakSelf;
            
        } isCancelled:^bool
        {
            return isCancelled.count != 0;
        }];
    }
    return self;
}

- (void)dealloc
{
    [_isCancelled addObject:@(1)];
}

+ (void)lookupUsageDataWithMessages:(NSArray *)messages completion:(void (^)(NSArray *))completion isCancelled:(bool (^)())isCancelled
{
    TGLog(@"%d messages", messages.count);
    NSMutableDictionary *messageDataByConversation = [[NSMutableDictionary alloc] init];
    
    for (TGMessage *message in messages)
    {
        //TGMediaUsageData *usageData =
    }
}

- (void)_updateUsageData:(NSArray *)mediaUsageData
{
    
}

@end
