#import <Foundation/Foundation.h>

@class TGWebPageMediaAttachment;
@class TGLocationMediaAttachment;

@interface TGOpenInAppItem : NSObject

@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSInteger storeIdentifier;
@property (nonatomic, readonly) UIImage *appIcon;

@property (nonatomic, readonly) id object;
@property (nonatomic, readonly) NSDictionary *userInfo;

@property (nonatomic, readonly) bool suppressSafariItem;

- (instancetype)initWithObject:(id)object userInfo:(NSDictionary *)userInfo;

+ (NSArray *)appItemsForURL:(NSURL *)url;
+ (NSArray *)appItemsForWebPageAttachment:(TGWebPageMediaAttachment *)webPage;
+ (NSArray *)appItemsForLocationAttachment:(TGLocationMediaAttachment *)location directions:(bool)directions;

- (void)performOpenIn;

+ (bool)canOpen:(id)object;
+ (NSString *)defaultURLScheme;
+ (bool)isAvailable;

+ (void)openURL:(NSURL *)url;

@end

extern NSString *const TGOpenInEmbedURLKey;