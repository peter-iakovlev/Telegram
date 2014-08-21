/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGModernRemoteImageView.h"

@interface TGModernRemoteImageView ()

@property (nonatomic, strong) NSString *viewIdentifier;
@property (nonatomic, strong) NSString *viewStateIdentifier;

@end

@implementation TGModernRemoteImageView

- (void)willBecomeRecycled
{
    [self prepareForRecycle];
}

- (NSString *)viewStateIdentifier
{
    return [[NSString alloc] initWithFormat:@"TGModernRemoteImageView/%@/%@", self.currentUrl, self.currentFilter];
}

- (void)setViewStateIdentifier:(NSString *)__unused viewStateIdentifier
{
}

@end
