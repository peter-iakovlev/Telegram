/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGImageView.h"

#import <SSignalKit/SSignalKit.h>
#import <AVFoundation/AVFoundation.h>

#import "TGModernView.h"
#import "TGModernGalleryVideoView.h"

typedef enum {
    TGMessageImageViewOverlayNone = 0,
    TGMessageImageViewOverlayProgress = 1,
    TGMessageImageViewOverlayDownload = 2,
    TGMessageImageViewOverlayPlay = 3,
    TGMessageImageViewOverlaySecret = 4,
    TGMessageImageViewOverlaySecretViewed = 5,
    TGMessageImageViewOverlaySecretProgress = 6,
    TGMessageImageViewOverlayProgressNoCancel = 7,
    TGMessageImageViewOverlayPlayMedia = 8,
    TGMessageImageViewOverlayPauseMedia = 9
} TGMessageImageViewOverlay;

typedef enum {
    TGMessageImageViewActionDownload = 0,
    TGMessageImageViewActionCancelDownload = 1,
    TGMessageImageViewActionPlay = 2,
    TGMessageImageViewActionSecret = 3
} TGMessageImageViewActionType;

@class TGMessageImageView;

@protocol TGMessageImageViewDelegate <NSObject>

@optional

- (void)messageImageViewActionButtonPressed:(TGMessageImageView *)messageImageView withAction:(TGMessageImageViewActionType)action;

@end

@interface TGMessageImageViewContainer : UIView <TGModernView>

@property (nonatomic, strong) TGMessageImageView *imageView;

@end

@interface TGMessageImageView : TGImageView <TGModernView>

@property (nonatomic, weak) id<TGMessageImageViewDelegate> delegate;

@property (nonatomic) int overlayType;
@property (nonatomic) CGFloat progress;
@property (nonatomic) NSTimeInterval completeDuration;
@property (nonatomic, strong) UIColor *overlayBackgroundColorHint;
@property (nonatomic) UIEdgeInsets inlineVideoInsets;
@property (nonatomic) CGSize inlineVideoSize;
@property (nonatomic) CGFloat inlineVideoCornerRadius;
@property (nonatomic) bool flexibleTimestamp;

@property (nonatomic, copy) void (^progressBlock)(TGImageView *, CGFloat);
@property (nonatomic, copy) void (^completionBlock)(TGImageView *);

- (void)setBlurlessOverlay:(bool)blurless;
- (void)setOverlayDiameter:(CGFloat)overlayDiameter;
- (void)setOverlayType:(int)overlayType animated:(bool)animated;
- (void)setProgress:(CGFloat)progress animated:(bool)animated;
- (void)setSecretProgress:(CGFloat)progress completeDuration:(NSTimeInterval)completeDuration animated:(bool)animated;
- (void)setTimestampColor:(UIColor *)color;
- (void)setTimestampHidden:(bool)timestampHidden;
- (void)setTimestampPosition:(int)timestampPosition;
- (void)setTimestampString:(NSString *)timestampString signatureString:(NSString *)signatureString displayCheckmarks:(bool)displayCheckmarks checkmarkValue:(int)checkmarkValue displayViews:(bool)displayViews viewsValue:(int)viewsValue animated:(bool)animated;
- (void)setAdditionalDataString:(NSString *)additionalDataString animated:(bool)animated;
- (void)setAdditionalDataPosition:(int)additionalDataPosition;
- (void)setDisplayTimestampProgress:(bool)displayTimestampProgress;
- (void)setTimestampOffset:(CGPoint)timestampOffset;
- (void)setIsBroadcast:(bool)isBroadcast;
- (void)setDetailStrings:(NSArray *)detailStrings detailStringsEdgeInsets:(UIEdgeInsets)detailStringsEdgeInsets animated:(bool)animated;

- (void)setVideoPathSignal:(SSignal *)signal;
- (void)showVideo;
- (void)hideVideo;

- (void)setVideoView:(TGModernGalleryVideoView *)videoView;

@end
