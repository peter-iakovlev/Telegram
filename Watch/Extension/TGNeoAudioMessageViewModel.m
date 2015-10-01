#import "TGNeoAudioMessageViewModel.h"
#import "TGBridgeMessage.h"

@interface TGNeoAudioMessageViewModel ()
{
    TGNeoLabelViewModel *_nameModel;
    TGNeoLabelViewModel *_durationModel;
}
@end

@implementation TGNeoAudioMessageViewModel

- (instancetype)initWithMessage:(TGBridgeMessage *)message users:(NSDictionary *)users context:(TGBridgeContext *)context
{
    self = [super initWithMessage:message users:users context:context];
    if (self != nil)
    {
        TGBridgeAudioMediaAttachment *audioAttachment = nil;
        TGBridgeDocumentMediaAttachment *documentAttachment = nil;
        
        for (TGBridgeMediaAttachment *attachment in message.media)
        {
            if ([attachment isKindOfClass:[TGBridgeAudioMediaAttachment class]])
            {
                audioAttachment = (TGBridgeAudioMediaAttachment *)attachment;
                break;
            }
            else if ([attachment isKindOfClass:[TGBridgeDocumentMediaAttachment class]])
            {
                documentAttachment = (TGBridgeDocumentMediaAttachment *)attachment;
                break;
            }
        }
        
        if (documentAttachment != nil)
        {
            [self removeSubmodel:self.forwardHeaderModel];
            self.forwardHeaderModel = nil;
        }
        
        NSString *title = (documentAttachment != nil) ? documentAttachment.title : TGLocalized(@"Message.Audio");
        _nameModel = [[TGNeoLabelViewModel alloc] initWithText:title font:[UIFont systemFontOfSize:12 weight:UIFontWeightMedium] color:[self normalColorForMessage:message] attributes:nil];
        _nameModel.multiline = false;
        [self addSubmodel:_nameModel];
        
        NSString *subtitle = @"";
        
        if (documentAttachment != nil)
        {
            subtitle = documentAttachment.performer.length > 0 ? documentAttachment.performer : @"";
        }
        else
        {
            NSInteger durationMinutes = floor(audioAttachment.duration / 60.0);
            NSInteger durationSeconds = audioAttachment.duration % 60;
            subtitle = [NSString stringWithFormat:@"%ld:%02ld", (long)durationMinutes, (long)durationSeconds];
        }
        
        _durationModel = [[TGNeoLabelViewModel alloc] initWithText:subtitle font:[UIFont systemFontOfSize:12] color:[self subtitleColorForMessage:message] attributes:nil];
        _durationModel.multiline = false;
        [self addSubmodel:_durationModel];
    }
    return self;
}

- (CGSize)layoutWithContainerSize:(CGSize)containerSize
{
    CGSize contentContainerSize = [self contentContainerSizeWithContainerSize:containerSize];
    
    CGSize headerSize = [self layoutHeaderModelsWithContainerSize:contentContainerSize];
    CGFloat maxContentWidth = headerSize.width;
    CGFloat textTopOffset = headerSize.height;
    
    CGFloat leftOffset = 26 + TGNeoBubbleMessageMetaSpacing;
    contentContainerSize = CGSizeMake(containerSize.width - TGNeoBubbleMessageViewModelInsets.left - TGNeoBubbleMessageViewModelInsets.right - leftOffset, FLT_MAX);
    
    CGSize nameSize = [_nameModel contentSizeWithContainerSize:contentContainerSize];
    CGSize durationSize = [_durationModel contentSizeWithContainerSize:contentContainerSize];
    maxContentWidth = MAX(maxContentWidth, MAX(nameSize.width, durationSize.width) + leftOffset);
    
    _nameModel.frame = CGRectMake(TGNeoBubbleMessageViewModelInsets.left + leftOffset, textTopOffset, nameSize.width, 14);
    _durationModel.frame = CGRectMake(TGNeoBubbleMessageViewModelInsets.left + leftOffset, CGRectGetMaxY(_nameModel.frame), durationSize.width, 14);
    
    UIEdgeInsets inset = UIEdgeInsetsMake(textTopOffset + 1.5f, TGNeoBubbleMessageViewModelInsets.left, 0, 0);
    NSDictionary *audioButtonDictionary = @{ TGNeoMessageAudioIcon: @"" };
    
    [self addAdditionalLayout:@{ TGNeoContentInset: [NSValue valueWithUIEdgeInsets:inset], TGNeoMessageAudioButton: audioButtonDictionary } withKey:TGNeoMessageMetaGroup];
    
    CGSize contentSize =  CGSizeMake(TGNeoBubbleMessageViewModelInsets.left + TGNeoBubbleMessageViewModelInsets.right + maxContentWidth, CGRectGetMaxY(_durationModel.frame) + TGNeoBubbleMessageViewModelInsets.bottom);
    
    [super layoutWithContainerSize:contentSize];
    
    return contentSize;
}

@end
