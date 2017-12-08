#import "TGAutoDownloadSettingsController.h"

#import "TGHeaderCollectionItem.h"
#import "TGSwitchCollectionItem.h"
#import "TGSizeSliderCollectionItem.h"

#import <LegacyComponents/ASWatcher.h>
#import "TGAppDelegate.h"

@interface TGAutoDownloadSettingsController () <ASWatcher>
{
    TGAutoDownloadSettingsMode _mode;
    
    TGSwitchCollectionItem *_cellularContactsItem;
    TGSwitchCollectionItem *_cellularOtherPrivateChatsItem;
    TGSwitchCollectionItem *_cellularGroupsItem;
    TGSwitchCollectionItem *_cellularChannelsItem;
    
    TGSwitchCollectionItem *_wifiContactsItem;
    TGSwitchCollectionItem *_wifiOtherPrivateChatsItem;
    TGSwitchCollectionItem *_wifiGroupsItem;
    TGSwitchCollectionItem *_wifiChannelsItem;
    
    TGSizeSliderCollectionItem *_sizeItem;
}

@property (nonatomic, strong) ASHandle *actionHandle;

@end

@implementation TGAutoDownloadSettingsController

- (instancetype)initWithMode:(TGAutoDownloadSettingsMode)mode
{
    self = [super init];
    if (self != nil)
    {
        _mode = mode;
        _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:true];
        
        [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Done") style:UIBarButtonItemStyleDone target:self action:@selector(donePressed)]];
        
        TGAutoDownloadPreferences *preferences = TGAppDelegateInstance.autoDownloadPreferences;
    
        if (mode != TGAutoDownloadSettingsModeSaveIncomingPhotos)
        {
            TGAutoDownloadMode autoDownloadMode = TGAutoDownloadModeNone;
            NSString *title = TGLocalized(@"AutoDownloadSettings.Title");
            switch (mode)
            {
                case TGAutoDownloadSettingsModePhotos:
                    autoDownloadMode = preferences.photos;
                    title = TGLocalized(@"AutoDownloadSettings.PhotosTitle");
                    break;
                
                case TGAutoDownloadSettingsModeVideos:
                    autoDownloadMode = preferences.videos;
                    title = TGLocalized(@"AutoDownloadSettings.VideosTitle");
                    break;
                    
                case TGAutoDownloadSettingsModeDocuments:
                    autoDownloadMode = preferences.documents;
                    title = TGLocalized(@"AutoDownloadSettings.DocumentsTitle");
                    break;
                    
                case TGAutoDownloadSettingsModeVoiceMessages:
                    autoDownloadMode = preferences.voiceMessages;
                    title = TGLocalized(@"AutoDownloadSettings.VoiceMessagesTitle");
                    break;
                    
                case TGAutoDownloadSettingsModeVideoMessages:
                    autoDownloadMode = preferences.videoMessages;
                    title = TGLocalized(@"AutoDownloadSettings.VideoMessagesTitle");
                    break;
                    
                default:
                    break;
            }
            
            self.title = title;
            TGCollectionMenuSection *cellularSection = [[TGCollectionMenuSection alloc] initWithItems:@
            [
             [[TGHeaderCollectionItem alloc] initWithTitle:TGLocalized(@"AutoDownloadSettings.Cellular")],
             _cellularContactsItem = [[TGSwitchCollectionItem alloc] initWithTitle:TGLocalized(@"AutoDownloadSettings.Contacts") isOn:[TGAutoDownloadPreferences shouldDownload:autoDownloadMode inChat:TGAutoDownloadChatContact networkType:TGNetworkTypeEdge]],
             _cellularOtherPrivateChatsItem = [[TGSwitchCollectionItem alloc] initWithTitle:TGLocalized(@"AutoDownloadSettings.PrivateChats") isOn:[TGAutoDownloadPreferences shouldDownload:autoDownloadMode inChat:TGAutoDownloadChatOtherPrivateChat networkType:TGNetworkTypeEdge]],
             _cellularGroupsItem = [[TGSwitchCollectionItem alloc] initWithTitle:TGLocalized(@"AutoDownloadSettings.GroupChats") isOn:[TGAutoDownloadPreferences shouldDownload:autoDownloadMode inChat:TGAutoDownloadChatGroup networkType:TGNetworkTypeEdge]],
             _cellularChannelsItem = [[TGSwitchCollectionItem alloc] initWithTitle:TGLocalized(@"AutoDownloadSettings.Channels") isOn:[TGAutoDownloadPreferences shouldDownload:autoDownloadMode inChat:TGAutoDownloadChatChannel networkType:TGNetworkTypeEdge]]
            ]];
            
            UIEdgeInsets topSectionInsets = cellularSection.insets;
            topSectionInsets.top = 32.0f;
            cellularSection.insets = topSectionInsets;
            [self.menuSections addSection:cellularSection];
            
            TGCollectionMenuSection *wifiSection = [[TGCollectionMenuSection alloc] initWithItems:@
            [
             [[TGHeaderCollectionItem alloc] initWithTitle:TGLocalized(@"AutoDownloadSettings.WiFi")],
             _wifiContactsItem = [[TGSwitchCollectionItem alloc] initWithTitle:TGLocalized(@"AutoDownloadSettings.Contacts") isOn:[TGAutoDownloadPreferences shouldDownload:autoDownloadMode inChat:TGAutoDownloadChatContact networkType:TGNetworkTypeWiFi]],
             _wifiOtherPrivateChatsItem = [[TGSwitchCollectionItem alloc] initWithTitle:TGLocalized(@"AutoDownloadSettings.PrivateChats") isOn:[TGAutoDownloadPreferences shouldDownload:autoDownloadMode inChat:TGAutoDownloadChatOtherPrivateChat networkType:TGNetworkTypeWiFi]],
             _wifiGroupsItem = [[TGSwitchCollectionItem alloc] initWithTitle:TGLocalized(@"AutoDownloadSettings.GroupChats") isOn:[TGAutoDownloadPreferences shouldDownload:autoDownloadMode inChat:TGAutoDownloadChatGroup networkType:TGNetworkTypeWiFi]],
             _wifiChannelsItem = [[TGSwitchCollectionItem alloc] initWithTitle:TGLocalized(@"AutoDownloadSettings.Channels") isOn:[TGAutoDownloadPreferences shouldDownload:autoDownloadMode inChat:TGAutoDownloadChatChannel networkType:TGNetworkTypeWiFi]]
            ]];
            [self.menuSections addSection:wifiSection];
            
            _cellularContactsItem.interfaceHandle = _actionHandle;
            _cellularOtherPrivateChatsItem.interfaceHandle = _actionHandle;
            _cellularGroupsItem.interfaceHandle = _actionHandle;
            _cellularChannelsItem.interfaceHandle = _actionHandle;
            
            _wifiContactsItem.interfaceHandle = _actionHandle;
            _wifiOtherPrivateChatsItem.interfaceHandle = _actionHandle;
            _wifiGroupsItem.interfaceHandle = _actionHandle;
            _wifiChannelsItem.interfaceHandle = _actionHandle;
            
            if (mode == TGAutoDownloadSettingsModeVideos || mode == TGAutoDownloadSettingsModeDocuments)
            {
                _sizeItem = [[TGSizeSliderCollectionItem alloc] init];
                _sizeItem.value = (mode == TGAutoDownloadSettingsModeVideos) ? preferences.maximumVideoSize : preferences.maximumDocumentSize;
                
                TGCollectionMenuSection *sizeSection = [[TGCollectionMenuSection alloc] initWithItems:@
                [
                    [[TGHeaderCollectionItem alloc] initWithTitle:TGLocalized(@"AutoDownloadSettings.LimitBySize")],
                    _sizeItem
                ]];
                [self.menuSections addSection:sizeSection];
            }
        }
        else
        {
            TGAutoDownloadMode autoDownloadMode = TGAppDelegateInstance.autoSavePhotosMode;
            
            self.title = TGLocalized(@"SaveIncomingPhotosSettings.Title");
            TGCollectionMenuSection *section = [[TGCollectionMenuSection alloc] initWithItems:@
            [
             [[TGHeaderCollectionItem alloc] initWithTitle:TGLocalized(@"SaveIncomingPhotosSettings.From")],
             _cellularContactsItem = [[TGSwitchCollectionItem alloc] initWithTitle:TGLocalized(@"AutoDownloadSettings.Contacts") isOn:[TGAutoDownloadPreferences shouldDownload:autoDownloadMode inChat:TGAutoDownloadChatContact networkType:TGNetworkTypeEdge]],
             _cellularOtherPrivateChatsItem = [[TGSwitchCollectionItem alloc] initWithTitle:TGLocalized(@"AutoDownloadSettings.PrivateChats") isOn:[TGAutoDownloadPreferences shouldDownload:autoDownloadMode inChat:TGAutoDownloadChatOtherPrivateChat networkType:TGNetworkTypeEdge]],
             _cellularGroupsItem = [[TGSwitchCollectionItem alloc] initWithTitle:TGLocalized(@"AutoDownloadSettings.GroupChats") isOn:[TGAutoDownloadPreferences shouldDownload:autoDownloadMode inChat:TGAutoDownloadChatGroup networkType:TGNetworkTypeEdge]],
             _cellularChannelsItem = [[TGSwitchCollectionItem alloc] initWithTitle:TGLocalized(@"AutoDownloadSettings.Channels") isOn:[TGAutoDownloadPreferences shouldDownload:autoDownloadMode inChat:TGAutoDownloadChatChannel networkType:TGNetworkTypeEdge]]
            ]];
            
            UIEdgeInsets topSectionInsets = section.insets;
            topSectionInsets.top = 32.0f;
            section.insets = topSectionInsets;
            [self.menuSections addSection:section];
        }
    }
    return self;
}

