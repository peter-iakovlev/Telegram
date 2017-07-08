#import "TGNetworkUsageController.h"

#import "TGFont.h"
#import "TGImageUtils.h"

#import "TGHeaderCollectionItem.h"
#import "TGVariantCollectionItem.h"
#import "TGButtonCollectionItem.h"
#import "TGCommentCollectionItem.h"

#import <MTProtoKit/MtProtoKit.h>

#import "TGTelegramNetworking.h"
#import "TGStringUtils.h"
#import "TGDateUtils.h"

#import "TGActionSheet.h"

static SSignal *statsSignal(MTNetworkUsageCalculationInfo *baseInfo) {
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
        MTNetworkUsageManager *manager = [[MTNetworkUsageManager alloc] initWithInfo:baseInfo];
        id<MTDisposable> disposable = [[manager currentStatsForKeys:@[
            @(TGTelegramNetworkUsageKeyDataIncomingWWAN),
            @(TGTelegramNetworkUsageKeyDataOutgoingWWAN),
            @(TGTelegramNetworkUsageKeyMediaGenericIncomingWWAN),
            @(TGTelegramNetworkUsageKeyMediaGenericOutgoingWWAN),
            @(TGTelegramNetworkUsageKeyMediaImageIncomingWWAN),
            @(TGTelegramNetworkUsageKeyMediaImageOutgoingWWAN),
            @(TGTelegramNetworkUsageKeyMediaVideoIncomingWWAN),
            @(TGTelegramNetworkUsageKeyMediaVideoOutgoingWWAN),
            @(TGTelegramNetworkUsageKeyMediaAudioIncomingWWAN),
            @(TGTelegramNetworkUsageKeyMediaAudioOutgoingWWAN),
            @(TGTelegramNetworkUsageKeyMediaDocumentIncomingWWAN),
            @(TGTelegramNetworkUsageKeyMediaDocumentOutgoingWWAN),
            @(TGTelegramNetworkUsageKeyCallIncomingWWAN),
            @(TGTelegramNetworkUsageKeyCallOutgoingWWAN),
            
            @(TGTelegramNetworkUsageKeyDataIncomingOther),
            @(TGTelegramNetworkUsageKeyDataOutgoingOther),
            @(TGTelegramNetworkUsageKeyMediaGenericIncomingOther),
            @(TGTelegramNetworkUsageKeyMediaGenericOutgoingOther),
            @(TGTelegramNetworkUsageKeyMediaImageIncomingOther),
            @(TGTelegramNetworkUsageKeyMediaImageOutgoingOther),
            @(TGTelegramNetworkUsageKeyMediaVideoIncomingOther),
            @(TGTelegramNetworkUsageKeyMediaVideoOutgoingOther),
            @(TGTelegramNetworkUsageKeyMediaAudioIncomingOther),
            @(TGTelegramNetworkUsageKeyMediaAudioOutgoingOther),
            @(TGTelegramNetworkUsageKeyMediaDocumentIncomingOther),
            @(TGTelegramNetworkUsageKeyMediaDocumentOutgoingOther),
            @(TGTelegramNetworkUsageKeyCallIncomingOther),
            @(TGTelegramNetworkUsageKeyCallOutgoingOther)
        ]] startWithNext:^(id next) {
            if (next == nil) {
                [subscriber putNext:@{}];
            } else {
                [subscriber putNext:next];
            }
        } error:^(id error) {
            [subscriber putError:error];
        } completed:^{
            [subscriber putCompletion];
        }];
        return [[SBlockDisposable alloc] initWithBlock:^{
            [disposable dispose];
        }];
    }];
}

@interface TGNetworkUsageController () {
    UIView *_segmentedControlContainer;
    UISegmentedControl *_segmentedControl;
    
    TGVariantCollectionItem *_cellularDataOutItem;
    TGVariantCollectionItem *_cellularDataInItem;
    TGVariantCollectionItem *_cellularMediaImageOutItem;
    TGVariantCollectionItem *_cellularMediaImageInItem;
    TGVariantCollectionItem *_cellularMediaVideoOutItem;
    TGVariantCollectionItem *_cellularMediaVideoInItem;
    TGVariantCollectionItem *_cellularMediaAudioOutItem;
    TGVariantCollectionItem *_cellularMediaAudioInItem;
    TGVariantCollectionItem *_cellularMediaDocumentOutItem;
    TGVariantCollectionItem *_cellularMediaDocumentInItem;
    TGVariantCollectionItem *_cellularCallOutItem;
    TGVariantCollectionItem *_cellularCallInItem;
    TGVariantCollectionItem *_cellularTotalOutItem;
    TGVariantCollectionItem *_cellularTotalInItem;
    
    TGVariantCollectionItem *_wifiDataOutItem;
    TGVariantCollectionItem *_wifiDataInItem;
    TGVariantCollectionItem *_wifiMediaImageOutItem;
    TGVariantCollectionItem *_wifiMediaImageInItem;
    TGVariantCollectionItem *_wifiMediaVideoOutItem;
    TGVariantCollectionItem *_wifiMediaVideoInItem;
    TGVariantCollectionItem *_wifiMediaAudioOutItem;
    TGVariantCollectionItem *_wifiMediaAudioInItem;
    TGVariantCollectionItem *_wifiMediaDocumentOutItem;
    TGVariantCollectionItem *_wifiMediaDocumentInItem;
    TGVariantCollectionItem *_wifiCallOutItem;
    TGVariantCollectionItem *_wifiCallInItem;
    TGVariantCollectionItem *_wifiTotalOutItem;
    TGVariantCollectionItem *_wifiTotalInItem;
    
