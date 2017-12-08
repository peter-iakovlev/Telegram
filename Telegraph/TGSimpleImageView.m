#import "TGSimpleImageView.h"

#import <LegacyComponents/Freedom.h>

@implementation TGSimpleImageView

static void TGSimpleImageViewDidMoveFromWindow(__unused id self, __unused SEL _cmd, __unused id fromWindow, __unused id toWindow)
{
}

+ (void)load
{
    FreedomDecoration instanceDecorations[] =
    {
        { .name = 0xb286f41U,
            .imp = (IMP)&TGSimpleImageViewDidMoveFromWindow,
            .newIdentifier = FreedomIdentifierEmpty,
            .newEncoding = FreedomIdentifierEmpty
        }
    };
    
    freedomClassAutoDecorateExplicit([self class], 0, NULL, 0, instanceDecorations, sizeof(instanceDecorations) / sizeof(instanceDecorations[0]));
}

- (UITraitCollection *)traitCollection
{
    return nil;
}

- (void)traitCollectionDidChange:(UITraitCollection *)__unused previousTraitCollection
{
    
}

@end
