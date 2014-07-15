/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGImageView.h"

#import "TGModernView.h"

typedef enum {
    TGMessageImageViewOverlayNone = 0,
    TGMessageImageViewOverlayProgress = 1,
    TGMessageImageViewOverlayDownload = 2,
    TGMessageImageViewOverlayPlay = 3
} TGMessageImageViewOverlay;

typedef enum {
    TGMessageImageViewActionDownload = 0,
    TGMessageImageViewActionCancelDownload = 1,
    TGMessageImageViewActionPlay = 2
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
@property (nonatomic) float progress;

- (UIImage *)currentImage;

- (void)setOverlayType:(int)overlayType animated:(bool)animated;
- (void)setProgress:(float)progress animated:(bool)animated;
- (void)setTimestampHidden:(bool)timestampHidden;
- (void)setTimestampString:(NSString *)timestampString displayCheckmarks:(bool)displayCheckmarks checkmarkValue:(int)checkmarkValue animated:(bool)animated;
- (void)setAdditionalDataString:(NSString *)additionalDataString;
- (void)setDisplayTimestampProgress:(bool)displayTimestampProgress;

@end