    bool _wifiMode;
    SMetaDisposable *_statsDisposable;
    
    int32_t _lastCellularReset;
    int32_t _lastWifiReset;
}

@end

@implementation TGNetworkUsageController

- (instancetype)init {
    self = [super init];
    if (self != nil) {
        [self setTitleText:TGLocalized(@"ChatSettings.Title")];
        
        _segmentedControl = [[UISegmentedControl alloc] initWithItems:@[TGLocalized(@"NetworkUsageSettings.Cellular"), TGLocalized(@"NetworkUsageSettings.Wifi")]];
        
        /*[_segmentedControl setBackgroundImage:[UIImage imageNamed:@"ModernSegmentedControlBackground.png"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        [_segmentedControl setBackgroundImage:[UIImage imageNamed:@"ModernSegmentedControlSelected.png"] forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
        [_segmentedControl setBackgroundImage:[UIImage imageNamed:@"ModernSegmentedControlSelected.png"] forState:UIControlStateSelected | UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
        [_segmentedControl setBackgroundImage:[UIImage imageNamed:@"ModernSegmentedControlHighlighted.png"] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
        UIImage *dividerImage = [UIImage imageNamed:@"ModernSegmentedControlDivider.png"];
        [_segmentedControl setDividerImage:dividerImage forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        
        [_segmentedControl setTitleTextAttributes:@{UITextAttributeTextColor: TGAccentColor(), UITextAttributeTextShadowColor: [UIColor clearColor], UITextAttributeFont: TGSystemFontOfSize(13)} forState:UIControlStateNormal];
        [_segmentedControl setTitleTextAttributes:@{UITextAttributeTextColor: [UIColor whiteColor], UITextAttributeTextShadowColor: [UIColor clearColor], UITextAttributeFont: TGSystemFontOfSize(13)} forState:UIControlStateSelected];*/
        
        [_segmentedControl setSelectedSegmentIndex:0];
        [_segmentedControl addTarget:self action:@selector(segmentedControlChanged) forControlEvents:UIControlEventValueChanged];
        
        [_segmentedControl sizeToFit];
        if ([TGViewController hasLargeScreen] && _segmentedControl.frame.size.width < 200.0f) {
            _segmentedControl.frame = CGRectMake(0.0f, 0.0f, 200.0f, _segmentedControl.frame.size.height);
        }
        
        _segmentedControlContainer = [[UIView alloc] initWithFrame:_segmentedControl.bounds];
        [_segmentedControlContainer addSubview:_segmentedControl];
        [self setTitleView:_segmentedControlContainer];
        
        _cellularDataOutItem = [[TGVariantCollectionItem alloc] initWithTitle:TGLocalized(@"NetworkUsageSettings.BytesSent") action:@selector(noOp)];
        _cellularDataOutItem.hideArrow = true;
        _cellularDataOutItem.selectable = false;
        _cellularDataOutItem.highlightable = false;
        _cellularDataInItem = [[TGVariantCollectionItem alloc] initWithTitle:TGLocalized(@"NetworkUsageSettings.BytesReceived") action:@selector(noOp)];
        _cellularDataInItem.hideArrow = true;
        _cellularDataInItem.selectable = false;
        _cellularDataInItem.highlightable = false;
        
        _cellularMediaImageOutItem = [[TGVariantCollectionItem alloc] initWithTitle:TGLocalized(@"NetworkUsageSettings.BytesSent") action:@selector(noOp)];
        _cellularMediaImageOutItem.hideArrow = true;
        _cellularMediaImageOutItem.selectable = false;
        _cellularMediaImageOutItem.highlightable = false;
        _cellularMediaImageInItem = [[TGVariantCollectionItem alloc] initWithTitle:TGLocalized(@"NetworkUsageSettings.BytesReceived") action:@selector(noOp)];
        _cellularMediaImageInItem.hideArrow = true;
        _cellularMediaImageInItem.selectable = false;
        _cellularMediaImageInItem.highlightable = false;
        
        _cellularMediaVideoOutItem = [[TGVariantCollectionItem alloc] initWithTitle:TGLocalized(@"NetworkUsageSettings.BytesSent") action:@selector(noOp)];
        _cellularMediaVideoOutItem.hideArrow = true;
        _cellularMediaVideoOutItem.selectable = false;
        _cellularMediaVideoOutItem.highlightable = false;
        _cellularMediaVideoInItem = [[TGVariantCollectionItem alloc] initWithTitle:TGLocalized(@"NetworkUsageSettings.BytesReceived") action:@selector(noOp)];
        _cellularMediaVideoInItem.hideArrow = true;
        _cellularMediaVideoInItem.selectable = false;
        _cellularMediaVideoInItem.highlightable = false;
        
        _cellularMediaAudioOutItem = [[TGVariantCollectionItem alloc] initWithTitle:TGLocalized(@"NetworkUsageSettings.BytesSent") action:@selector(noOp)];
        _cellularMediaAudioOutItem.hideArrow = true;
        _cellularMediaAudioOutItem.selectable = false;
        _cellularMediaAudioOutItem.highlightable = false;
        _cellularMediaAudioInItem = [[TGVariantCollectionItem alloc] initWithTitle:TGLocalized(@"NetworkUsageSettings.BytesReceived") action:@selector(noOp)];
        _cellularMediaAudioInItem.hideArrow = true;
        _cellularMediaAudioInItem.selectable = false;
        _cellularMediaAudioInItem.highlightable = false;
        
        _cellularMediaDocumentOutItem = [[TGVariantCollectionItem alloc] initWithTitle:TGLocalized(@"NetworkUsageSettings.BytesSent") action:@selector(noOp)];
        _cellularMediaDocumentOutItem.hideArrow = true;
        _cellularMediaDocumentOutItem.selectable = false;
        _cellularMediaDocumentOutItem.highlightable = false;
        _cellularMediaDocumentInItem = [[TGVariantCollectionItem alloc] initWithTitle:TGLocalized(@"NetworkUsageSettings.BytesReceived") action:@selector(noOp)];
        _cellularMediaDocumentInItem.hideArrow = true;
        _cellularMediaDocumentInItem.selectable = false;
        _cellularMediaDocumentInItem.highlightable = false;
        
        _cellularCallOutItem = [[TGVariantCollectionItem alloc] initWithTitle:TGLocalized(@"NetworkUsageSettings.BytesSent") action:@selector(noOp)];
        _cellularCallOutItem.hideArrow = true;
        _cellularCallOutItem.selectable = false;
        _cellularCallOutItem.highlightable = false;
        _cellularCallInItem = [[TGVariantCollectionItem alloc] initWithTitle:TGLocalized(@"NetworkUsageSettings.BytesReceived") action:@selector(noOp)];
        _cellularCallInItem.hideArrow = true;
        _cellularCallInItem.selectable = false;
        _cellularCallInItem.highlightable = false;
        
        _cellularTotalOutItem = [[TGVariantCollectionItem alloc] initWithTitle:TGLocalized(@"NetworkUsageSettings.BytesSent") action:@selector(noOp)];
        _cellularTotalOutItem.hideArrow = true;
        _cellularTotalOutItem.selectable = false;
        _cellularTotalOutItem.highlightable = false;
        _cellularTotalInItem = [[TGVariantCollectionItem alloc] initWithTitle:TGLocalized(@"NetworkUsageSettings.BytesReceived") action:@selector(noOp)];
        _cellularTotalInItem.hideArrow = true;
        _cellularTotalInItem.selectable = false;
        _cellularTotalInItem.highlightable = false;
        
        _wifiDataOutItem = [[TGVariantCollectionItem alloc] initWithTitle:TGLocalized(@"NetworkUsageSettings.BytesSent") action:@selector(noOp)];
        _wifiDataOutItem.hideArrow = true;
        _wifiDataOutItem.selectable = false;
        _wifiDataOutItem.highlightable = false;
        _wifiDataInItem = [[TGVariantCollectionItem alloc] initWithTitle:TGLocalized(@"NetworkUsageSettings.BytesReceived") action:@selector(noOp)];
        _wifiDataInItem.hideArrow = true;
        _wifiDataInItem.selectable = false;
        _wifiDataInItem.highlightable = false;
        
        _wifiMediaImageOutItem = [[TGVariantCollectionItem alloc] initWithTitle:TGLocalized(@"NetworkUsageSettings.BytesSent") action:@selector(noOp)];
        _wifiMediaImageOutItem.hideArrow = true;
        _wifiMediaImageOutItem.selectable = false;
        _wifiMediaImageOutItem.highlightable = false;
        _wifiMediaImageInItem = [[TGVariantCollectionItem alloc] initWithTitle:TGLocalized(@"NetworkUsageSettings.BytesReceived") action:@selector(noOp)];
        _wifiMediaImageInItem.hideArrow = true;
        _wifiMediaImageInItem.selectable = false;
        _wifiMediaImageInItem.highlightable = false;
        
        _wifiMediaVideoOutItem = [[TGVariantCollectionItem alloc] initWithTitle:TGLocalized(@"NetworkUsageSettings.BytesSent") action:@selector(noOp)];
        _wifiMediaVideoOutItem.hideArrow = true;
        _wifiMediaVideoOutItem.selectable = false;
        _wifiMediaVideoOutItem.highlightable = false;
        _wifiMediaVideoInItem = [[TGVariantCollectionItem alloc] initWithTitle:TGLocalized(@"NetworkUsageSettings.BytesReceived") action:@selector(noOp)];
        _wifiMediaVideoInItem.hideArrow = true;
        _wifiMediaVideoInItem.selectable = false;
        _wifiMediaVideoInItem.highlightable = false;
        
        _wifiMediaAudioOutItem = [[TGVariantCollectionItem alloc] initWithTitle:TGLocalized(@"NetworkUsageSettings.BytesSent") action:@selector(noOp)];
        _wifiMediaAudioOutItem.hideArrow = true;
        _wifiMediaAudioOutItem.selectable = false;
        _wifiMediaAudioOutItem.highlightable = false;
        _wifiMediaAudioInItem = [[TGVariantCollectionItem alloc] initWithTitle:TGLocalized(@"NetworkUsageSettings.BytesReceived") action:@selector(noOp)];
        _wifiMediaAudioInItem.hideArrow = true;
        _wifiMediaAudioInItem.selectable = false;
        _wifiMediaAudioInItem.highlightable = false;
        
        _wifiMediaDocumentOutItem = [[TGVariantCollectionItem alloc] initWithTitle:TGLocalized(@"NetworkUsageSettings.BytesSent") action:@selector(noOp)];
        _wifiMediaDocumentOutItem.hideArrow = true;
        _wifiMediaDocumentOutItem.selectable = false;
        _wifiMediaDocumentOutItem.highlightable = false;
        _wifiMediaDocumentInItem = [[TGVariantCollectionItem alloc] initWithTitle:TGLocalized(@"NetworkUsageSettings.BytesReceived") action:@selector(noOp)];
        _wifiMediaDocumentInItem.hideArrow = true;
        _wifiMediaDocumentInItem.selectable = false;
        _wifiMediaDocumentInItem.highlightable = false;
        
        _wifiCallOutItem = [[TGVariantCollectionItem alloc] initWithTitle:TGLocalized(@"NetworkUsageSettings.BytesSent") action:@selector(noOp)];
        _wifiCallOutItem.hideArrow = true;
        _wifiCallOutItem.selectable = false;
        _wifiCallOutItem.highlightable = false;
        _wifiCallInItem = [[TGVariantCollectionItem alloc] initWithTitle:TGLocalized(@"NetworkUsageSettings.BytesReceived") action:@selector(noOp)];
        _wifiCallInItem.hideArrow = true;
        _wifiCallInItem.selectable = false;
        _wifiCallInItem.highlightable = false;
        
        _wifiTotalOutItem = [[TGVariantCollectionItem alloc] initWithTitle:TGLocalized(@"NetworkUsageSettings.BytesSent") action:@selector(noOp)];
        _wifiTotalOutItem.hideArrow = true;
        _wifiTotalOutItem.selectable = false;
        _wifiTotalOutItem.highlightable = false;
        _wifiTotalInItem = [[TGVariantCollectionItem alloc] initWithTitle:TGLocalized(@"NetworkUsageSettings.BytesReceived") action:@selector(noOp)];
        _wifiTotalInItem.hideArrow = true;
        _wifiTotalInItem.selectable = false;
        _wifiTotalInItem.highlightable = false;
        
        NSData *lastCellularReset = [NSData dataWithContentsOfFile:[[TGTelegramNetworking instance] cellularUsageResetPath]];
        NSData *lastWifiReset = [NSData dataWithContentsOfFile:[[TGTelegramNetworking instance] wifiUsageResetPath]];
        if (lastCellularReset.length == 4) {
            [lastCellularReset getBytes:&_lastCellularReset];
        }
        if (lastWifiReset.length == 4) {
            [lastWifiReset getBytes:&_lastWifiReset];
        }
        
        [self updateSections];
        
        _statsDisposable = [[SMetaDisposable alloc] init];
        [self beginUpdatingStats];
    }
    return self;
}

