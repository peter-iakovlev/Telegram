#import <Foundation/Foundation.h>

@class TGUser;
@class TGMessage;
@class TGDocumentMediaAttachment;
@class TGBotContextResult;

@interface TGMusicPlayerItem : NSObject

@property (nonatomic, strong, readonly) id<NSObject, NSCopying> key;
@property (nonatomic, strong, readonly) id media;
@property (nonatomic, readonly) int64_t peerId;
@property (nonatomic, strong, readonly) TGUser *author;
@property (nonatomic, readonly) int32_t date;

@property (nonatomic, strong, readonly) NSString *performer;
@property (nonatomic, strong, readonly) NSString *title;
@property (nonatomic, readonly) int32_t duration;

+ (instancetype)itemWithMessage:(TGMessage *)message author:(TGUser *)author;
+ (instancetype)itemWithBotContextResult:(TGBotContextResult *)result;

- (instancetype)initWithKey:(id<NSObject, NSCopying>)key media:(id)media peerId:(int64_t)peerId author:(TGUser *)author date:(int32_t)date performer:(NSString *)performer title:(NSString *)title duration:(int32_t)duration;

- (bool)isVoice;

@end
