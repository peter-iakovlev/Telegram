#import <Foundation/Foundation.h>

#import "PSCoding.h"

#import "TGBotReplyMarkupButton.h"

@interface TGBotReplyMarkupRow : NSObject <PSCoding, NSCoding>

@property (nonatomic, strong, readonly) NSArray *buttons;

- (instancetype)initWithButtons:(NSArray *)buttons;

@end
