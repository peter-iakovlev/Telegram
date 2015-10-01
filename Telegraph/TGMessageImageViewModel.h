/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGModernViewModel.h"

typedef enum {
    TGMessageImageViewTimestampPositionDefault = 0,
    TGMessageImageViewTimestampPositionLeft = 1,
    TGMessageImageViewTimestampPositionRight = 2
} TGMessageImageViewTimestampPosition;

@class TGImageView;

@interface TGMessageImageViewModel : TGModernViewModel

@property (nonatomic) bool mediaVisible;
@property (nonatomic) bool expectExtendedEdges;

@property (nonatomic, strong) NSString *uri;

@property (nonatomic) CGFloat overlayDiameter;
@property (nonatomic) UIColor *overlayBackgroundColorHint;
@property (nonatomic) int overlayType;
@property (nonatomic) CGFloat progress;
@property (nonatomic) bool timestampHidden;
@property (nonatomic) bool isBroadcast;

@property (nonatomic, strong) NSArray *detailStrings;
@property (nonatomic) UIEdgeInsets detailStringsInsets;

@property (nonatomic, copy) void (^progressBlock)(TGImageView *, CGFloat);
@property (nonatomic, copy) void (^completionBlock)(TGImageView *);

- (instancetype)initWithUri:(NSString *)uri;

- (void)setOverlayType:(int)overlayType animated:(bool)animated;
- (void)setProgress:(CGFloat)progress animated:(bool)animated;
- (void)setSecretProgress:(CGFloat)progress completeDuration:(NSTimeInterval)completeDuration animated:(bool)animated;
- (void)setTimestampColor:(UIColor *)color;
- (void)setTimestampString:(NSString *)timestampString displayCheckmarks:(bool)displayCheckmarks checkmarkValue:(int)checkmarkValue displayViews:(bool)displayViews viewsValue:(int)viewsValue animated:(bool)animated;
- (void)setTimestampPosition:(TGMessageImageViewTimestampPosition)timestampPosition;
- (void)setDisplayTimestampProgress:(bool)displayTimestampProgress;
- (void)setAdditionalDataString:(NSString *)additionalDataString;
- (void)setAdditionalDataString:(NSString *)additionalDataString animated:(bool)animated;
- (void)reloadImage:(bool)synchronous;
- (void)setDetailStrings:(NSArray *)detailStrings detailStringsInsets:(UIEdgeInsets)detailStringsInsets animated:(bool)animated;

@end