- (void)dealloc {
    [_statsDisposable dispose];
}

- (void)beginUpdatingStats {
    __weak TGNetworkUsageController *weakSelf = self;
    [_statsDisposable setDisposable:[[[[statsSignal([[TGTelegramNetworking instance] dataUsageInfo]) then:[[SSignal complete] delay:1.0 onQueue:[SQueue concurrentDefaultQueue]]] restart] deliverOn:[SQueue mainQueue]] startWithNext:^(NSDictionary *dict) {
        __strong TGNetworkUsageController *strongSelf = weakSelf;
        if (strongSelf != nil) {
            int64_t dataIncomingWWAN = [dict[@(TGTelegramNetworkUsageKeyDataIncomingWWAN)] longLongValue];
            int64_t dataOutgoingWWAN = [dict[@(TGTelegramNetworkUsageKeyDataOutgoingWWAN)] longLongValue];
            int64_t dataIncomingOther = [dict[@(TGTelegramNetworkUsageKeyDataIncomingOther)] longLongValue];
            int64_t dataOutgoingOther = [dict[@(TGTelegramNetworkUsageKeyDataOutgoingOther)] longLongValue];
            
            int64_t mediaGenericIncomingWWAN = [dict[@(TGTelegramNetworkUsageKeyMediaGenericIncomingWWAN)] longLongValue];
            int64_t mediaGenericOutgoingWWAN = [dict[@(TGTelegramNetworkUsageKeyMediaGenericOutgoingWWAN)] longLongValue];
            int64_t mediaGenericIncomingOther = [dict[@(TGTelegramNetworkUsageKeyMediaGenericIncomingOther)] longLongValue];
            int64_t mediaGenericOutgoingOther = [dict[@(TGTelegramNetworkUsageKeyMediaGenericOutgoingOther)] longLongValue];
            
            int64_t mediaImageIncomingWWAN = [dict[@(TGTelegramNetworkUsageKeyMediaDocumentIncomingWWAN)] longLongValue];
            int64_t mediaImageOutgoingWWAN = [dict[@(TGTelegramNetworkUsageKeyMediaImageOutgoingWWAN)] longLongValue];
            int64_t mediaImageIncomingOther = [dict[@(TGTelegramNetworkUsageKeyMediaImageIncomingOther)] longLongValue];
            int64_t mediaImageOutgoingOther = [dict[@(TGTelegramNetworkUsageKeyMediaImageOutgoingOther)] longLongValue];
            
            int64_t mediaVideoIncomingWWAN = [dict[@(TGTelegramNetworkUsageKeyMediaVideoIncomingWWAN)] longLongValue];
            int64_t mediaVideoOutgoingWWAN = [dict[@(TGTelegramNetworkUsageKeyMediaVideoOutgoingWWAN)] longLongValue];
            int64_t mediaVideoIncomingOther = [dict[@(TGTelegramNetworkUsageKeyMediaVideoIncomingOther)] longLongValue];
            int64_t mediaVideoOutgoingOther = [dict[@(TGTelegramNetworkUsageKeyMediaVideoOutgoingOther)] longLongValue];
            
            int64_t mediaAudioIncomingWWAN = [dict[@(TGTelegramNetworkUsageKeyMediaAudioIncomingWWAN)] longLongValue];
            int64_t mediaAudioOutgoingWWAN = [dict[@(TGTelegramNetworkUsageKeyMediaAudioOutgoingWWAN)] longLongValue];
            int64_t mediaAudioIncomingOther = [dict[@(TGTelegramNetworkUsageKeyMediaAudioIncomingOther)] longLongValue];
            int64_t mediaAudioOutgoingOther = [dict[@(TGTelegramNetworkUsageKeyMediaAudioOutgoingOther)] longLongValue];
            
            int64_t mediaDocumentIncomingWWAN = [dict[@(TGTelegramNetworkUsageKeyMediaDocumentIncomingWWAN)] longLongValue];
            int64_t mediaDocumentOutgoingWWAN = [dict[@(TGTelegramNetworkUsageKeyMediaDocumentOutgoingWWAN)] longLongValue];
            int64_t mediaDocumentIncomingOther = [dict[@(TGTelegramNetworkUsageKeyMediaDocumentIncomingOther)] longLongValue];
            int64_t mediaDocumentOutgoingOther = [dict[@(TGTelegramNetworkUsageKeyMediaDocumentOutgoingOther)] longLongValue];
            
            int64_t callIncomingWWAN = [dict[@(TGTelegramNetworkUsageKeyCallIncomingWWAN)] longLongValue];
            int64_t callOutgoingWWAN = [dict[@(TGTelegramNetworkUsageKeyCallOutgoingWWAN)] longLongValue];
            int64_t callIncomingOther = [dict[@(TGTelegramNetworkUsageKeyCallIncomingOther)] longLongValue];
            int64_t callOutgoingOther = [dict[@(TGTelegramNetworkUsageKeyCallOutgoingOther)] longLongValue];
            
            [strongSelf->_cellularDataInItem setVariant:[TGStringUtils stringForFileSize:dataIncomingWWAN + mediaGenericIncomingWWAN]];
            [strongSelf->_cellularDataOutItem setVariant:[TGStringUtils stringForFileSize:dataOutgoingWWAN + mediaGenericOutgoingWWAN]];
            
            [strongSelf->_cellularMediaImageInItem setVariant:[TGStringUtils stringForFileSize:mediaImageIncomingWWAN]];
            [strongSelf->_cellularMediaImageOutItem setVariant:[TGStringUtils stringForFileSize:mediaImageOutgoingWWAN]];
            
            [strongSelf->_cellularMediaVideoInItem setVariant:[TGStringUtils stringForFileSize:mediaVideoIncomingWWAN]];
            [strongSelf->_cellularMediaVideoOutItem setVariant:[TGStringUtils stringForFileSize:mediaVideoOutgoingWWAN]];
            
            [strongSelf->_cellularMediaAudioInItem setVariant:[TGStringUtils stringForFileSize:mediaAudioIncomingWWAN]];
            [strongSelf->_cellularMediaAudioOutItem setVariant:[TGStringUtils stringForFileSize:mediaAudioOutgoingWWAN]];
            
            [strongSelf->_cellularMediaDocumentInItem setVariant:[TGStringUtils stringForFileSize:mediaDocumentIncomingWWAN]];
            [strongSelf->_cellularMediaDocumentOutItem setVariant:[TGStringUtils stringForFileSize:mediaDocumentOutgoingWWAN]];
            
            [strongSelf->_cellularCallInItem setVariant:[TGStringUtils stringForFileSize:callIncomingWWAN]];
            [strongSelf->_cellularCallOutItem setVariant:[TGStringUtils stringForFileSize:callOutgoingWWAN]];
            
            [strongSelf->_wifiDataInItem setVariant:[TGStringUtils stringForFileSize:dataIncomingOther + mediaGenericIncomingOther]];
            [strongSelf->_wifiDataOutItem setVariant:[TGStringUtils stringForFileSize:dataOutgoingOther + mediaGenericOutgoingOther]];
            
            [strongSelf->_wifiMediaImageInItem setVariant:[TGStringUtils stringForFileSize:mediaImageIncomingOther]];
            [strongSelf->_wifiMediaImageOutItem setVariant:[TGStringUtils stringForFileSize:mediaImageOutgoingOther]];
            
            [strongSelf->_wifiMediaVideoInItem setVariant:[TGStringUtils stringForFileSize:mediaVideoIncomingOther]];
            [strongSelf->_wifiMediaVideoOutItem setVariant:[TGStringUtils stringForFileSize:mediaVideoOutgoingOther]];
            
            [strongSelf->_wifiMediaAudioInItem setVariant:[TGStringUtils stringForFileSize:mediaAudioIncomingOther]];
            [strongSelf->_wifiMediaAudioOutItem setVariant:[TGStringUtils stringForFileSize:mediaAudioOutgoingOther]];
            
            [strongSelf->_wifiMediaDocumentInItem setVariant:[TGStringUtils stringForFileSize:mediaDocumentIncomingOther]];
            [strongSelf->_wifiMediaDocumentOutItem setVariant:[TGStringUtils stringForFileSize:mediaDocumentOutgoingOther]];
            
            [strongSelf->_wifiCallInItem setVariant:[TGStringUtils stringForFileSize:callIncomingOther]];
            [strongSelf->_wifiCallOutItem setVariant:[TGStringUtils stringForFileSize:callOutgoingOther]];
            
            [strongSelf->_cellularTotalInItem setVariant:[TGStringUtils stringForFileSize:dataIncomingWWAN + mediaGenericIncomingWWAN + mediaImageIncomingWWAN + mediaVideoIncomingWWAN + mediaAudioIncomingWWAN + mediaDocumentIncomingWWAN + callIncomingWWAN]];
            [strongSelf->_cellularTotalOutItem setVariant:[TGStringUtils stringForFileSize:dataOutgoingWWAN + mediaGenericOutgoingWWAN + mediaImageOutgoingWWAN + mediaVideoOutgoingWWAN + mediaAudioOutgoingWWAN + mediaDocumentOutgoingWWAN + callOutgoingWWAN]];
            
            [strongSelf->_wifiTotalInItem setVariant:[TGStringUtils stringForFileSize:dataIncomingOther + mediaGenericIncomingOther + mediaImageIncomingOther + mediaVideoIncomingOther + mediaAudioIncomingOther + mediaDocumentIncomingOther + callIncomingOther]];
            [strongSelf->_wifiTotalOutItem setVariant:[TGStringUtils stringForFileSize:dataOutgoingOther + mediaGenericOutgoingOther + mediaImageOutgoingOther + mediaVideoOutgoingOther + mediaAudioOutgoingOther + mediaDocumentOutgoingOther + callOutgoingOther]];
        }
    }]];
}

