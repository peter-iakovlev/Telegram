#import "TGDatabaseReadMessagesByDate.h"

@implementation TGDatabaseReadMessagesByDate

- (instancetype)initWithDate:(int32_t)date referenceDateForTimers:(int32_t)referenceDateForTimers {
    self = [super init];
    if (self != nil) {
        _date = date;
        _referenceDateForTimers = referenceDateForTimers;
    }
    return self;
}

@end
