#import <Foundation/Foundation.h>

#import "TGMessageHole.h"

typedef enum {
    TGVisibleMessageHoleDirectionEarlier,
    TGVisibleMessageHoleDirectionLater
} TGVisibleMessageHoleDirection;

@interface TGVisibleMessageHole : NSObject

@property (nonatomic, strong, readonly) TGMessageHole *hole;
@property (nonatomic, readonly) TGVisibleMessageHoleDirection direction;

- (instancetype)initWithHole:(TGMessageHole *)hole direction:(TGVisibleMessageHoleDirection)direction;

@end
