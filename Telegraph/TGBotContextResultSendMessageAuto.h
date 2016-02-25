#import <Foundation/Foundation.h>

@interface TGBotContextResultSendMessageAuto : NSObject

@property (nonatomic, strong, readonly) NSString *caption;

- (instancetype)initWithCaption:(NSString *)caption;

@end
