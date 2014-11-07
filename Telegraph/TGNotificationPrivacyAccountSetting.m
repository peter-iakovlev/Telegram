#import "TGNotificationPrivacyAccountSetting.h"

@implementation TGNotificationPrivacyAccountSetting

- (instancetype)initWithDefaultValues
{
    return [self initWithLastSeenPrimarySetting:TGPrivacySettingsLastSeenPrimarySettingEverybody alwaysShareWithUserIds:@[] neverShareWithUserIds:@[]];
}

- (instancetype)initWithLastSeenPrimarySetting:(TGPrivacySettingsLastSeenPrimarySetting)lastSeenPrimarySetting alwaysShareWithUserIds:(NSArray *)alwaysShareWithUserIds neverShareWithUserIds:(NSArray *)neverShareWithUserIds
{
    self = [super init];
    if (self != nil)
    {
        _lastSeenPrimarySetting = lastSeenPrimarySetting;
        _alwaysShareWithUserIds = alwaysShareWithUserIds;
        _neverShareWithUserIds  = neverShareWithUserIds;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    return [self initWithLastSeenPrimarySetting:(TGPrivacySettingsLastSeenPrimarySetting)[aDecoder decodeInt32ForKey:@"lastSeenPrimarySetting"] alwaysShareWithUserIds:[aDecoder decodeObjectForKey:@"alwaysShareWithUserIds"] neverShareWithUserIds:[aDecoder decodeObjectForKey:@"neverShareWithUserIds"]];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInt32:(int32_t)_lastSeenPrimarySetting forKey:@"lastSeenPrimarySetting"];
    if (_alwaysShareWithUserIds != nil)
        [aCoder encodeObject:_alwaysShareWithUserIds forKey:@"alwaysShareWithUserIds"];
    if (_neverShareWithUserIds != nil)
        [aCoder encodeObject:_neverShareWithUserIds forKey:@"neverShareWithUserIds"];
}

- (BOOL)isEqual:(id)object
{
    return [object isKindOfClass:[TGNotificationPrivacyAccountSetting class]] && _lastSeenPrimarySetting == ((TGNotificationPrivacyAccountSetting *)object)->_lastSeenPrimarySetting && TGObjectCompare(_alwaysShareWithUserIds, ((TGNotificationPrivacyAccountSetting *)object)->_alwaysShareWithUserIds) && TGObjectCompare(_neverShareWithUserIds, ((TGNotificationPrivacyAccountSetting *)object)->_neverShareWithUserIds);
}

- (TGNotificationPrivacyAccountSetting *)normalize
{
    NSArray *neverShareWithUserIds = nil;
    NSArray *alwaysShareWithUserIds = nil;
    
    switch (_lastSeenPrimarySetting)
    {
        case TGPrivacySettingsLastSeenPrimarySettingEverybody:
            neverShareWithUserIds = _neverShareWithUserIds;
            break;
        case TGPrivacySettingsLastSeenPrimarySettingContacts:
            neverShareWithUserIds = _neverShareWithUserIds;
            alwaysShareWithUserIds = _alwaysShareWithUserIds;
            break;
        case TGPrivacySettingsLastSeenPrimarySettingNobody:
            alwaysShareWithUserIds = _alwaysShareWithUserIds;
            break;
    }
    
    return [[TGNotificationPrivacyAccountSetting alloc] initWithLastSeenPrimarySetting:_lastSeenPrimarySetting alwaysShareWithUserIds:alwaysShareWithUserIds neverShareWithUserIds:neverShareWithUserIds];
}

- (TGNotificationPrivacyAccountSetting *)modifyLastSeenPrimarySetting:(TGPrivacySettingsLastSeenPrimarySetting)lastSeenPrimarySetting
{
    return [[TGNotificationPrivacyAccountSetting alloc] initWithLastSeenPrimarySetting:lastSeenPrimarySetting alwaysShareWithUserIds:_alwaysShareWithUserIds neverShareWithUserIds:_neverShareWithUserIds];
}

- (TGNotificationPrivacyAccountSetting *)modifyAlwaysShareWithUserIds:(NSArray *)alwaysShareWithUserIds
{
    NSMutableArray *array = [[NSMutableArray alloc] initWithArray:_neverShareWithUserIds];
    [array removeObjectsInArray:alwaysShareWithUserIds];
    return [[TGNotificationPrivacyAccountSetting alloc] initWithLastSeenPrimarySetting:_lastSeenPrimarySetting alwaysShareWithUserIds:alwaysShareWithUserIds neverShareWithUserIds:array];
}

- (TGNotificationPrivacyAccountSetting *)modifyNeverShareWithUserIds:(NSArray *)neverShareWithUserIds
{
    NSMutableArray *array = [[NSMutableArray alloc] initWithArray:_alwaysShareWithUserIds];
    [array removeObjectsInArray:neverShareWithUserIds];
    return [[TGNotificationPrivacyAccountSetting alloc] initWithLastSeenPrimarySetting:_lastSeenPrimarySetting alwaysShareWithUserIds:array neverShareWithUserIds:neverShareWithUserIds];
}

@end