- (void)updateSections {
    while (self.menuSections.sections.count != 0) {
        [self.menuSections deleteSection:0];
    }
    
    TGVariantCollectionItem *dataOutItem = nil;
    TGVariantCollectionItem *dataInItem = nil;
    TGVariantCollectionItem *mediaImageOutItem = nil;
    TGVariantCollectionItem *mediaImageInItem = nil;
    TGVariantCollectionItem *mediaVideoOutItem = nil;
    TGVariantCollectionItem *mediaVideoInItem = nil;
    TGVariantCollectionItem *mediaAudioOutItem = nil;
    TGVariantCollectionItem *mediaAudioInItem = nil;
    TGVariantCollectionItem *mediaDocumentOutItem = nil;
    TGVariantCollectionItem *mediaDocumentInItem = nil;
    TGVariantCollectionItem *callOutItem = nil;
    TGVariantCollectionItem *callInItem = nil;
    TGVariantCollectionItem *totalOutItem = nil;
    TGVariantCollectionItem *totalInItem = nil;
    
    if (_wifiMode) {
        dataOutItem = _wifiDataOutItem;
        dataInItem = _wifiDataInItem;
        mediaImageOutItem = _wifiMediaImageOutItem;
        mediaImageInItem = _wifiMediaImageInItem;
        mediaVideoOutItem = _wifiMediaVideoOutItem;
        mediaVideoInItem = _wifiMediaVideoInItem;
        mediaAudioOutItem = _wifiMediaAudioOutItem;
        mediaAudioInItem = _wifiMediaAudioInItem;
        mediaDocumentOutItem = _wifiMediaDocumentOutItem;
        mediaDocumentInItem = _wifiMediaDocumentInItem;
        callOutItem = _wifiCallOutItem;
        callInItem = _wifiCallInItem;
        totalOutItem = _wifiTotalOutItem;
        totalInItem = _wifiTotalInItem;
    } else {
        dataOutItem = _cellularDataOutItem;
        dataInItem = _cellularDataInItem;
        mediaImageOutItem = _cellularMediaImageOutItem;
        mediaImageInItem = _cellularMediaImageInItem;
        mediaVideoOutItem = _cellularMediaVideoOutItem;
        mediaVideoInItem = _cellularMediaVideoInItem;
        mediaAudioOutItem = _cellularMediaAudioOutItem;
        mediaAudioInItem = _cellularMediaAudioInItem;
        mediaDocumentOutItem = _cellularMediaDocumentOutItem;
        mediaDocumentInItem = _cellularMediaDocumentInItem;
        callOutItem = _cellularCallOutItem;
        callInItem = _cellularCallInItem;
        totalOutItem = _cellularTotalOutItem;
        totalInItem = _cellularTotalInItem;
    }
    
    TGCollectionMenuSection *dataSection = [[TGCollectionMenuSection alloc] initWithItems:@[
        [[TGHeaderCollectionItem alloc] initWithTitle:TGLocalized(@"NetworkUsageSettings.GeneralDataSection")],
        dataOutItem,
        dataInItem
    ]];
    UIEdgeInsets topSectionInsets = dataSection.insets;
    topSectionInsets.top = 32.0f;
    dataSection.insets = topSectionInsets;
    [self.menuSections addSection:dataSection];
    
    TGCollectionMenuSection *mediaImageSection = [[TGCollectionMenuSection alloc] initWithItems:@[
        [[TGHeaderCollectionItem alloc] initWithTitle:TGLocalized(@"NetworkUsageSettings.MediaImageDataSection")],
        mediaImageOutItem,
        mediaImageInItem
    ]];
    [self.menuSections addSection:mediaImageSection];
    
    TGCollectionMenuSection *mediaVideoSection = [[TGCollectionMenuSection alloc] initWithItems:@[
        [[TGHeaderCollectionItem alloc] initWithTitle:TGLocalized(@"NetworkUsageSettings.MediaVideoDataSection")],
        mediaVideoOutItem,
        mediaVideoInItem
    ]];
    [self.menuSections addSection:mediaVideoSection];
    
    TGCollectionMenuSection *mediaAudioSection = [[TGCollectionMenuSection alloc] initWithItems:@[
        [[TGHeaderCollectionItem alloc] initWithTitle:TGLocalized(@"NetworkUsageSettings.MediaAudioDataSection")],
        mediaAudioOutItem,
        mediaAudioInItem
    ]];
    [self.menuSections addSection:mediaAudioSection];
    
    TGCollectionMenuSection *mediaDocumentSection = [[TGCollectionMenuSection alloc] initWithItems:@[
        [[TGHeaderCollectionItem alloc] initWithTitle:TGLocalized(@"NetworkUsageSettings.MediaDocumentDataSection")],
        mediaDocumentOutItem,
        mediaDocumentInItem
    ]];
    [self.menuSections addSection:mediaDocumentSection];
    
    TGCollectionMenuSection *callSection = [[TGCollectionMenuSection alloc] initWithItems:@[
        [[TGHeaderCollectionItem alloc] initWithTitle:TGLocalized(@"NetworkUsageSettings.CallDataSection")],
        callOutItem,
        callInItem
    ]];
    [self.menuSections addSection:callSection];
    
    TGCollectionMenuSection *totalSection = [[TGCollectionMenuSection alloc] initWithItems:@[
        [[TGHeaderCollectionItem alloc] initWithTitle:TGLocalized(@"NetworkUsageSettings.TotalSection")],
        totalOutItem,
        totalInItem
    ]];
    [self.menuSections addSection:totalSection];
    
    NSMutableArray *resetItems = [[NSMutableArray alloc] init];
    TGButtonCollectionItem *resetItem = [[TGButtonCollectionItem alloc] initWithTitle:TGLocalized(@"NetworkUsageSettings.ResetStats") action:@selector(resetStatsPressed)];
    resetItem.deselectAutomatically = true;
    [resetItems addObject:resetItem];
    if (_wifiMode) {
        if (_lastWifiReset != 0) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"E, d MMM yyyy HH:mm"];
            NSString *dateStringPlain = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:_lastWifiReset]];
            
            NSString *text = [NSString stringWithFormat:TGLocalized(@"NetworkUsageSettings.WifiUsageSince"), dateStringPlain];
            [resetItems addObject:[[TGCommentCollectionItem alloc] initWithText:text]];
        }
    } else {
        if (_lastCellularReset != 0) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"E, d MMM yyyy HH:mm"];
            NSString *dateStringPlain = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:_lastCellularReset]];

            NSString *text = [NSString stringWithFormat:TGLocalized(@"NetworkUsageSettings.CellularUsageSince"), dateStringPlain];
            [resetItems addObject:[[TGCommentCollectionItem alloc] initWithText:text]];
        }
    }
    TGCollectionMenuSection *resetSection = [[TGCollectionMenuSection alloc] initWithItems:resetItems];
    [self.menuSections addSection:resetSection];
    
    [self.collectionView reloadData];
}

