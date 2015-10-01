#import <Foundation/Foundation.h>

#import "PSCoding.h"

#import "TGBotReplyMarkupRow.h"

@interface TGBotReplyMarkup : NSObject <PSCoding>

@property (nonatomic, readonly) int32_t userId;
@property (nonatomic, readonly) int32_t messageId;
@property (nonatomic, strong, readonly) NSArray *rows;
@property (nonatomic) bool matchDefaultHeight;
@property (nonatomic) bool hideKeyboardOnActivation;
@property (nonatomic) bool alreadyActivated;

- (instancetype)initWithUserId:(int32_t)userId messageId:(int32_t)messageId rows:(NSArray *)rows matchDefaultHeight:(bool)matchDefaultHeight hideKeyboardOnActivation:(bool)hideKeyboardOnActivation alreadyActivated:(bool)alreadyActivated;

- (TGBotReplyMarkup *)activatedMarkup;

@end
