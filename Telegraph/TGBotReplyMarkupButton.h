#import <Foundation/Foundation.h>

#import "PSCoding.h"

@interface TGBotReplyMarkupButton : NSObject <PSCoding>

@property (nonatomic, strong, readonly) NSString *text;

- (instancetype)initWithText:(NSString *)text;

@end
