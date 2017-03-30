#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLKeyboardButton : NSObject <TLObject>

@property (nonatomic, retain) NSString *text;

@end

@interface TLKeyboardButton$keyboardButton : TLKeyboardButton


@end

@interface TLKeyboardButton$keyboardButtonUrl : TLKeyboardButton

@property (nonatomic, retain) NSString *url;

@end

@interface TLKeyboardButton$keyboardButtonCallback : TLKeyboardButton

@property (nonatomic, retain) NSData *data;

@end

@interface TLKeyboardButton$keyboardButtonRequestPhone : TLKeyboardButton


@end

@interface TLKeyboardButton$keyboardButtonRequestGeoLocation : TLKeyboardButton


@end

@interface TLKeyboardButton$keyboardButtonSwitchInline : TLKeyboardButton

@property (nonatomic) int32_t flags;
@property (nonatomic, retain) NSString *query;

@end

@interface TLKeyboardButton$keyboardButtonGame : TLKeyboardButton


@end

@interface TLKeyboardButton$keyboardButtonBuy : TLKeyboardButton


@end

