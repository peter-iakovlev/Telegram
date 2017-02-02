/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGModernViewModel.h"

typedef enum {
    TGModernClockProgressTypeOutgoingClock = 0,
    TGModernClockProgressTypeOutgoingMediaClock = 1,
    TGModernClockProgressTypeIncomingClock = 2
} TGModernClockProgressType;

@class TGModernClockProgressView;

@interface TGModernClockProgressViewModel : TGModernViewModel

- (instancetype)initWithType:(TGModernClockProgressType)type;

+ (void)setupView:(TGModernClockProgressView *)view forType:(TGModernClockProgressType)type;

@end
