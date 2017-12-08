#import "TGModernClockProgressViewModel.h"

#import <LegacyComponents/LegacyComponents.h>

#import "TGModernClockProgressView.h"

@interface TGModernClockProgressViewModel ()
{
    TGModernClockProgressType _type;
}

@end

@implementation TGModernClockProgressViewModel

- (instancetype)initWithType:(TGModernClockProgressType)type
{
    self = [super init];
    if (self != nil)
    {
        _type = type;
    }
    return self;
}

- (Class)viewClass
{
    return [TGModernClockProgressView class];
}

+ (CGImageRef)frameImageForType:(TGModernClockProgressType)type
{
    switch (type)
    {
        case TGModernClockProgressTypeOutgoingClock:
        {
            static CGImageRef image = NULL;
            
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^
            {
                UIImage *rawImage = TGImageNamed(@"ClockFrame.png");
                image = CGImageRetain(TGScaleAndRoundCorners(rawImage, CGSizeMake(rawImage.size.width, rawImage.size.height), CGSizeZero, 0, nil, false, nil).CGImage);
            });
            
            return image;
        }
        case TGModernClockProgressTypeOutgoingMediaClock:
        {
            static CGImageRef image = NULL;
            
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^
            {
                UIImage *rawImage = TGImageNamed(@"ClockWhiteFrame.png");
                image = CGImageRetain(TGScaleAndRoundCorners(rawImage, CGSizeMake(rawImage.size.width, rawImage.size.height), CGSizeZero, 0, nil, false, nil).CGImage);
            });
            
            return image;
        }
        case TGModernClockProgressTypeIncomingClock:
        {
            static CGImageRef image = NULL;
            
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^
            {
                UIImage *rawImage = TGImageNamed(@"ClockIncomingFrame.png");
                image = CGImageRetain(TGScaleAndRoundCorners(rawImage, CGSizeMake(rawImage.size.width, rawImage.size.height), CGSizeZero, 0, nil, false, nil).CGImage);
            });
            
            return image;
        }
    }
    
    return nil;
}

+ (CGImageRef)minImageForType:(TGModernClockProgressType)type
{
    switch (type)
    {
        case TGModernClockProgressTypeOutgoingClock:
        {
            static CGImageRef image = NULL;
            
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^
            {
                UIImage *rawImage = TGImageNamed(@"ClockMin.png");
                image = CGImageRetain(TGScaleAndRoundCorners(rawImage, CGSizeMake(rawImage.size.width, rawImage.size.height), CGSizeZero, 0, nil, false, nil).CGImage);
            });
            
            return image;
        }
        case TGModernClockProgressTypeOutgoingMediaClock:
        {
            static CGImageRef image = NULL;
            
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^
            {
                UIImage *rawImage = TGImageNamed(@"ClockWhiteMin.png");
                image = CGImageRetain(TGScaleAndRoundCorners(rawImage, CGSizeMake(rawImage.size.width, rawImage.size.height), CGSizeZero, 0, nil, false, nil).CGImage);
            });
            
            return image;
        }
        case TGModernClockProgressTypeIncomingClock:
        {
            static CGImageRef image = NULL;
            
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^
            {
                UIImage *rawImage = TGImageNamed(@"ClockIncomingMin.png");
                image = CGImageRetain(TGScaleAndRoundCorners(rawImage, CGSizeMake(rawImage.size.width, rawImage.size.height), CGSizeZero, 0, nil, false, nil).CGImage);
            });

            return image;
        }
        default:
            break;
    }
}

+ (CGImageRef)hourImageForType:(TGModernClockProgressType)type
{
    switch (type)
    {
        case TGModernClockProgressTypeOutgoingClock:
        {
            static CGImageRef image = NULL;
            
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^
            {
                UIImage *rawImage = TGImageNamed(@"ClockHour.png");
                image = CGImageRetain(TGScaleAndRoundCorners(rawImage, CGSizeMake(rawImage.size.width, rawImage.size.height), CGSizeZero, 0, nil, false, nil).CGImage);
            });
            
            return image;
        }
        case TGModernClockProgressTypeOutgoingMediaClock:
        {
            static CGImageRef image = NULL;
            
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^
            {
                UIImage *rawImage = TGImageNamed(@"ClockWhiteHour.png");
                image = CGImageRetain(TGScaleAndRoundCorners(rawImage, CGSizeMake(rawImage.size.width, rawImage.size.height), CGSizeZero, 0, nil, false, nil).CGImage);
            });
            
            return image;
        }
        case TGModernClockProgressTypeIncomingClock:
        {
            static CGImageRef image = NULL;
            
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^
            {
                UIImage *rawImage = TGImageNamed(@"ClockIncomingHour.png");
                image = CGImageRetain(TGScaleAndRoundCorners(rawImage, CGSizeMake(rawImage.size.width, rawImage.size.height), CGSizeZero, 0, nil, false, nil).CGImage);
            });
            
            return image;
        }
    }
}

- (void)bindViewToContainer:(UIView *)container viewStorage:(TGModernViewStorage *)viewStorage
{
    [super bindViewToContainer:container viewStorage:viewStorage];
    
    TGModernClockProgressView *view = (TGModernClockProgressView *)[self boundView];

    [view setFrameImage:[TGModernClockProgressViewModel frameImageForType:_type] hourImage:[TGModernClockProgressViewModel hourImageForType:_type] minImage:[TGModernClockProgressViewModel minImageForType:_type]];
}

+ (void)setupView:(TGModernClockProgressView *)view forType:(TGModernClockProgressType)type {
    [view setFrameImage:[TGModernClockProgressViewModel frameImageForType:type] hourImage:[TGModernClockProgressViewModel hourImageForType:type] minImage:[TGModernClockProgressViewModel minImageForType:type]];
}

- (void)drawInContext:(CGContextRef)context
{
    [super drawInContext:context];
    
    if (!self.skipDrawInContext)
    {
        CGContextTranslateCTM(context, 15.0f / 2.0f, 15.0f / 2.0f);
        CGContextScaleCTM(context, 1.0f, -1.0f);
        CGContextTranslateCTM(context, -15.0f / 2.0f, -15.0f / 2.0f);
        
        CGImageRef frameImage = [TGModernClockProgressViewModel frameImageForType:_type];
        if (frameImage != NULL)
            CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, 15.0f, 15.0f), frameImage);
        
        CGImageRef hourImage = [TGModernClockProgressViewModel hourImageForType:_type];
        if (hourImage != NULL)
            CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, 15.0f, 15.0f), hourImage);

        CGImageRef minImage = [TGModernClockProgressViewModel minImageForType:_type];
        if (minImage != NULL)
            CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, 15.0f, 15.0f), minImage);
        
        CGContextTranslateCTM(context, 15.0f / 2.0f, 15.0f / 2.0f);
        CGContextScaleCTM(context, 1.0f, -1.0f);
        CGContextTranslateCTM(context, -15.0f / 2.0f, -15.0f / 2.0f);
    }
}

- (void)sizeToFit
{
    CGRect frame = self.frame;
    frame.size = CGSizeMake(15.0f, 15.0f);
    self.frame = frame;
}

@end
