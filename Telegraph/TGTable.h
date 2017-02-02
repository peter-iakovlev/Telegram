#import <Foundation/Foundation.h>

#import "TGDatabaseInterface.h"

@interface TGTable : NSObject

@property (nonatomic, strong, readonly) TGDatabaseInterface *interface;

- (instancetype)initWithInterface:(TGDatabaseInterface *)interface;

@end