- (void)donePressed {
    [self.navigationController popViewControllerAnimated:true];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    TGAutoDownloadMode autoDownloadMode = TGAutoDownloadModeNone;
    if (_cellularContactsItem.isOn)
        autoDownloadMode |= TGAutoDownloadModeCellularContacts;
    if (_cellularOtherPrivateChatsItem.isOn)
        autoDownloadMode |= TGAutoDownloadModeCellularPrivateChats;
    if (_cellularGroupsItem.isOn)
        autoDownloadMode |= TGAutoDownloadModeCellularGroups;
    if (_cellularChannelsItem.isOn)
        autoDownloadMode |= TGAutoDownloadModeCellularChannels;
    
    if (_wifiContactsItem.isOn)
        autoDownloadMode |= TGAutoDownloadModeWifiContacts;
    if (_wifiOtherPrivateChatsItem.isOn)
        autoDownloadMode |= TGAutoDownloadModeWifiPrivateChats;
    if (_wifiGroupsItem.isOn)
        autoDownloadMode |= TGAutoDownloadModeWifiGroups;
    if (_wifiChannelsItem.isOn)
        autoDownloadMode |= TGAutoDownloadModeWifiChannels;
    
    if (_mode != TGAutoDownloadSettingsModeSaveIncomingPhotos)
    {
        TGAutoDownloadPreferences *preferences = TGAppDelegateInstance.autoDownloadPreferences;
        switch (_mode)
        {
            case TGAutoDownloadSettingsModePhotos:
                preferences = [preferences updatePhotosMode:autoDownloadMode];
                break;
                
            case TGAutoDownloadSettingsModeVideos:
                preferences = [preferences updateVideosMode:autoDownloadMode maximumSize:_sizeItem.value];
                break;
                
            case TGAutoDownloadSettingsModeDocuments:
                preferences = [preferences updateDocumentsMode:autoDownloadMode maximumSize:_sizeItem.value];
                break;
                
            case TGAutoDownloadSettingsModeVoiceMessages:
                preferences = [preferences updateVoiceMessagesMode:autoDownloadMode];
                break;
                
            case TGAutoDownloadSettingsModeVideoMessages:
                preferences = [preferences updateVideoMessagesMode:autoDownloadMode];
                break;
                
            default:
                break;
        }
        
        TGAppDelegateInstance.autoDownloadPreferences = preferences;
    }
    else
    {
        TGAppDelegateInstance.autoSavePhotosMode = autoDownloadMode;
    }
    
    if (self.settingsUpdated != nil)
        self.settingsUpdated();
}

@end
