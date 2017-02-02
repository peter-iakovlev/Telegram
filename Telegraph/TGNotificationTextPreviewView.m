#import "TGNotificationTextPreviewView.h"

#import "TGMessage.h"
#import "TGConversation.h"

#import "TGScrollIndicatorView.h"

@interface TGNotificationTextPreviewView () <UIScrollViewDelegate>
{
    UIScrollView *_scrollView;
    TGScrollIndicatorView *_scrollIndicator;
}
@end

@implementation TGNotificationTextPreviewView

- (instancetype)initWithMessage:(TGMessage *)message conversation:(TGConversation *)conversation peers:(NSDictionary *)peers
{
    self = [super initWithMessage:message conversation:conversation peers:peers];
    if (self != nil)
    {
        bool isSecretMessage = (conversation.encryptedData != nil);
        NSString *text = isSecretMessage ? [NSString stringWithFormat:TGLocalized(@"ENCRYPTED_MESSAGE"), @""] : message.text;
        if (!isSecretMessage) {
            for (id attachment in message.mediaAttachments) {
                if ([attachment isKindOfClass:[TGDocumentMediaAttachment class]]) {
                    if ([(TGDocumentMediaAttachment *)attachment isAnimated]) {
                        text = TGLocalized(@"Message.Animation");
                    }
                    else {
                        for (id attribute in ((TGDocumentMediaAttachment *)attachment).attributes) {
                            if ([attribute isKindOfClass:[TGDocumentAttributeAudio class]]) {
                                text = TGLocalized(@"Message.Audio");
                                break;
                            }
                        }
                    }
                    break;
                } else if ([attachment isKindOfClass:[TGGameMediaAttachment class]]) {
                    text = [@"🎮 " stringByAppendingString:((TGGameMediaAttachment *)attachment).title];
                } else if ([attachment isKindOfClass:[TGActionMediaAttachment class]]) {
                    /*TGActionMediaAttachment *actionAttachment = (TGActionMediaAttachment *)attachment;
                    switch (actionAttachment.actionType)
                    {
                        case TGMessageActionChatEditTitle:
                        {
                            text = [[NSString alloc] initWithFormat:TGLocalized(@"CHAT_TITLE_EDITED"), user.displayName, [((TGActionMediaAttachment *)attachment).actionData objectForKey:@"title"]];
                            
                            break;
                        }
                        case TGMessageActionChatEditPhoto:
                        {
                            text = [[NSString alloc] initWithFormat:TGLocalized(@"CHAT_PHOTO_EDITED"), user.displayName, chatName];
                            
                            break;
                        }
                        case TGMessageActionChatAddMember:
                        {
                            NSArray *uids = actionAttachment.actionData[@"uids"];
                            if (uids != nil) {
                                TGUser *authorUser = user;
                                NSMutableArray *subjectUsers = [[NSMutableArray alloc] init];
                                for (NSNumber *nUid in uids) {
                                    TGUser *subjectUser = [TGDatabaseInstance() loadUser:[nUid intValue]];
                                    if (user != nil) {
                                        [subjectUsers addObject:subjectUser];
                                    }
                                }
                                
                                if (subjectUsers.count == 1 && authorUser.uid == ((TGUser *)subjectUsers[0]).uid) {
                                    text = [[NSString alloc] initWithFormat:TGLocalized(@"CHAT_RETURNED"), authorUser.displayName, chatName];
                                } else {
                                    NSMutableString *subjectNames = [[NSMutableString alloc] init];
                                    for (TGUser *subjectUser in subjectUsers) {
                                        if (subjectNames.length != 0) {
                                            [subjectNames appendString:@", "];
                                        }
                                        [subjectNames appendString:subjectUser.displayName];
                                    }
                                    text = [[NSString alloc] initWithFormat:TGLocalized(@"CHAT_ADD_MEMBER"), authorUser.displayName, chatName, subjectNames];
                                }
                                attachmentFound = true;
                            } else {
                                NSNumber *nUid = [actionAttachment.actionData objectForKey:@"uid"];
                                if (nUid != nil)
                                {
                                    TGUser *subjectUser = [TGDatabaseInstance() loadUser:[nUid intValue]];
                                    
                                    if (subjectUser.uid == user.uid)
                                        text = [[NSString alloc] initWithFormat:TGLocalized(@"CHAT_RETURNED"), user.displayName, chatName];
                                    else if (subjectUser.uid == TGTelegraphInstance.clientUserId)
                                        text = [[NSString alloc] initWithFormat:TGLocalized(@"CHAT_ADD_YOU"), user.displayName, chatName];
                                    else
                                        text = [[NSString alloc] initWithFormat:TGLocalized(@"CHAT_ADD_MEMBER"), user.displayName, chatName, subjectUser.displayName];
                                    attachmentFound = true;
                                }
                            }
                            
                            break;
                        }
                        case TGMessageActionChatDeleteMember:
                        {
                            NSNumber *nUid = [actionAttachment.actionData objectForKey:@"uid"];
                            if (nUid != nil)
                            {
                                TGUser *subjectUser = [TGDatabaseInstance() loadUser:[nUid intValue]];
                                
                                if (subjectUser.uid == user.uid)
                                    text = [[NSString alloc] initWithFormat:TGLocalized(@"CHAT_LEFT"), user.displayName, chatName];
                                else if (subjectUser.uid == TGTelegraphInstance.clientUserId)
                                    text = [[NSString alloc] initWithFormat:TGLocalized(@"CHAT_DELETE_YOU"), user.displayName, chatName];
                                else
                                    text = [[NSString alloc] initWithFormat:TGLocalized(@"CHAT_DELETE_MEMBER"), user.displayName, chatName, subjectUser.displayName];
                                attachmentFound = true;
                            }
                            
                            break;
                        }
                        case TGMessageActionCreateChat:
                        {
                            text = [[NSString alloc] initWithFormat:TGLocalized(@"CHAT_CREATED"), user.displayName, chatName];
                            attachmentFound = true;
                            
                            break;
                        }
                        case TGMessageActionChannelCreated:
                        {
                            text = @"";
                            attachmentFound = true;
                            
                            break;
                        }
                        case TGMessageActionChannelCommentsStatusChanged:
                        {
                            text = [actionAttachment.actionData[@"enabled"] boolValue] ? TGLocalized(@"Channel.NotificationCommentsEnabled") : TGLocalized(@"Channel.NotificationCommentsDisabled");
                            attachmentFound = true;
                            
                            break;
                        }
                        case TGMessageActionJoinedByLink:
                        {
                            text = [[NSString alloc] initWithFormat:TGLocalized(@"Notification.JoinedGroupByLink"), user.displayName];
                            attachmentFound = true;
                            
                            break;
                        }
                        case TGMessageActionGroupMigratedTo:
                        {
                            migrationFound = true;
                            break;
                        }
                        case TGMessageActionGameScore:
                        {
                            TGMessage *replyMessage = nil;
                            for (id attachment in message.mediaAttachments) {
                                if ([attachment isKindOfClass:[TGReplyMessageMediaAttachment class]]) {
                                    replyMessage = ((TGReplyMessageMediaAttachment *)attachment).replyMessage;
                                    break;
                                }
                            }
                            
                            NSString *gameTitle = nil;
                            for (id attachment in replyMessage.mediaAttachments) {
                                if ([attachment isKindOfClass:[TGGameMediaAttachment class]]) {
                                    gameTitle = ((TGGameMediaAttachment *)attachment).title;
                                    break;
                                }
                            }
                            
                            int scoreCount = (int)[actionAttachment.actionData[@"score"] intValue];
                            
                            NSString *formatStringBase = @"";
                            if (gameTitle != nil) {
                                if (user.uid == TGTelegraphInstance.clientUserId) {
                                    formatStringBase = [TGStringUtils integerValueFormat:@"ServiceMessage.GameScoreSelfExtended_" value:scoreCount];
                                } else {
                                    formatStringBase = [TGStringUtils integerValueFormat:@"ServiceMessage.GameScoreExtended_" value:scoreCount];
                                }
                            } else {
                                if (user.uid == TGTelegraphInstance.clientUserId) {
                                    formatStringBase = [TGStringUtils integerValueFormat:@"ServiceMessage.GameScoreSelfSimple_" value:scoreCount];
                                } else {
                                    formatStringBase = [TGStringUtils integerValueFormat:@"ServiceMessage.GameScoreSimple_" value:scoreCount];
                                }
                            }
                            
                            NSMutableString *formatString = [[NSMutableString alloc] initWithString:TGLocalized(formatStringBase)];
                            
                            NSString *authorName = user.displayFirstName;
                            
                            for (int i = 0; i < 3; i++) {
                                NSRange nameRange = [formatString rangeOfString:@"{name}"];
                                NSRange scoreRange = [formatString rangeOfString:@"{score}"];
                                NSRange gameTitleRange = [formatString rangeOfString:@"{game}"];
                                
                                if (nameRange.location != NSNotFound) {
                                    if (scoreRange.location == NSNotFound || scoreRange.location > nameRange.location) {
                                        scoreRange.location = NSNotFound;
                                    }
                                    if (gameTitleRange.location == NSNotFound || gameTitleRange.location > nameRange.location) {
                                        gameTitleRange.location = NSNotFound;
                                    }
                                }
                                
                                if (scoreRange.location != NSNotFound) {
                                    if (nameRange.location == NSNotFound || nameRange.location > scoreRange.location) {
                                        nameRange.location = NSNotFound;
                                    }
                                    if (gameTitleRange.location == NSNotFound || gameTitleRange.location > scoreRange.location) {
                                        gameTitleRange.location = NSNotFound;
                                    }
                                }
                                
                                if (gameTitleRange.location != NSNotFound) {
                                    if (scoreRange.location == NSNotFound || scoreRange.location > gameTitleRange.location) {
                                        scoreRange.location = NSNotFound;
                                    }
                                    if (nameRange.location == NSNotFound || nameRange.location > gameTitleRange.location) {
                                        nameRange.location = NSNotFound;
                                    }
                                }
                                
                                if (nameRange.location != NSNotFound) {
                                    [formatString replaceCharactersInRange:nameRange withString:authorName];
                                }
                                
                                if (scoreRange.location != NSNotFound) {
                                    [formatString replaceCharactersInRange:scoreRange withString:[NSString stringWithFormat:@"%d", scoreCount]];
                                }
                                
                                if (gameTitleRange.location != NSNotFound) {
                                    [formatString replaceCharactersInRange:gameTitleRange withString:gameTitle];
                                }
                            }
                            
                            text = formatString;
                            attachmentFound = true;
                            
                            break;
                        }
                        default:
                            break;
                    }*/
                }
            }
        }
        [self setIcon:nil text:text];
        
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
        _scrollView.backgroundColor = [UIColor clearColor];
        _scrollView.delegate = self;
        _scrollView.showsHorizontalScrollIndicator = false;
        _scrollView.showsVerticalScrollIndicator = false;
        _scrollView.userInteractionEnabled = false;
        _scrollView.scrollEnabled = false;
        [self addSubview:_scrollView];
        
        _scrollIndicator = [[TGScrollIndicatorView alloc] init];
        _scrollIndicator.color = UIColorRGBA(0xb2b2b2, 0.6f);
        [_scrollIndicator setHidden:true animated:false];
        [_scrollView addSubview:_scrollIndicator];
        
        if (_replyHeader != nil)
            [_scrollView addSubview:_replyHeader];
        if (_forwardHeader != nil)
            [_scrollView addSubview:_forwardHeader];
        
        [_scrollView addSubview:_textLabel];
        
        _hasExtraContent = false;
    }
    return self;
}

