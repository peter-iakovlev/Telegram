#import <Foundation/Foundation.h>

typedef enum {
    TGModernConversationTitleIconPositionBeforeTitle = 0,
    TGModernConversationTitleIconPositionAfterTitle = 1
} TGModernConversationTitleIconPosition;

@interface TGModernConversationTitleIcon : NSObject

@property (nonatomic, strong) UIImage *image;
@property (nonatomic) CGRect bounds;
@property (nonatomic) CGFloat offsetWeight;
@property (nonatomic) CGPoint imageOffset;
@property (nonatomic) TGModernConversationTitleIconPosition iconPosition;

@end
