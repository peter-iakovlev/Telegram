#import <Foundation/Foundation.h>

@class TGMessage;

typedef enum {
    TGMessageGroupPositionNone = 0,
    TGMessageGroupPositionTop = 1 << 0,
    TGMessageGroupPositionBottom = 1 << 1,
    TGMessageGroupPositionLeft = 1 << 2,
    TGMessageGroupPositionRight = 1 << 3,
    TGMessageGroupPositionInside = 1 << 4,
    TGMessageGroupPositionUnknown = 1 << 16
} TGMessageGroupPositionFlags;

@interface TGMessageGroupedLayout : NSObject


@property (nonatomic, readonly) CGSize dimensions;
@property (nonatomic, readonly) NSUInteger count;

- (instancetype)initWithMessages:(NSArray *)messages larger:(bool)larger;

- (CGRect)frameForMessageId:(int32_t)mid;
- (TGMessageGroupPositionFlags)positionForMessageId:(int32_t)mid;
- (void)enumerateMessageFrames:(void (^)(int32_t, CGRect))enumerationBlock;

- (int32_t)messageIdForPosition:(TGMessageGroupPositionFlags)position;

- (TGMessageGroupedLayout *)groupedLayoutAfterMessageUpdate:(TGMessage *)message previousMessage:(TGMessage *)previousMessage;

@end
