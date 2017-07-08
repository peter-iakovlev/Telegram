
#import "TGShareTextViewInternal.h"

#import "TGShareGrowingTextView.h"

#import <objc/runtime.h>
#import <objc/message.h>

#import <MobileCoreServices/MobileCoreServices.h>

@implementation TGShareTextViewInternal

void InjectInstanceMethodFromAnotherClass(Class toClass, Class fromClass, SEL fromSelector, SEL toSeletor)
{
    Method method = class_getInstanceMethod(fromClass, fromSelector);
    if (method != nil)
    {
        if (!class_addMethod(toClass, toSeletor, method_getImplementation(method), method_getTypeEncoding(method)))
            NSLog(@"Attempt to add method failed");
    }
    else
        NSLog(@"Attempt to add nonexistent method");
}

NSString *TGEncodeText(NSString *string, int key)
{
    NSMutableString *result = [[NSMutableString alloc] init];
    
    for (int i = 0; i < (int)[string length]; i++)
    {
        unichar c = [string characterAtIndex:i];
        c += key;
        [result appendString:[NSString stringWithCharacters:&c length:1]];
    }
    
    return result;
}


+ (void)addTextViewMethods
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        InjectInstanceMethodFromAnotherClass([TGShareTextViewInternal class], [TGShareTextViewInternal class], @selector(textViewAdjustScrollRange:animated:), NSSelectorFromString(TGEncodeText(@"`tdspmmSbohfUpWjtjcmf;bojnbufe;", -1)));
    });
}

- (void)setText:(NSString *)text
{
    BOOL originalValue = self.scrollEnabled;
    //If one of GrowingTextView's superviews is a scrollView, and self.scrollEnabled == NO,
    //setting the text programatically will cause UIKit to search upwards until it finds a scrollView with scrollEnabled==yes
    //then scroll it erratically. Setting scrollEnabled temporarily to YES prevents this.
    [self setScrollEnabled:YES];
    [super setText:text];
    [self setScrollEnabled:originalValue];
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    BOOL originalValue = self.scrollEnabled;
    //If one of GrowingTextView's superviews is a scrollView, and self.scrollEnabled == NO,
    //setting the text programatically will cause UIKit to search upwards until it finds a scrollView with scrollEnabled==yes
    //then scroll it erratically. Setting scrollEnabled temporarily to YES prevents this.
    [self setScrollEnabled:YES];
    [super setAttributedText:attributedText];
    [self setScrollEnabled:originalValue];
}

- (void)setScrollable:(BOOL)isScrollable
{
    [super setScrollEnabled:isScrollable];
}

- (void)textViewAdjustScrollRange:(NSRange)range animated:(BOOL)animated
{
    static SEL selector = NULL;
    static void (*impl)(id, SEL, NSRange, BOOL) = NULL;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        Method method = class_getInstanceMethod([UITextView class], selector);
        if (method != NULL)
            impl = (void (*)(id, SEL, NSRange, BOOL))method_getImplementation(method);
    });
    
    animated = false;
    
    if (impl != NULL)
        impl(self, selector, range, animated);
}

- (void)scrollRectToVisible:(CGRect)__unused rect animated:(BOOL)__unused animated
{
    
}

- (void)setContentOffset:(CGPoint)contentOffset animated:(BOOL)animated
{
    if (_freezeContentOffset)
        return;
    
    [super setContentOffset:contentOffset animated:_disableContentOffsetAnimation ? false : animated];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
}

-(void)setContentOffset:(CGPoint)s
{
    if (_freezeContentOffset)
        return;
    
    [super setContentOffset:s];
}

- (void)textViewEnsureSelectionVisible
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            CGRect caretFrame = [self caretRectForPosition:self.selectedTextRange.end];
            if (caretFrame.origin.x < CGFLOAT_MAX && caretFrame.origin.y < CGFLOAT_MAX && !CGRectIsInfinite(caretFrame))
            {
                UIEdgeInsets implicitInset = UIEdgeInsetsMake(8, 0, 8, 0);
                
                caretFrame.origin.y -= implicitInset.top;
                caretFrame.size.height += implicitInset.top + implicitInset.bottom;
                caretFrame.origin.y = floor(caretFrame.origin.y * 2.0f) / 2.0f;
                caretFrame.size.height = floor(caretFrame.size.height * 2.0f) / 2.0f;
                
                CGFloat frameHeight = self.frame.size.height;
                CGPoint contentOffset = self.contentOffset;
                
                if (caretFrame.origin.y < contentOffset.y)
                    contentOffset.y = caretFrame.origin.y;
                if (caretFrame.origin.y + caretFrame.size.height > contentOffset.y + frameHeight)
                    contentOffset.y = caretFrame.origin.y + caretFrame.size.height - frameHeight;
                contentOffset.y = MAX(0, contentOffset.y);
                
                if (!CGPointEqualToPoint(contentOffset, self.contentOffset))
                    self.contentOffset = contentOffset;
            }
        });
    } else {
        CGRect caretFrame = [self caretRectForPosition:self.selectedTextRange.end];
        if (caretFrame.origin.x < CGFLOAT_MAX && caretFrame.origin.y < CGFLOAT_MAX && !CGRectIsInfinite(caretFrame))
        {
            UIEdgeInsets implicitInset = UIEdgeInsetsMake(8, 0, 8, 0);
            
            caretFrame.origin.y -= implicitInset.top;
            caretFrame.size.height += implicitInset.top + implicitInset.bottom;
            caretFrame.origin.y = floor(caretFrame.origin.y * 2.0f) / 2.0f;
            caretFrame.size.height = floor(caretFrame.size.height * 2.0f) / 2.0f;
            
            CGFloat frameHeight = self.frame.size.height;
            CGPoint contentOffset = self.contentOffset;
            
            if (caretFrame.origin.y < contentOffset.y)
                contentOffset.y = caretFrame.origin.y;
            if (caretFrame.origin.y + caretFrame.size.height > contentOffset.y + frameHeight)
                contentOffset.y = caretFrame.origin.y + caretFrame.size.height - frameHeight;
            contentOffset.y = MAX(0, contentOffset.y);
            
            if (!CGPointEqualToPoint(contentOffset, self.contentOffset))
                self.contentOffset = contentOffset;
        }
    }
}

- (void)setContentSize:(CGSize)contentSize
{
    [super setContentSize:contentSize];
    
    [self textViewEnsureSelectionVisible];
}

- (BOOL)canBecomeFirstResponder
{
    if (!_enableFirstResponder)
        return false;
    return true;
}

- (BOOL)becomeFirstResponder
{
    if (!_enableFirstResponder)
        return false;
    
    __block BOOL result = false;
    result = [super becomeFirstResponder];
    
    if (result)
    {
        id delegate = _responderStateDelegate.object;
        if (delegate != nil && [delegate conformsToProtocol:@protocol(TGShareTextViewInternalDelegate)])
        {
            [(id<TGShareTextViewInternalDelegate>)delegate hpTextViewChangedResponderState:true];
        }
    }
    return result;
}

- (BOOL)resignFirstResponder
{
    __block BOOL result = false;
    result = [super resignFirstResponder];
    
    if (result)
    {
        id delegate = _responderStateDelegate.object;
        if (delegate != nil && [delegate conformsToProtocol:@protocol(TGShareTextViewInternalDelegate)])
        {
            [(id<TGShareTextViewInternalDelegate>)delegate hpTextViewChangedResponderState:false];
        }
    }
    return result;
}

@end
