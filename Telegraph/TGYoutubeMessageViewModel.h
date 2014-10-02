#import "TGImageMessageViewModel.h"

@interface TGYoutubeMessageViewModel : TGImageMessageViewModel

- (instancetype)initWithVideoId:(NSString *)videoId message:(TGMessage *)message author:(TGUser *)author context:(TGModernViewContext *)context;

@end
