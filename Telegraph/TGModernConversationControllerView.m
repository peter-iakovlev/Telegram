#import "TGModernConversationControllerView.h"

@interface TGModernConversationControllerView () {
    CGSize _validSize;
}

@end

@implementation TGModernConversationControllerView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        _validSize = frame.size;
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    if (!CGSizeEqualToSize(_validSize, frame.size)) {
        _validSize = frame.size;
        if (_layoutForSize) {
            _layoutForSize(frame.size);
        }
    }
}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    
    if (!CGSizeEqualToSize(_validSize, bounds.size)) {
        _validSize = bounds.size;
        if (_layoutForSize) {
            _layoutForSize(bounds.size);
        }
    }
}

- (void)didMoveToWindow {
    if (self.window != nil) {
        if (_movedToWindow) {
            _movedToWindow();
        }
    }
}

@end
