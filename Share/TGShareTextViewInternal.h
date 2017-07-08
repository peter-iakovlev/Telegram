#import <UIKit/UIKit.h>

#import "TGWeakDelegate.h"

@interface TGShareTextViewInternal : UITextView

@property (nonatomic) bool isPasting;

@property (nonatomic) bool freezeContentOffset;
@property (nonatomic) bool disableContentOffsetAnimation;

@property (nonatomic, strong) TGWeakDelegate *responderStateDelegate;

@property (nonatomic) bool enableFirstResponder;

+ (void)addTextViewMethods;

- (void)textViewEnsureSelectionVisible;

@end

@protocol TGShareTextViewInternalDelegate <NSObject>

@required

- (void)hpTextViewChangedResponderState:(bool)firstResponder;

@end
