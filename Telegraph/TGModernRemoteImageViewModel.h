/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGModernViewModel.h"

@interface TGModernRemoteImageViewModel : TGModernViewModel

@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *filter;
@property (nonatomic, strong) UIImage *placeholder;
@property (nonatomic) bool fadeTransition;
@property (nonatomic) NSTimeInterval fadeTransitionDuration;
@property (nonatomic) int flags;

- (instancetype)initWithUrl:(NSString *)url filter:(NSString *)filter;

- (void)invalidateImage;
- (void)invalidateImage:(bool)animated;

@end
