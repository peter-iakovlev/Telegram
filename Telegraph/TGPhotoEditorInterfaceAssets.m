#import "TGPhotoEditorInterfaceAssets.h"

#import "pop/POP.h"

@implementation TGPhotoEditorInterfaceAssets

+ (UIColor *)toolbarBackgroundColor
{
    return [UIColor blackColor]; //UIColorRGB(0x171717);
}

+ (UIColor *)toolbarTransparentBackgroundColor
{
    return UIColorRGBA(0x000000, 0.9f); //UIColorRGBA(0x191919, 0.9f);
}

+ (UIColor *)cropTransparentOverlayColor
{
    return UIColorRGBA(0x000000, 0.7f);
}

+ (UIColor *)accentColor
{
    return UIColorRGB(0x4fbcff);
}

+ (UIColor *)panelBackgroundColor
{
    return UIColorRGBA(0x000000, 0.9f); //UIColorRGBA(0x000000, 0.9f);
}

+ (UIColor *)selectedImagesPanelBackgroundColor
{
    return UIColorRGBA(0x000000, 0.9f); //UIColorRGBA(0x191919, 0.9f);
}

+ (UIColor *)editorButtonSelectionBackgroundColor
{
    return UIColorRGB(0xd1d1d1);
}

+ (UIImage *)captionIcon
{
    return [UIImage imageNamed:@"PhotoEditorCaption.png"];
}

+ (UIImage *)cropIcon
{
    return [UIImage imageNamed:@"PhotoEditorCrop.png"];
}

+ (UIImage *)toolsIcon
{
    return [UIImage imageNamed:@"PhotoEditorTools.png"];
}

+ (UIImage *)rotateIcon
{
    return [UIImage imageNamed:@"PhotoEditorRotate.png"];
}

+ (UIImage *)paintIcon
{
    return [UIImage imageNamed:@"PhotoEditorPaint.png"];
}

+ (UIImage *)stickerIcon
{
    return [UIImage imageNamed:@"PaintStickersIcon.png"];
}

+ (UIImage *)textIcon
{
    return [UIImage imageNamed:@"PaintTextIcon.png"];
}

+ (UIImage *)gifIcon
{
    return [UIImage imageNamed:@"PhotoEditorMute.png"];
}

+ (UIImage *)gifActiveIcon
{
    return [UIImage imageNamed:@"PhotoEditorMuteActive.png"];
}

+ (UIColor *)toolbarSelectedIconColor
{
    return UIColorRGB(0x171717);
}

+ (UIColor *)toolbarAppliedIconColor
{
    return UIColorRGB(0x4fbcff);
}

+ (UIColor *)editorItemTitleColor
{
    return UIColorRGB(0xb8b8b8);
}

+ (UIColor *)editorActiveItemTitleColor
{
    return UIColorRGB(0xffffff);
}

+ (UIFont *)editorItemTitleFont
{
    return [TGFont systemFontOfSize:12];
}

+ (UIColor *)filterSelectionColor
{
    return [UIColor whiteColor];
}

+ (UIColor *)sliderBackColor
{
    return UIColorRGB(0x2e2e2e);
}

+ (UIColor *)sliderTrackColor
{
    return UIColorRGB(0xcccccc);
}

@end