- (void)setExpandProgress:(CGFloat)progress
{
    _expandProgress = (_textHeight < 20.0f && _headerHeight < FLT_EPSILON) ? 0.0f : progress;
    
    _scrollView.scrollEnabled = (progress >= 1.0f - FLT_EPSILON);
    
    [self _updateExpandProgress:progress hideText:false];
    
    [self setNeedsLayout];
}

- (CGFloat)maxContentHeight
{
    static dispatch_once_t onceToken;
    static CGFloat height = 0;
    dispatch_once(&onceToken, ^
    {
        NSString *string = @" \n\n\n\n\n\n\n\n\n\n ";
        CGFloat textHeight = [string sizeWithFont:_textLabel.font constrainedToSize:CGSizeMake(100.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping].height;
        textHeight = ceil(textHeight - textHeight / 8.0f);
        height = textHeight;
    });
    return height;
}

- (void)_layoutHeaders
{
    [super _layoutHeaders];
    
    CGFloat progress = _expandProgress;
    CGFloat headerOffset = (_titleEndPos - _titleStartPos) + (_titleStartPos - _titleEndPos) * progress;
    
    _replyHeader.frame = CGRectMake(0, 4 + headerOffset, _replyHeader.frame.size.width, _replyHeader.frame.size.height);
    _forwardHeader.frame = CGRectMake(0, 4 + headerOffset, _forwardHeader.frame.size.width, _forwardHeader.frame.size.height);
}

- (bool)isPanable
{
    return !_scrollView.userInteractionEnabled;
}

- (void)scrollViewDidScroll:(UIScrollView *)__unused scrollView
{
    if (_scrollView.isTracking)
        _isIdle = false;
    
    [_scrollIndicator updateScrollViewDidScroll];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)__unused scrollView
{
    [_scrollIndicator updateScrollViewDidEndScrolling];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)__unused scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
        [_scrollIndicator updateScrollViewDidEndScrolling];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat progress = _expandProgress;
    CGSize contentSize = CGSizeMake(_textLabel.frame.size.width + 10.0f, _textHeight + _headerHeight);
    CGFloat maxContentHeight = [self maxContentHeight];
    
    CGFloat maxScrollHeight = MIN(maxContentHeight, contentSize.height);
    CGFloat scrollHeight = _collapsedTextHeight + (maxScrollHeight - _collapsedTextHeight) * progress;
    
    if (!CGSizeEqualToSize(_scrollView.contentSize, contentSize))
        _scrollView.contentSize = contentSize;
    
    _scrollView.frame = CGRectMake(_textLabel.frame.origin.x, CGRectGetMaxY(_titleLabel.frame), contentSize.width, scrollHeight);

    CGFloat titleOffset = (_titleStartPos - _titleEndPos) * progress;
    CGFloat textOffset = (_textEndPos - _textStartPos) * progress + titleOffset;
    _textLabel.frame = CGRectMake(0, textOffset, _textLabel.frame.size.width, (_expandProgress > FLT_EPSILON) ? _textHeight : _collapsedTextHeight);
    
    bool contentClipped = (contentSize.height > maxContentHeight);
    [_scrollIndicator setHidden:!contentClipped animated:false];
    _scrollView.userInteractionEnabled = contentClipped;
}

@end
