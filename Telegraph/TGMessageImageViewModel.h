/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGModernViewModel.h"

@interface TGMessageImageViewModel : TGModernViewModel

@property (nonatomic, strong) NSString *uri;

@property (nonatomic) int overlayType;
@property (nonatomic) float progress;
@property (nonatomic) bool timestampHidden;

- (instancetype)initWithUri:(NSString *)uri;

- (void)setOverlayType:(int)overlayType animated:(bool)animated;
- (void)setProgress:(float)progress animated:(bool)animated;
- (void)setTimestampString:(NSString *)timestampString displayCheckmarks:(bool)displayCheckmarks checkmarkValue:(int)checkmarkValue animated:(bool)animated;
- (void)setDisplayTimestampProgress:(bool)displayTimestampProgress;
- (void)setAdditionalDataString:(NSString *)additionalDataString;
- (void)reloadImage:(bool)synchronous;

@end
