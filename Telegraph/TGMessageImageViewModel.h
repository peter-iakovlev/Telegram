/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGModernViewModel.h"

@interface TGMessageImageViewModel : TGModernViewModel

@property (nonatomic) bool mediaVisible;

@property (nonatomic, strong) NSString *uri;

@property (nonatomic) int overlayType;
@property (nonatomic) float progress;
@property (nonatomic) bool timestampHidden;
@property (nonatomic) bool isBroadcast;

@property (nonatomic, strong) NSArray *detailStrings;

- (instancetype)initWithUri:(NSString *)uri;

- (void)setOverlayType:(int)overlayType animated:(bool)animated;
- (void)setProgress:(float)progress animated:(bool)animated;
- (void)setSecretProgress:(float)progress completeDuration:(NSTimeInterval)completeDuration animated:(bool)animated;
- (void)setTimestampString:(NSString *)timestampString displayCheckmarks:(bool)displayCheckmarks checkmarkValue:(int)checkmarkValue animated:(bool)animated;
- (void)setDisplayTimestampProgress:(bool)displayTimestampProgress;
- (void)setAdditionalDataString:(NSString *)additionalDataString;
- (void)setAdditionalDataString:(NSString *)additionalDataString animated:(bool)animated;
- (void)reloadImage:(bool)synchronous;
- (void)setDetailStrings:(NSArray *)detailStrings animated:(bool)animated;

@end
