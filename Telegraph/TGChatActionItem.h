#import <Foundation/Foundation.h>

@interface TGChatActionItem : NSObject

@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) UIImage *icon;
@property (nonatomic, readonly) NSString *alt;
@property (nonatomic, readonly) NSArray *subitems;
@property (nonatomic, copy) void (^action)(void);

- (instancetype)initWithTitle:(NSString *)title icon:(UIImage *)icon alt:(NSString *)alt subitems:(NSArray *)subitmes action:(void (^)(void))action;

@end