- (void)segmentedControlChanged
{
    int index = (int)_segmentedControl.selectedSegmentIndex;
    
    if (index == 0) {
        if (_wifiMode) {
            _wifiMode = false;
            [self updateSections];
        }
    } else if (index == 1) {
        if (!_wifiMode) {
            _wifiMode = true;
            [self updateSections];
        }
    }
}

- (void)noOp {
}

- (void)resetStatsPressed {
    __weak TGNetworkUsageController *weakSelf = self;
    [[[TGActionSheet alloc] initWithTitle:TGLocalized(@"NetworkUsageSettings.ResetStatsConfirmation") actions:@[
        [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"NetworkUsageSettings.ResetStats") action:@"reset" type:TGActionSheetActionTypeDestructive],
        [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.Cancel") action:@"cancel" type:TGActionSheetActionTypeCancel]
    ] actionBlock:^(__unused id target, NSString *action) {
        __strong TGNetworkUsageController *strongSelf = weakSelf;
        if (strongSelf != nil && [action isEqualToString:@"reset"]) {
            MTNetworkUsageManager *dataManager = [[MTNetworkUsageManager alloc] initWithInfo:[[TGTelegramNetworking instance] dataUsageInfo]];
            NSArray<NSNumber *> *keys = @[];
            if (strongSelf->_wifiMode) {
                keys = @[
                    @(TGTelegramNetworkUsageKeyDataIncomingOther),
                    @(TGTelegramNetworkUsageKeyDataOutgoingOther),
                    @(TGTelegramNetworkUsageKeyMediaGenericIncomingOther),
                    @(TGTelegramNetworkUsageKeyMediaGenericOutgoingOther),
                    @(TGTelegramNetworkUsageKeyMediaImageIncomingOther),
                    @(TGTelegramNetworkUsageKeyMediaImageOutgoingOther),
                    @(TGTelegramNetworkUsageKeyMediaVideoIncomingOther),
                    @(TGTelegramNetworkUsageKeyMediaVideoOutgoingOther),
                    @(TGTelegramNetworkUsageKeyMediaAudioIncomingOther),
                    @(TGTelegramNetworkUsageKeyMediaAudioOutgoingOther),
                    @(TGTelegramNetworkUsageKeyMediaDocumentIncomingOther),
                    @(TGTelegramNetworkUsageKeyMediaDocumentOutgoingOther),
                    @(TGTelegramNetworkUsageKeyCallIncomingOther),
                    @(TGTelegramNetworkUsageKeyCallOutgoingOther),
                ];
            } else {
                keys = @[
                    @(TGTelegramNetworkUsageKeyDataIncomingWWAN),
                    @(TGTelegramNetworkUsageKeyDataOutgoingWWAN),
                    @(TGTelegramNetworkUsageKeyMediaGenericIncomingWWAN),
                    @(TGTelegramNetworkUsageKeyMediaGenericOutgoingWWAN),
                    @(TGTelegramNetworkUsageKeyMediaImageIncomingWWAN),
                    @(TGTelegramNetworkUsageKeyMediaImageOutgoingWWAN),
                    @(TGTelegramNetworkUsageKeyMediaVideoIncomingWWAN),
                    @(TGTelegramNetworkUsageKeyMediaVideoOutgoingWWAN),
                    @(TGTelegramNetworkUsageKeyMediaAudioIncomingWWAN),
                    @(TGTelegramNetworkUsageKeyMediaAudioOutgoingWWAN),
                    @(TGTelegramNetworkUsageKeyMediaDocumentIncomingWWAN),
                    @(TGTelegramNetworkUsageKeyMediaDocumentOutgoingWWAN),
                    @(TGTelegramNetworkUsageKeyCallIncomingWWAN),
                    @(TGTelegramNetworkUsageKeyCallOutgoingWWAN),
                ];
            }
            [dataManager resetKeys:keys setKeys:@{} completion:^{
                TGDispatchOnMainThread(^{
                    if (strongSelf->_wifiMode) {
                        strongSelf->_lastWifiReset = (int32_t)[[NSDate date] timeIntervalSince1970];
                        [[NSData dataWithBytes:&strongSelf->_lastWifiReset length:4] writeToFile:[[TGTelegramNetworking instance] wifiUsageResetPath] atomically:true];
                    } else {
                       strongSelf-> _lastCellularReset = (int32_t)[[NSDate date] timeIntervalSince1970];
                        [[NSData dataWithBytes:&strongSelf->_lastCellularReset length:4] writeToFile:[[TGTelegramNetworking instance] cellularUsageResetPath] atomically:true];
                    }
                    
                    [strongSelf updateSections];
                    [strongSelf beginUpdatingStats];
                });
            }];
        }
    } target:self] showInView:self.view];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        _segmentedControl.frame = CGRectMake(_segmentedControl.frame.origin.x, _segmentedControl.frame.origin.y, _segmentedControl.frame.size.width, 29.0f);
    } else {
        _segmentedControl.frame = CGRectMake(_segmentedControl.frame.origin.x, _segmentedControl.frame.origin.y, _segmentedControl.frame.size.width, 21.0f);
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    if (!TGIsPad()) {
        if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
            _segmentedControl.frame = CGRectMake(_segmentedControl.frame.origin.x, _segmentedControl.frame.origin.y, _segmentedControl.frame.size.width, 29.0f);
        } else {
            _segmentedControl.frame = CGRectMake(_segmentedControl.frame.origin.x, _segmentedControl.frame.origin.y, _segmentedControl.frame.size.width, 21.0f);
        }
    }
}

@end
