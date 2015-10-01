#import "TGNeoServiceMessageViewModel.h"

#import "TGNeoLabelViewModel.h"

#import "TGBridgeMessage.h"
#import "TGBridgeUser.h"
#import "TGChatInfo.h"

#import "TGPeerIdAdapter.h"

const UIEdgeInsets TGNeoServiceMessageInsets = { 12, 0, 12, 0 };

@interface TGNeoServiceMessageViewModel ()
{
    TGNeoLabelViewModel *_titleModel;
    TGNeoLabelViewModel *_textModel;
}
@end

@implementation TGNeoServiceMessageViewModel

- (instancetype)initWithMessage:(TGBridgeMessage *)message users:(NSDictionary *)users context:(TGBridgeContext *)context
{
    self = [super initWithMessage:message users:users context:context];
    if (self != nil)
    {
        NSString *actionText = nil;
        NSArray *additionalAttributes = nil;
        
        bool isChannel = TGPeerIdIsChannel(message.cid);
        
        TGBridgeUser *author = users[@(message.fromUid)];
        
        for (TGBridgeMediaAttachment *attachment in message.media)
        {
            if ([attachment isKindOfClass:[TGBridgeActionMediaAttachment class]])
            {
                TGBridgeActionMediaAttachment *actionAttachment = (TGBridgeActionMediaAttachment *)attachment;
                
                switch (actionAttachment.actionType)
                {
                    case TGBridgeMessageActionChatEditTitle:
                    {
                        if (isChannel)
                        {
                            NSString *formatString = TGLocalized(@"Notification.ChannelFullTitleUpdated");
                            actionText = [NSString stringWithFormat:formatString, actionAttachment.actionData[@"title"]];
                        }
                        else
                        {
                            NSString *authorName = author.displayName;
                            NSString *formatString = TGLocalized(@"Notification.ChangedGroupName");
                            actionText = [NSString stringWithFormat:formatString, authorName, actionAttachment.actionData[@"title"]];
                            
                            NSRange formatNameRange = [formatString rangeOfString:@"%@"];
                            if (formatNameRange.location != NSNotFound)
                            {
                                additionalAttributes = [TGNeoServiceMessageViewModel _mediumFontAttributeForRange:NSMakeRange(formatNameRange.location, authorName.length)];
                            }
                        }
                    }
                        break;
                        
                    case TGBridgeMessageActionChatEditPhoto:
                    {
                        NSString *authorName = author.displayName;
                        bool changed = actionAttachment.actionData[@"photo"];
                        
                        if (isChannel)
                        {
                            actionText = changed ? TGLocalized(@"Notification.ChannelPhotoUpdated") : TGLocalized(@"Notification.ChannelPhotoRemoved");
                        }
                        else
                        {
                            NSString *formatString = changed ? TGLocalized(@"Notification.ChangedGroupPhoto") : TGLocalized(@"Notification.RemovedGroupPhoto");
                            
                            actionText = [NSString stringWithFormat:formatString, authorName];
                            
                            NSRange formatNameRange = [formatString rangeOfString:@"%@"];
                            if (formatNameRange.location != NSNotFound)
                            {
                                additionalAttributes = [TGNeoServiceMessageViewModel _mediumFontAttributeForRange:NSMakeRange(formatNameRange.location, authorName.length)];
                            }
                        }
                    }
                        break;
                        
                    case TGBridgeMessageActionUserChangedPhoto:
                        
                        break;
                        
                    case TGBridgeMessageActionChatAddMember:
                    case TGBridgeMessageActionChatDeleteMember:
                    {
                        NSString *authorName = author.displayName;
                        TGBridgeUser *user = users[@([actionAttachment.actionData[@"uid"] int32Value])];
                        
                        if (user.identifier == author.identifier)
                        {
                            NSString *formatString = (actionAttachment.actionType == TGBridgeMessageActionChatAddMember) ? TGLocalized(@"Notification.JoinedChat") : TGLocalized(@"Notification.LeftChat");
                            actionText = [[NSString alloc] initWithFormat:formatString, authorName];
                            
                            NSRange formatNameRange = [formatString rangeOfString:@"%@"];
                            if (formatNameRange.location != NSNotFound)
                            {
                                additionalAttributes = [TGNeoServiceMessageViewModel _mediumFontAttributeForRange:NSMakeRange(formatNameRange.location, authorName.length)];
                            }
                        }
                        else
                        {
                            NSString *userName = user.displayName;
                            NSString *formatString = (actionAttachment.actionType == TGBridgeMessageActionChatAddMember) ? TGLocalized(@"Notification.Invited") : TGLocalized(@"Notification.Kicked");
                            actionText = [[NSString alloc] initWithFormat:formatString, authorName, userName];
                            
                            NSRange formatNameRangeFirst = [formatString rangeOfString:@"%@"];
                            NSRange formatNameRangeSecond = formatNameRangeFirst.location != NSNotFound ? [formatString rangeOfString:@"%@" options:0 range:NSMakeRange(formatNameRangeFirst.location + formatNameRangeFirst.length, formatString.length - (formatNameRangeFirst.location + formatNameRangeFirst.length))] : NSMakeRange(NSNotFound, 0);
                            
                            if (formatNameRangeFirst.location != NSNotFound && formatNameRangeSecond.location != NSNotFound)
                            {
                                NSMutableArray *array = [[NSMutableArray alloc] init];
                                
                                NSRange rangeFirst = NSMakeRange(formatNameRangeFirst.location, authorName.length);
                                [array addObjectsFromArray:[TGNeoServiceMessageViewModel _mediumFontAttributeForRange:rangeFirst]];
                                [array addObjectsFromArray:[TGNeoServiceMessageViewModel _mediumFontAttributeForRange:NSMakeRange(rangeFirst.length - formatNameRangeFirst.length + formatNameRangeSecond.location, userName.length)]];
                                
                                additionalAttributes = array;
                            }
                        }
                    }
                        break;
                        
                    case TGBridgeMessageActionJoinedByLink:
                    {
                        NSString *authorName = author.displayName;
                        NSString *formatString = TGLocalized(@"Notification.JoinedGroupByLink");
                        actionText = [[NSString alloc] initWithFormat:formatString, authorName, actionAttachment.actionData[@"title"]];
                        
                        NSRange formatNameRange = [formatString rangeOfString:@"%@"];
                        if (formatNameRange.location != NSNotFound)
                        {
                            additionalAttributes = [TGNeoServiceMessageViewModel _mediumFontAttributeForRange:NSMakeRange(formatNameRange.location, authorName.length)];
                        }
                    }
                        break;
                        
                    case TGBridgeMessageActionCreateChat:
                    {
                        NSString *authorName = author.displayName;
                        NSString *formatString = TGLocalized(@"Notification.CreatedChatWithTitle");
                        actionText = [[NSString alloc] initWithFormat:formatString, authorName, actionAttachment.actionData[@"title"]];
                        
                        NSRange formatNameRange = [formatString rangeOfString:@"%@"];
                        if (formatNameRange.location != NSNotFound)
                        {
                            additionalAttributes = [TGNeoServiceMessageViewModel _mediumFontAttributeForRange:NSMakeRange(formatNameRange.location, authorName.length)];
                        }
                    }
                        break;
                        
                    case TGBridgeMessageActionContactRegistered:
                    {
                        actionText = TGLocalized(@"Notification.Joined");
                    }
                        break;
                        
                    case TGBridgeMessageActionChannelCreated:
                    {
                        actionText = TGLocalized(@"Notification.ChannelCreated");
                    }
                        
                    case TGBridgeMessageActionChannelInviter:
                    {
                        TGBridgeUser *user = users[@([actionAttachment.actionData[@"uid"] int32Value])];
                        NSString *authorName = user.displayName;
                        NSString *formatString = TGLocalized(@"Notification.ChannelInviter");
                        actionText = [[NSString alloc] initWithFormat:formatString, authorName];
                        
                        NSRange formatNameRange = [formatString rangeOfString:@"%@"];
                        if (formatNameRange.location != NSNotFound)
                        {
                            additionalAttributes = [TGNeoServiceMessageViewModel _mediumFontAttributeForRange:NSMakeRange(formatNameRange.location, authorName.length)];
                        }
                    }
                        break;
                        
                    default:
                        break;
                }
            }
        }
        
        if (actionText == nil)
            actionText = @"";
        
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.alignment = NSTextAlignmentCenter;
        
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:actionText attributes:@
        {   NSFontAttributeName: [UIFont systemFontOfSize:12],
            NSForegroundColorAttributeName: [UIColor whiteColor],
            NSParagraphStyleAttributeName: style
        }];
        
        if (additionalAttributes != nil)
        {
            NSUInteger count = additionalAttributes.count;
            for (NSUInteger i = 0; i < count; i += 2)
            {
                NSRange range = NSMakeRange(0, 0);
                [(NSValue *)[additionalAttributes objectAtIndex:i] getValue:&range];
                NSDictionary *attributes = [additionalAttributes objectAtIndex:i + 1];
                
                if (range.location + range.length <= attributedText.length)
                    [attributedText addAttributes:attributes range:range];
            }
        }
        
        _textModel = [[TGNeoLabelViewModel alloc] initWithAttributedText:attributedText];
        [self addSubmodel:_textModel];
    }
    return self;
}

