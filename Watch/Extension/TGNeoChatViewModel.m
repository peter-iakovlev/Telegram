#import "TGNeoChatViewModel.h"

#import "TGNeoLabelViewModel.h"
#import "TGNeoImageViewModel.h"
#import "TGNeoAttachmentViewModel.h"

#import "TGBridgeContext.h"
#import "TGBridgeChat.h"
#import "TGBridgeUser.h"

#import "TGStringUtils.h"
#import "TGDateUtils.h"

const CGFloat TGNeoChatViewModelHeight = 57;

@interface TGNeoChatViewModel ()
{
    TGNeoLabelViewModel *_nameModel;
    TGNeoLabelViewModel *_authorNameModel;
    TGNeoImageViewModel *_verifiedModel;
    TGNeoLabelViewModel *_authorInitialsModel;
    TGNeoLabelViewModel *_textModel;
    TGNeoAttachmentViewModel *_attachmentModel;
    TGNeoLabelViewModel *_timeModel;
}
@end

@implementation TGNeoChatViewModel

- (instancetype)initWithChat:(TGBridgeChat *)chat users:(NSDictionary *)users context:(TGBridgeContext *)context
{
    self = [super init];
    if (self != nil)
    {
        TGBridgeUser *author = nil;
        NSString *name = nil;
        
        if (chat.isGroup)
        {
            author = users[@(chat.fromUid)];
            name = chat.groupTitle;
        }
        else if (chat.isChannel)
        {
            name = chat.groupTitle;
        }
        else
        {
            author = users[@(chat.identifier)];
            name = [author displayName];
        }
        
        _nameModel = [[TGNeoLabelViewModel alloc] initWithText:name font:[UIFont systemFontOfSize:16 weight:UIFontWeightMedium] color:[UIColor whiteColor] attributes:nil];
        _nameModel.multiline = false;
        [self addSubmodel:_nameModel];
        
        if (chat.isVerified)
        {
            _verifiedModel = [[TGNeoImageViewModel alloc] initWithImage:[UIImage imageNamed:@"VerifiedList"]];
            [self addSubmodel:_verifiedModel];
        }
        
        _attachmentModel = [[TGNeoAttachmentViewModel alloc] initWithAttachments:chat.media author:author forChannel:chat.isChannel users:users font:[UIFont systemFontOfSize:16] subTitleColor:[UIColor hexColor:0x8f8f8f] normalColor:[UIColor whiteColor] compact:false];
        if (_attachmentModel != nil)
            [self addSubmodel:_attachmentModel];
        
        if (chat.isGroup && !_attachmentModel.inhibitsInitials)
        {
            NSString *initials = (chat.fromUid == context.userId) ? TGLocalized(@"ChatList.You") : [TGStringUtils initialsForFirstName:author.firstName lastName:author.lastName single:false];
            
            if (initials.length > 0)
            {
                _authorInitialsModel = [[TGNeoLabelViewModel alloc] initWithText:[NSString stringWithFormat:@"%@:", initials] font:[UIFont systemFontOfSize:16 weight:UIFontWeightMedium] color:[UIColor whiteColor] attributes:nil];
                [self addSubmodel:_authorInitialsModel];
            }
        }
        
        if (chat.text.length > 0)
        {
            _textModel = [[TGNeoLabelViewModel alloc] initWithText:chat.text font:[UIFont systemFontOfSize:16] color:[UIColor hexColor:0x8f8f8f] attributes:nil];
            _textModel.multiline = false;
            [self addSubmodel:_textModel];
        }
        
        NSString *time = @"";
        if (chat.date > 0)
            time = [TGDateUtils stringForMessageListDate:chat.date];
        
        _timeModel = [[TGNeoLabelViewModel alloc] initWithText:time font:[UIFont systemFontOfSize:13] color:[UIColor hexColor:0x8f8f8f] attributes:nil];
        [self addSubmodel:_timeModel];
    }
    return self;
}

- (CGSize)layoutWithContainerSize:(CGSize)containerSize
{
    CGSize nameSize = [_nameModel contentSizeWithContainerSize:CGSizeMake(containerSize.width - 31 - 7, FLT_MAX)];

    if (_verifiedModel != nil)
    {
        CGFloat margin = 4;
        _verifiedModel.frame = CGRectMake(MIN(31.5f + nameSize.width + margin, containerSize.width - 20), 6, 12, 12);
        nameSize.width = MIN(nameSize.width, _verifiedModel.frame.origin.x - 31.5f - margin);

        _nameModel.frame = CGRectMake(31.5f, 1.5f, nameSize.width, 20);
    }
    else
    {
        _nameModel.frame = CGRectMake(31.5f, 1.5f, containerSize.width - 31 - 7, 20);
    }
    
    CGFloat textOffset = 0;
    if (_authorInitialsModel != nil)
    {
        CGFloat width = [_authorInitialsModel contentSizeWithContainerSize:CGSizeMake(40, 20)].width + 4;
        _authorInitialsModel.frame = CGRectMake(31.5f, 19, width, 20);
        textOffset += width;
    }
    
    if (_attachmentModel != nil)
        _attachmentModel.frame = CGRectMake(31.5f + textOffset, 19, containerSize.width - 31 - 7 - textOffset, 20);
    else
        _textModel.frame = CGRectMake(31.5f + textOffset, 19, containerSize.width - 31 - 7 - textOffset, 20);
    
    _timeModel.frame = CGRectMake(31.5f, 38, containerSize.width - 31 - 36, 20);
    
    self.contentSize = CGSizeMake(containerSize.width, TGNeoChatViewModelHeight);
    return self.contentSize;
}

@end
