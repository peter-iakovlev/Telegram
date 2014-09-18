#import "TGExportContactFutureAction.h"

@implementation TGExportContactFutureAction

- (id)initWithContactId:(int)contactId
{
    self = [super initWithType:TGExportContactFutureActionType];
    if (self != nil)
    {
        self.uniqueId = contactId;
    }
    return self;
}

- (int)contactId
{
    return (int)self.uniqueId;
}

- (NSData *)serialize
{
    return [NSData data];
}

- (TGFutureAction *)deserialize:(NSData *)__unused data
{
    return [[TGExportContactFutureAction alloc] initWithContactId:0];
}

@end
