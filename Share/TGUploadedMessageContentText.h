#import "TGUploadedMessageContent.h"

@interface TGUploadedMessageContentText : TGUploadedMessageContent

@property (nonatomic, strong, readonly) NSString *text;

- (instancetype)initWithText:(NSString *)text;

@end
