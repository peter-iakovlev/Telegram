#import "TGReplyHeaderModel.h"

@class SSignal;
@class TGSignalImageViewModel;
@class TGModernImageViewModel;

@interface TGReplyHeaderImageModel : TGReplyHeaderModel
{
    @protected
    TGSignalImageViewModel *_imageModel;
    TGModernImageViewModel *_iconModel;
}

- (instancetype)initWithPeer:(id)peer incoming:(bool)incoming text:(NSString *)text imageSignalGenerator:(SSignal *(^)())imageSignalGenerator imageSignalIdentifier:(NSString *)imageSignalIdentifier icon:(UIImage *)icon truncateTextInTheMiddle:(bool)truncateTextInTheMiddle system:(bool)system;

@end
