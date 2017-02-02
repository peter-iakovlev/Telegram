#import "TGPreviewAudioItemView.h"
#import "TGMusicPlayerCompleteView.h"

#import "TGImageUtils.h"

#import "TGBotContextExternalResult.h"
#import "TGGenericPeerPlaylistSignals.h"

#import "TGTelegraph.h"

@interface TGPreviewAudioItemView ()
{
    TGMusicPlayerCompleteView *_musicView;
}
@end

@implementation TGPreviewAudioItemView

- (instancetype)init
{
    self = [super initWithType:TGMenuSheetItemTypeDefault];
    if (self != nil)
    {
        _musicView = [[TGMusicPlayerCompleteView alloc] initWithFrame:CGRectZero setTitle:nil actionsEnabled:nil];
        _musicView.preview = true;
        [self addSubview:_musicView];
    }
    return self;
}

- (instancetype)initWithBotContextResult:(TGBotContextResult *)result
{
    self = [self init];
    if (self != nil)
    {
        TGMusicPlayerItem *item = [TGMusicPlayerItem itemWithBotContextResult:result];
        if (item != nil)
        {
            [TGTelegraphInstance.musicPlayer setPlaylist:[TGGenericPeerPlaylistSignals playlistForItem:item voice:[result.type isEqualToString:@"voice"]] initialItemKey:item.key metadata:nil];
        }

    }
    return self;
}

- (void)dealloc
{
    [TGTelegraphInstance.musicPlayer setPlaylist:nil initialItemKey:nil metadata:nil];
}

- (CGFloat)preferredHeightForWidth:(CGFloat)__unused width screenHeight:(CGFloat)__unused screenHeight
{
    CGSize screenSize = TGScreenSize();
    return MIN(screenSize.width, screenSize.height) + 57.0f;
}

- (void)layoutSubviews
{
    CGSize screenSize = TGScreenSize();
    CGFloat screenHeight = MAX(screenSize.width, screenSize.height);
    
    _musicView.frame = CGRectMake(0, 0, self.frame.size.width, screenHeight);
}

@end