- (instancetype)initWithChatInfo:(TGChatInfo *)chatInfo
{
    self = [super init];
    if (self != nil)
    {
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.alignment = NSTextAlignmentCenter;
        NSDictionary *attributes = @{ NSParagraphStyleAttributeName: style };
        
        _titleModel = [[TGNeoLabelViewModel alloc] initWithText:chatInfo.title font:[UIFont systemFontOfSize:12 weight:UIFontWeightSemibold] color:[UIColor whiteColor] attributes:attributes];
        [self addSubmodel:_titleModel];
        
        _textModel = [[TGNeoLabelViewModel alloc] initWithText:chatInfo.text font:[UIFont systemFontOfSize:12 weight:UIFontWeightMedium] color:[UIColor whiteColor] attributes:attributes];
        [self addSubmodel:_textModel];
    }
    return self;
}

- (CGSize)layoutWithContainerSize:(CGSize)containerSize
{
    CGSize titleSize = CGSizeZero;
    CGFloat textTopOffset = TGNeoServiceMessageInsets.top;
    
    if (_titleModel != nil)
    {
        titleSize = [_titleModel contentSizeWithContainerSize:CGSizeMake(containerSize.width, FLT_MAX)];
        _titleModel.frame = CGRectMake((containerSize.width - titleSize.width) / 2, textTopOffset, titleSize.width, titleSize.height);
        
        textTopOffset = CGRectGetMaxY(_titleModel.frame) + 1;
    }
    
    CGSize textSize = [_textModel contentSizeWithContainerSize:CGSizeMake(containerSize.width, FLT_MAX)];
    _textModel.frame = CGRectMake((containerSize.width - textSize.width) / 2, textTopOffset, textSize.width, textSize.height);
    
    CGSize contentSize = CGSizeMake(containerSize.width, CGRectGetMaxY(_textModel.frame) + TGNeoServiceMessageInsets.bottom);
    
    self.contentSize = contentSize;
    
    return contentSize;
}

+ (NSArray *)_mediumFontAttributeForRange:(NSRange)range
{
    NSDictionary *fontAttributes = @{ NSFontAttributeName: [UIFont systemFontOfSize:12.0f weight:UIFontWeightMedium], NSForegroundColorAttributeName: [UIColor whiteColor] };
    return [[NSArray alloc] initWithObjects:[[NSValue alloc] initWithBytes:&range objCType:@encode(NSRange)], fontAttributes, nil];
}

@end
