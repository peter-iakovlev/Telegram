//
//  GDImageCell.m
//  GDFileManagerExample
//
//  Created by Graham Dennis on 2/03/13.
//  Copyright (c) 2013 Graham Dennis. All rights reserved.
//

#import "GDImageCell.h"

@implementation GDImageCell

#define BORDER_WIDTH 20.0

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect imageFrame = CGRectInset(self.contentView.bounds, BORDER_WIDTH, 0.0);
    self.imageView.frame = imageFrame;
    self.imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
}

@end
