//
//  RMIntroPageView.m
//  IntroOpenGL
//
//  Created by Ilya Rimchikov on 05.12.13.
//  Copyright (c) 2013 Ilya Rimchikov. All rights reserved.
//

#import "RMIntroPageView.h"

#import "RMGeometry.h"

#define IPAD     UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad

#define dDeviceOrientation [[UIDevice currentDevice] orientation]
#define isPortrait  UIDeviceOrientationIsPortrait(dDeviceOrientation)
#define isLandscape UIDeviceOrientationIsLandscape(dDeviceOrientation)

//#define STATUS_HEIGHT [[UIDevice currentDevice] systemVersion]>=7 ? 0 : 10;

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define _(n) NSLocalizedString(n, nil)

@implementation RMIntroPageView


- (id)initWithFrame:(CGRect)frame headline:(NSString*)headline description:(NSString*)description
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        
        //self.backgroundColor=[UIColor redColor];
        self.opaque=YES;
        _headline=headline;
        
        UILabel *headlineLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, 64+8)];
        headlineLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:IPAD ? 96/2 : 36];
        headlineLabel.text = _headline;
        headlineLabel.textAlignment = NSTextAlignmentCenter;
        headlineLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
        
      
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.lineSpacing = IPAD ? 6 : 5;
        style.lineBreakMode = NSLineBreakByWordWrapping;
        style.alignment = NSTextAlignmentCenter;
        
        
        
        
        
        NSMutableArray *boldRanges = [[NSMutableArray alloc] init];
        
        NSMutableString *cleanText = [[NSMutableString alloc] initWithString:description];
        while (true)
        {
            NSRange startRange = [cleanText rangeOfString:@"**"];
            if (startRange.location == NSNotFound)
                break;
            
            [cleanText deleteCharactersInRange:startRange];
            
            NSRange endRange = [cleanText rangeOfString:@"**"];
            if (endRange.location == NSNotFound)
                break;
            
            [cleanText deleteCharactersInRange:endRange];
            
            [boldRanges addObject:[NSValue valueWithRange:NSMakeRange(startRange.location, endRange.location - startRange.location)]];
        }
        
        
        
        _description = [[NSMutableAttributedString alloc]initWithString:cleanText];
        NSDictionary *boldAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [UIFont fontWithName:@"HelveticaNeue-Medium" size:IPAD ? 44/2 : 17], NSFontAttributeName, nil];
        for (NSValue *nRange in boldRanges)
        {
            [_description addAttributes:boldAttributes range:[nRange rangeValue]];
        }
        
        
        [_description addAttribute:NSParagraphStyleAttributeName
                             value:style
                             range:NSMakeRange(0, _description.length)];
        int padding=10;
        UILabel *descriptionLabel = [[UILabel alloc]initWithFrame:CGRectMake(padding, 45+ 25 + (IPAD ? 22 : 0), frame.size.width-padding*2, 120+8+5)];
        //descriptionLabel.backgroundColor = [UIColor lightGrayColor];

        descriptionLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:IPAD ? 44/2 : 17];
        descriptionLabel.attributedText = _description;
        descriptionLabel.numberOfLines=0;
        [descriptionLabel sizeToFit];
        descriptionLabel.frame = CGRectChangedWidth(descriptionLabel.frame, frame.size.width-padding*2);
        
        descriptionLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
        [self addSubview:descriptionLabel];
        
        
        [self addSubview:headlineLabel];
        
        
    }
    return self;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
