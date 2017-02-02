#import <TGViewController.h>

@class TGMessage;

@interface TGWebAppControllerShareGameData : NSObject

@property (nonatomic, readonly) int64_t peerId;
@property (nonatomic, readonly) int32_t messageId;
@property (nonatomic, strong, readonly) NSString *botName;
@property (nonatomic, strong, readonly) NSString *shareName;

- (instancetype)initWithPeerId:(int64_t)peerId messageId:(int32_t)messageId botName:(NSString *)botName shareName:(NSString *)shareName;

@end

@interface TGWebAppController : TGViewController

@property (nonatomic, strong) TGWebAppControllerShareGameData *shareGameData;

- (instancetype)initWithUrl:(NSURL *)url title:(NSString *)title botName:(NSString *)botName peerIdForActivityUpdates:(int64_t)peerIdForActivityUpdates peerAccessHashForActivityUpdates:(int64_t)peerAccessHashForActivityUpdates;

+ (void)presentShare:(TGWebAppControllerShareGameData *)shareGameData parentController:(UIViewController *)parentController withScore:(bool)withScore;

@end
