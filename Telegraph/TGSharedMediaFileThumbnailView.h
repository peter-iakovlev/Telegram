#import <UIKit/UIKit.h>

typedef enum {
    TGSharedMediaFileThumbnailViewStyleRounded,
    TGSharedMediaFileThumbnailViewStylePlain
} TGSharedMediaFileThumbnailViewStyle;

@interface TGSharedMediaFileThumbnailView : UIView

- (void)setStyle:(TGSharedMediaFileThumbnailViewStyle)style colors:(NSArray *)colors;

@end
