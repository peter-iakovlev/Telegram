/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGModernGalleryScrollView.h"

@interface TGModernGalleryScrollView ()
{
    
}

@end

@implementation TGModernGalleryScrollView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        self.showsHorizontalScrollIndicator = false;
        self.showsVerticalScrollIndicator = false;
        self.pagingEnabled = true;
    }
    return self;
}

- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    
    id<TGModernGalleryScrollViewDelegate> scrollDelegate = _scrollDelegate;
    [scrollDelegate scrollViewBoundsChanged:bounds];
}

@end
