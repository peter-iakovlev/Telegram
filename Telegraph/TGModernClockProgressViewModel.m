#import "TGModernClockProgressViewModel.h"

#import <LegacyComponents/LegacyComponents.h>

#import "TGModernClockProgressView.h"

#import "TGPresentation.h"

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

+ (CGImageRef)frameImageForType:(TGModernClockProgressType)type presentation:(TGPresentation *)presentation
{
    switch (type)
    {
        case TGModernClockProgressTypeOutgoingClock:
            return presentation.images.chatClockFrameIconOutgoing.CGImage;
        
        case TGModernClockProgressTypeOutgoingMediaClock:
            return presentation.images.chatClockFrameIconMedia.CGImage;
        
        case TGModernClockProgressTypeIncomingClock:
            return presentation.images.chatClockFrameIconIncoming.CGImage;
    }
    
    return NULL;
}

+ (CGImageRef)minImageForType:(TGModernClockProgressType)type presentation:(TGPresentation *)presentation
{
    switch (type)
    {
        case TGModernClockProgressTypeOutgoingClock:
            return presentation.images.chatClockMinuteIconOutgoing.CGImage;

        case TGModernClockProgressTypeOutgoingMediaClock:
            return presentation.images.chatClockMinuteIconMedia.CGImage;
            
        case TGModernClockProgressTypeIncomingClock:
            return presentation.images.chatClockMinuteIconIncoming.CGImage;
    }
    
    return NULL;
}

+ (CGImageRef)hourImageForType:(TGModernClockProgressType)type presentation:(TGPresentation *)presentation
{
    switch (type)
    {
        case TGModernClockProgressTypeOutgoingClock:
            return presentation.images.chatClockHourIconOutgoing.CGImage;
            
        case TGModernClockProgressTypeOutgoingMediaClock:
            return presentation.images.chatClockHourIconMedia.CGImage;
            
        case TGModernClockProgressTypeIncomingClock:
            return presentation.images.chatClockHourIconIncoming.CGImage;
    }
    
    return NULL;
}

- (void)bindViewToContainer:(UIView *)container viewStorage:(TGModernViewStorage *)viewStorage
{
    [super bindViewToContainer:container viewStorage:viewStorage];
    
    TGModernClockProgressView *view = (TGModernClockProgressView *)[self boundView];

    [view setFrameImage:[TGModernClockProgressViewModel frameImageForType:_type presentation:_presentation] hourImage:[TGModernClockProgressViewModel hourImageForType:_type presentation:_presentation] minImage:[TGModernClockProgressViewModel minImageForType:_type presentation:_presentation]];
}

+ (void)setupView:(TGModernClockProgressView *)view forType:(TGModernClockProgressType)type presentation:(TGPresentation *)presentation {
    [view setFrameImage:[TGModernClockProgressViewModel frameImageForType:type presentation:presentation] hourImage:[TGModernClockProgressViewModel hourImageForType:type presentation:presentation] minImage:[TGModernClockProgressViewModel minImageForType:type presentation:presentation]];
}

- (void)drawInContext:(CGContextRef)context
{
    [super drawInContext:context];
    
    if (!self.skipDrawInContext)
    {
        CGContextTranslateCTM(context, 15.0f / 2.0f, 15.0f / 2.0f);
        CGContextScaleCTM(context, 1.0f, -1.0f);
        CGContextTranslateCTM(context, -15.0f / 2.0f, -15.0f / 2.0f);
        
        CGImageRef frameImage = [TGModernClockProgressViewModel frameImageForType:_type presentation:_presentation];
        if (frameImage != NULL)
            CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, 15.0f, 15.0f), frameImage);
        
        CGImageRef hourImage = [TGModernClockProgressViewModel hourImageForType:_type presentation:_presentation];
        if (hourImage != NULL)
            CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, 15.0f, 15.0f), hourImage);

        CGImageRef minImage = [TGModernClockProgressViewModel minImageForType:_type presentation:_presentation];
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
