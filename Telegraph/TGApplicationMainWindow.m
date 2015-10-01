#import "TGApplicationMainWindow.h"

@implementation TGApplicationMainWindow

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    
    TGLog(@"setBounds: %@", NSStringFromCGRect(bounds));
}

@end
