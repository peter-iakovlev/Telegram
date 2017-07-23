#import "TGMediaAssetsMomentsController.h"
#import "TGMediaAssetsModernLibrary.h"
#import "TGMediaAssetMomentList.h"
#import "TGMediaAssetFetchResult.h"

#import "TGMediaAssetsUtils.h"

#import "TGMediaPickerLayoutMetrics.h"
#import "TGMediaAssetsMomentsCollectionView.h"
#import "TGMediaAssetsMomentsCollectionLayout.h"
#import "TGMediaAssetsMomentsSectionHeaderView.h"
#import "TGMediaAssetsMomentsSectionHeader.h"

#import "TGMediaAssetsPhotoCell.h"
#import "TGMediaAssetsVideoCell.h"
#import "TGMediaAssetsGifCell.h"

#import "TGMediaPickerModernGalleryMixin.h"

#import "TGMediaPickerToolbarView.h"

#import "TGMediaPickerSelectionGestureRecognizer.h"

@interface TGMediaAssetsMomentsController ()
{
    TGMediaAssetMomentList *_momentList;
    
    TGMediaAssetsMomentsCollectionLayout *_collectionLayout;
}
@end

@implementation TGMediaAssetsMomentsController

- (instancetype)initWithAssetsLibrary:(TGMediaAssetsLibrary *)assetsLibrary momentList:(TGMediaAssetMomentList *)momentList intent:(TGMediaAssetsControllerIntent)intent selectionContext:(TGMediaSelectionContext *)selectionContext editingContext:(TGMediaEditingContext *)editingContext
{
    self = [super initWithAssetsLibrary:assetsLibrary assetGroup:nil intent:intent selectionContext:selectionContext editingContext:editingContext];
    if (self != nil)
    {
        _momentList = momentList;
        
        [self setTitle:TGLocalized(@"MediaPicker.Moments")];
    }
    return self;
}

- (Class)_collectionViewClass
{
    return [TGMediaAssetsMomentsCollectionView class];
}

- (UICollectionViewLayout *)_collectionLayout
{
    if (_collectionLayout == nil)
        _collectionLayout = [[TGMediaAssetsMomentsCollectionLayout alloc] init];
    
    return _collectionLayout;
}

- (void)viewDidLoad
{
    CGSize frameSize = self.view.frame.size;
    CGRect collectionViewFrame = CGRectMake(0.0f, 0.0f, frameSize.width, frameSize.height);
    _collectionViewWidth = collectionViewFrame.size.width;
    _collectionView.frame = collectionViewFrame;
    
    _layoutMetrics = [TGMediaPickerLayoutMetrics defaultLayoutMetrics];
    
    _preheatMixin.imageSize = [_layoutMetrics imageSize];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    dispatch_async(dispatch_get_main_queue(), ^
    {
        [_collectionView reloadData];
        [_collectionView layoutSubviews];
        [self _adjustContentOffsetToBottom];
    });
}

- (void)collectionView:(UICollectionView *)__unused collectionView setupSectionHeaderView:(TGMediaAssetsMomentsSectionHeaderView *)sectionHeaderView forSectionHeader:(TGMediaAssetsMomentsSectionHeader *)sectionHeader
{
    TGMediaAssetMoment *moment = _momentList[sectionHeader.index];
    
    NSString *title = @"";
    NSString *location = @"";
    NSString *date = @"";
    if (moment.title.length > 0)
    {
        title = moment.title;
        if (moment.locationNames.count > 0)
            location = moment.locationNames.firstObject;
        date = [TGMediaAssetsDateUtils formattedDateRangeWithStartDate:moment.startDate endDate:moment.endDate currentDate:[NSDate date] shortDate:true];
    }
    else
    {
        title = [TGMediaAssetsDateUtils formattedDateRangeWithStartDate:moment.startDate endDate:moment.endDate currentDate:[NSDate date] shortDate:false];
    }
    
    [sectionHeaderView setTitle:title location:location date:date];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)__unused collectionView
{
    return _momentList.count;
}

- (NSInteger)collectionView:(UICollectionView *)__unused collectionView numberOfItemsInSection:(NSInteger)__unused section
{
    return ((TGMediaAssetMoment *)_momentList[section]).assetCount;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)__unused collectionView layout:(UICollectionViewLayout *)__unused collectionViewLayout insetForSectionAtIndex:(NSInteger)__unused section
{
    return UIEdgeInsetsMake(48.0f, 0.0f, 0.0f, 0.0f);
}

- (TGMediaPickerModernGalleryMixin *)_galleryMixinForItem:(id)item thumbnailImage:(UIImage *)thumbnailImage selectionContext:(TGMediaSelectionContext *)selectionContext editingContext:(TGMediaEditingContext *)editingContext suggestionContext:(TGSuggestionContext *)suggestionContext hasCaptions:(bool)hasCaption asFile:(bool)asFile
{
    return [[TGMediaPickerModernGalleryMixin alloc] initWithItem:item momentList:_momentList parentController:self thumbnailImage:thumbnailImage selectionContext:selectionContext editingContext:editingContext suggestionContext:suggestionContext hasCaptions:hasCaption hasTimer:false inhibitDocumentCaptions:false asFile:asFile itemsLimit:0];
}

- (id)_itemAtIndexPath:(NSIndexPath *)indexPath
{
    TGMediaAssetFetchResult *fetchResult = [_momentList[indexPath.section] fetchResult];
    TGMediaAsset *asset = [fetchResult assetAtIndex:indexPath.row];
    return asset;
}

@end
