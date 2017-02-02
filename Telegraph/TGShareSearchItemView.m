#import "TGShareSearchItemView.h"

#import "TGUser.h"
#import "TGConversation.h"

#import "TGFont.h"

#import "TGSearchBar.h"
#import "TGModernButton.h"
#import "UIControl+HitTestEdgeInsets.h"

@interface TGShareSearchItemView () <TGSearchBarDelegate>
{
    UIView *_headerWrapperView;
    UILabel *_titleLabel;
    UILabel *_subtitleLabel;
    TGModernButton *_searchButton;
    TGModernButton *_externalButton;
    
    TGSearchBar *_searchBar;
}
@end

@implementation TGShareSearchItemView

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        _disposable = [[SMetaDisposable alloc] init];
    
        _searchBar = [[TGSearchBar alloc] initWithFrame:CGRectZero style:TGSearchBarStyleLightAlwaysPlain];
        _searchBar.clipsToBounds = true;
        _searchBar.delegate = self;
        _searchBar.placeholder = TGLocalized(@"Common.Search");
        [_searchBar sizeToFit];
        _searchBar.delayActivity = false;
        _searchBar.alpha = 0.0f;
        [_searchBar customCancelButton];
        _searchBar.userInteractionEnabled = false;
        [self addSubview:_searchBar];
        
        _headerWrapperView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 64)];
        _headerWrapperView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:_headerWrapperView];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.backgroundColor = [UIColor whiteColor];
        _titleLabel.font = TGMediumSystemFontOfSize(20);
        _titleLabel.text = TGLocalized(@"ShareMenu.ShareTo");
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.userInteractionEnabled = false;
        [_titleLabel sizeToFit];
        [_headerWrapperView addSubview:_titleLabel];
        
        _subtitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _subtitleLabel.backgroundColor = [UIColor whiteColor];
        _subtitleLabel.font = TGSystemFontOfSize(11);
        _subtitleLabel.text = TGLocalized(@"ShareMenu.SelectChats");
        _subtitleLabel.textAlignment = NSTextAlignmentCenter;
        _subtitleLabel.textColor = UIColorRGB(0x8e8e93);
        _subtitleLabel.userInteractionEnabled = false;
        [_subtitleLabel sizeToFit];
        [_headerWrapperView addSubview:_subtitleLabel];
        
        _searchButton = [[TGModernButton alloc] initWithFrame:CGRectMake(0, 0, 52, 52)];
        _searchButton.adjustsImageWhenHighlighted = false;
        [_searchButton setImage:[UIImage imageNamed:@"ShareSearchIcon"] forState:UIControlStateNormal];
        [_searchButton addTarget:self action:@selector(searchButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [_headerWrapperView addSubview:_searchButton];
        
        _externalButton = [[TGModernButton alloc] initWithFrame:CGRectMake(0, 0, 52, 52)];
        _externalButton.adjustsImageWhenHighlighted = false;
        _externalButton.hidden = true;
        [_externalButton setImage:[UIImage imageNamed:@"ShareExternalIcon"] forState:UIControlStateNormal];
        [_externalButton addTarget:self action:@selector(externalButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [_headerWrapperView addSubview:_externalButton];
    }
    return self;
}

- (void)searchButtonPressed
{
    [self setSearchBarHidden:false animated:true];
}

- (void)externalButtonPressed
{
    if (self.externalPressed != nil)
        self.externalPressed();
}

- (void)setExternalButtonHidden:(bool)hidden
{
    _externalButton.hidden = hidden;
}

- (void)finishSearch
{
    if (self.didEndSearch != nil)
        self.didEndSearch(false);
    [self setSearchBarHidden:true animated:true];
    
    _searchBar.text = @"";
}

- (void)setSelectedPeerIds:(NSArray *)selectedPeerIds peers:(NSDictionary *)peers
{
    NSString *subtitle = TGLocalized(@"ShareMenu.SelectChats");
    
    if (selectedPeerIds.count > 0)
    {
        if (selectedPeerIds.count == 1)
        {
            subtitle = [self _titleForPeer:peers[selectedPeerIds.firstObject] full:true];
        }
        else
        {
            NSMutableArray *peerTitles = [[NSMutableArray alloc] init];
            for (id peerId in selectedPeerIds)
            {
                id peer = peers[peerId];
                if (peer != nil)
                {
                    NSString *title = [self _titleForPeer:peer full:false];
                    if (title.length > 0)
                        [peerTitles addObject:title];
                }
            }
            
            subtitle = [peerTitles componentsJoinedByString:@", "];
        }
    }
    
    _subtitleLabel.text = subtitle;
}

- (NSString *)_titleForPeer:(id)peer full:(bool)full
{
    if ([peer isKindOfClass:[TGConversation class]])
    {
        TGConversation *conversation = (TGConversation *)peer;
        if (conversation.additionalProperties[@"user"] != nil)
        {
            TGUser *user = conversation.additionalProperties[@"user"];
            return (user.uid == 777000) ? user.displayName : (full ? user.displayName : user.displayFirstName);
        }
        else
        {
            return conversation.chatTitle;
        }
    }
    else if ([peer isKindOfClass:[TGUser class]])
    {
        TGUser *user = (TGUser *)peer;
        return (user.uid == 777000) ? user.displayName : (full ? user.displayName : user.displayFirstName);
    }
    
    return @"";
}

- (void)setSearchBarHidden:(bool)hidden animated:(bool)animated
{
    if (animated)
    {
        void (^completionBlock)(BOOL) = ^(BOOL finished)
        {
            if (finished)
                _searchBar.userInteractionEnabled = !hidden;
        };
        if (!hidden)
        {
            [_searchBar setShowsCancelButton:true animated:false];
            if (self.didBeginSearch != nil)
                self.didBeginSearch();
            
            [_searchBar.customTextField becomeFirstResponder];
            [UIView animateWithDuration:0.15f animations:^
            {
                _searchBar.alpha = 1.0f;
                _headerWrapperView.alpha = 0.0f;
            } completion:completionBlock];
        }
        else
        {
            [_searchBar.customTextField resignFirstResponder];
            [UIView animateWithDuration:0.15f animations:^
            {
                _searchBar.alpha = 0.0f;
                _headerWrapperView.alpha = 1.0f;
            } completion:completionBlock];
        }
    }
    else
    {
        
    }
}

- (void)setShowActivity:(bool)activity
{
    [_searchBar setShowActivity:activity];
}

- (void)searchBar:(TGSearchBar *)__unused searchBar textDidChange:(NSString *)searchText
{
    if (!searchBar.maybeCustomTextField.isFirstResponder)
        return;
    
    if (self.textChanged != nil)
        self.textChanged(searchText);
}

- (void)searchBar:(TGSearchBar *)__unused searchBar willChangeHeight:(CGFloat)__unused newHeight
{
    
}

- (void)searchBarCancelButtonClicked:(TGSearchBar *)__unused searchBar
{
    if (self.didEndSearch != nil)
        self.didEndSearch(true);
    
    [self setSearchBarHidden:true animated:true];
}

- (bool)inhibitPan
{
    return _searchBar.maybeCustomTextField.isFirstResponder;
}

- (CGFloat)preferredHeightForWidth:(CGFloat)__unused width screenHeight:(CGFloat)__unused screenHeight
{
    return 68.0f;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _searchButton.frame = CGRectMake(8.0f, 8.0f, _searchButton.frame.size.width, _searchButton.frame.size.height);
    _externalButton.frame = CGRectMake(self.frame.size.width - _externalButton.frame.size.width - 8.0f, 8.0f, _searchButton.frame.size.width, _searchButton.frame.size.height);
    
    _searchButton.hitTestEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -(_externalButton.frame.origin.x - _searchButton.frame.origin.x - _searchButton.frame.size.width));
    
    _titleLabel.frame = CGRectMake(CGFloor((self.frame.size.width - _titleLabel.frame.size.width) / 2), 16.0f, _titleLabel.frame.size.width, _titleLabel.frame.size.height);
    _subtitleLabel.frame = CGRectMake(CGRectGetMaxX(_searchButton.frame), CGRectGetMaxY(_titleLabel.frame), self.frame.size.width - CGRectGetMaxX(_searchButton.frame) - _searchButton.frame.origin.x - _externalButton.frame.size.width, _subtitleLabel.frame.size.height);
    
    _searchBar.frame = CGRectMake(8.0f, 8.0f, self.bounds.size.width - 16.0f, [_searchBar baseHeight]);
}

@end
