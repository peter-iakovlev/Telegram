#import <UIKit/UIKit.h>

@class TGCallSession;

@interface TGCallDebugView : UIView

@property (nonatomic, copy) void (^dismissBlock)(void);
@property (nonatomic, copy) void (^valuesChanged)(NSInteger bitrate, NSInteger packetLoss, bool p2p);

- (instancetype)initWithFrame:(CGRect)frame callSession:(TGCallSession *)session;

- (void)setBitrate:(NSInteger)bitrate packetLoss:(NSInteger)packetLoss p2p:(bool)p2p;

@end
