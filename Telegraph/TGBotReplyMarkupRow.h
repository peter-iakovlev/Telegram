#import <Foundation/Foundation.h>

#import "PSCoding.h"

#import "TGBotReplyMarkupButton.h"

@interface TGBotReplyMarkupRow : NSObject <PSCoding>

@property (nonatomic, strong, readonly) NSArray *buttons;

- (instancetype)initWithButtons:(NSArray *)buttons;

@end
