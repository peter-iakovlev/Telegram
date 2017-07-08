#import "TGGroupInviteSheetItemView.h"

#import "TGLetteredAvatarView.h"
#import "TGFont.h"
#import "TGStringUtils.h"

#import "TGShareSheetSharePeersLayout.h"
#import "TGModernMediaCollectionView.h"
#import "TGShareSheetSharePeersCell.h"
#import "TGGroupInviteSheetMoreCell.h"

@interface TGGroupInviteSheetItemView () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout> {
    TGLetteredAvatarView *_avatarView;
    UILabel *_titleLabel;
    UILabel *_infoLabel;
    
    UICollectionView *_collectionView;
    TGShareSheetSharePeersLayout *_layout;
    
    NSArray *_recentPeers;
    NSUInteger _moreCount;
}

@end

@implementation TGGroupInviteSheetItemView

- (instancetype)initWithTitle:(NSString *)title photoUrlSmall:(NSString *)photoUrlSmall userCount:(NSInteger)userCount users:(NSArray *)users {
    self = [super init];
    if (self != nil) {
        _avatarView = [[TGLetteredAvatarView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 75.0f, 75.0f)];
        [_avatarView setSingleFontSize:28.0f doubleFontSize:28.0f useBoldFont:false];
        
        CGSize size = CGSizeMake(75.0f, 75.0f);
        static UIImage *placeholder = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            UIGraphicsBeginImageContextWithOptions(size, false, 0.0f);
            CGContextRef context = UIGraphicsGetCurrentContext();
            
            //!placeholder
            CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
            CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, size.width, size.height));
            CGContextSetStrokeColorWithColor(context, UIColorRGB(0xd9d9d9).CGColor);
            CGContextSetLineWidth(context, 1.0f);
            CGContextStrokeEllipseInRect(context, CGRectMake(0.5f, 0.5f, size.width - 1.0f, size.height - 1.0f));
            
            placeholder = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        });
        
        if (photoUrlSmall.length != 0) {
            [_avatarView loadImage:photoUrlSmall filter:@"circle:75x75" placeholder:placeholder];
        } else {
            [_avatarView loadGroupPlaceholderWithSize:size conversationId:1 title:title placeholder:placeholder];
        }
        
        [self addSubview:_avatarView];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.font = TGMediumSystemFontOfSize(17.0f);
        _titleLabel.text = title;
        [self addSubview:_titleLabel];
        
        _infoLabel = [[UILabel alloc] init];
        _infoLabel.backgroundColor = [UIColor clearColor];
        _infoLabel.textColor = UIColorRGB(0x8f8f94);
        _infoLabel.font = TGSystemFontOfSize(15.0f);
        _infoLabel.text = [[NSString alloc] initWithFormat:TGLocalized([TGStringUtils integerValueFormat:@"Invitation.Members_" value:userCount]), [TGStringUtils stringWithLocalizedNumber:userCount]];
        [self addSubview:_infoLabel];
        
        _layout = [[TGShareSheetSharePeersLayout alloc] init];
        _layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        _recentPeers = users;
        
        _collectionView = [[TGModernMediaCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_layout];
        _collectionView.backgroundColor = nil;
        _collectionView.opaque = false;
        _collectionView.showsHorizontalScrollIndicator = false;
        _collectionView.showsVerticalScrollIndicator = false;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.delaysContentTouches = false;
        _collectionView.canCancelContentTouches = true;
        
        if (userCount > (int)users.count) {
            _moreCount = userCount - users.count;
        }
        
        [_collectionView registerClass:[TGShareSheetSharePeersCell class] forCellWithReuseIdentifier:@"TGAttachmentSheetSharePeersCell"];
        [_collectionView registerClass:[TGGroupInviteSheetMoreCell class] forCellWithReuseIdentifier:@"TGGroupInviteSheetMoreCell"];
        [self addSubview:_collectionView];
    }
    return self;
}

- (CGFloat)preferredHeightForMaximumHeight:(CGFloat)__unused maximumHeight {
    return 266.0;
}

- (CGSize)collectionView:(UICollectionView *)__unused collectionView layout:(UICollectionViewLayout *)__unused collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)__unused indexPath
{
    return CGSizeMake(82.0f, 80.0f);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)__unused collectionView layout:(UICollectionViewLayout *)__unused collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(4.0f, (_moreCount != 0 && section == 1) ? 0.0f : 11.0f, 0.0f, (_moreCount != 0 && section == 0) ? 0.0f : 11.0f);
}

- (CGFloat)collectionView:(UICollectionView *)__unused collectionView layout:(UICollectionViewLayout *)__unused collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)__unused section
{
    return 0.0f;
}

- (CGFloat)collectionView:(UICollectionView *)__unused collectionView layout:(UICollectionViewLayout *)__unused collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)__unused section
{
    return 0.0f;
}

- (NSInteger)collectionView:(UICollectionView *)__unused collectionView numberOfItemsInSection:(NSInteger)section
{
    if (section == 0) {
        return _recentPeers.count;
    }
    return 1;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)__unused collectionView {
    return _moreCount == 0 ? 1 : 2;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        TGShareSheetSharePeersCell *cell = (TGShareSheetSharePeersCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"TGAttachmentSheetSharePeersCell" forIndexPath:indexPath];
        
        id peer = _recentPeers[indexPath.row];
        [cell setPeer:peer];
        return cell;
    } else {
        TGGroupInviteSheetMoreCell *cell = (TGGroupInviteSheetMoreCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"TGGroupInviteSheetMoreCell" forIndexPath:indexPath];
        [cell setCount:_moreCount];
        return cell;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _avatarView.frame = CGRectMake(CGFloor((self.bounds.size.width - _avatarView.frame.size.width) / 2.0f), 22.0f, _avatarView.frame.size.width, _avatarView.frame.size.height);
    
    CGSize titleSize = [_titleLabel.text sizeWithFont:_titleLabel.font];
    titleSize.width = MIN(titleSize.width, self.bounds.size.width - 20.0f);
    _titleLabel.frame = CGRectMake(CGFloor((self.bounds.size.width - titleSize.width) / 2.0f), 111.0f, titleSize.width, titleSize.height);
    
    CGSize infoSize = [_infoLabel.text sizeWithFont:_infoLabel.font];
    infoSize.width = MIN(infoSize.width, self.bounds.size.width - 20.0f);
    _infoLabel.frame = CGRectMake(CGFloor((self.bounds.size.width - infoSize.width) / 2.0f), 133.0f, infoSize.width, infoSize.height);
    
    _collectionView.frame = CGRectMake(0.0f, 160.0f, self.bounds.size.width, 100.0f);
}


@end
