#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLSendMessageAction : NSObject <TLObject>


@end

@interface TLSendMessageAction$sendMessageTypingAction : TLSendMessageAction


@end

@interface TLSendMessageAction$sendMessageCancelAction : TLSendMessageAction


@end

@interface TLSendMessageAction$sendMessageRecordVideoAction : TLSendMessageAction


@end

@interface TLSendMessageAction$sendMessageRecordAudioAction : TLSendMessageAction


@end

@interface TLSendMessageAction$sendMessageGeoLocationAction : TLSendMessageAction


@end

@interface TLSendMessageAction$sendMessageChooseContactAction : TLSendMessageAction


@end

@interface TLSendMessageAction$sendMessageUploadVideoAction : TLSendMessageAction

@property (nonatomic) int32_t progress;

@end

@interface TLSendMessageAction$sendMessageUploadAudioAction : TLSendMessageAction

@property (nonatomic) int32_t progress;

@end

@interface TLSendMessageAction$sendMessageUploadDocumentAction : TLSendMessageAction

@property (nonatomic) int32_t progress;

@end

@interface TLSendMessageAction$sendMessageUploadPhotoAction : TLSendMessageAction

@property (nonatomic) int32_t progress;

@end

@interface TLSendMessageAction$sendMessageGamePlayAction : TLSendMessageAction


@end

@interface TLSendMessageAction$sendMessageGameStopAction : TLSendMessageAction


@end

@interface TLSendMessageAction$sendMessageRecordRoundAction : TLSendMessageAction


@end

@interface TLSendMessageAction$sendMessageUploadRoundAction : TLSendMessageAction

@property (nonatomic) int32_t progress;

@end

