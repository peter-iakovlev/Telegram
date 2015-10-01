#import "TGLiveNearbyActor.h"

#import "ActionStage.h"
#import "SGraphObjectNode.h"

#import "TGTelegraph.h"

#import "TGUser+Telegraph.h"

#import "TGTimer.h"

#import "TGInterfaceManager.h"

#include <set>

@interface TGLiveNearbyActor () <TGLocateContactsProtocol>

@property (nonatomic, strong) TGTimer *timer;

@property (nonatomic, strong) NSDictionary *currentResults;

@property (nonatomic) bool previousRequestHasFailed;

@end

@implementation TGLiveNearbyActor

@synthesize actionHandle = _actionHandle;

@synthesize discloseLocation = _discloseLocation;

@synthesize timer = _timer;

@synthesize currentResults = _currentResults;

@synthesize previousRequestHasFailed = _previousRequestHasFailed;

+ (NSString *)genericPath
{
    return @"/tg/liveNearby";
}

- (id)initWithPath:(NSString *)path
{
    self = [super initWithPath:path];
    if (self != nil)
    {
        _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:false];
    }
    return self;
}

- (void)dealloc
{
    [_actionHandle reset];
    [ActionStageInstance() removeWatcher:self];
}

- (void)execute:(NSDictionary *)__unused options
{
    [self checkNearby];
}

- (NSDictionary *)currentResults
{
    return _currentResults;
}

- (void)checkNearbyIfFailed
{
    if (_previousRequestHasFailed)
    {
        _previousRequestHasFailed = false;
        [self checkNearby];
    }
}

- (void)forceCheckNearby
{
    _previousRequestHasFailed = false;
    [self checkNearby];
}

- (void)checkNearby
{
    if (self.cancelToken != nil)
    {
        [TGTelegraphInstance cancelRequestByToken:self.cancelToken];
        self.cancelToken = nil;
    }
    
    if (_timer != nil)
    {
        [_timer invalidate];
        _timer = nil;
    }
    
    [ActionStageInstance() requestActor:@"/tg/location/current/(100)" options:nil watcher:self];
}

- (void)actorCompleted:(int)resultCode path:(NSString *)path result:(id)result
{
    if ([path hasPrefix:@"/tg/location/current"])
    {
        if (resultCode == ASStatusSuccess)
        {
            NSDictionary *locationDict = ((SGraphObjectNode *)result).object;
            double latitude = [[locationDict objectForKey:@"latitude"] doubleValue];
            double longitude = [[locationDict objectForKey:@"longitude"] doubleValue];
            
            self.cancelToken = [TGTelegraphInstance doLocateContacts:latitude longitude:longitude radius:160 discloseLocation:_discloseLocation actor:self];
            
            _previousRequestHasFailed = false;
        }
        else
        {
            _previousRequestHasFailed = true;
        }
        
        _timer = [[TGTimer alloc] initWithTimeout:(70.0) repeat:false completion:^
        {
            [self checkNearby];
        } queue:[ActionStageInstance() globalStageDispatchQueue]];
        [_timer start];
    }
}

- (void)addResults:(TLcontacts_Located *)locatedContacts
{
    [self mixResults:locatedContacts replaceCurrent:false];
}

- (void)locateSuccess:(TLcontacts_Located *)locatedContacts
{
    [self mixResults:locatedContacts replaceCurrent:true];
}

- (void)mixResults:(TLcontacts_Located *)locatedContacts replaceCurrent:(bool)replaceCurrent
{
    NSMutableDictionary *usersMap = [[NSMutableDictionary alloc] initWithCapacity:locatedContacts.users.count];
    for (TLUser *userDesc in locatedContacts.users)
    {
        TGUser *user = [[TGUser alloc] initWithTelegraphUserDesc:userDesc];
        if (user.uid != 0)
            [usersMap setObject:user forKey:[[NSNumber alloc] initWithInt:user.uid]];
    }
    
    NSMutableArray *usersLocated = [[NSMutableArray alloc] init];
    NSMutableArray *hiddenUsersLocated = [[NSMutableArray alloc] init];
    
    Class contactLocatedPreviewClass = [TLContactLocated$contactLocatedPreview class];
    Class contactLocatedClass = [TLContactLocated$contactLocated class];
    
    for (TLContactLocated *contactDesc in locatedContacts.results)
    {
        if ([contactDesc isKindOfClass:contactLocatedClass])
        {
            TLContactLocated$contactLocated *concreteContact = (TLContactLocated$contactLocated *)contactDesc;
            
            TGUser *user = [usersMap objectForKey:[[NSNumber alloc] initWithInt:concreteContact.user_id]];
            if (user != nil)
            {
                double latitude = 0.0;
                double longitude = 0.0;
                
                if ([concreteContact.location isKindOfClass:[TLGeoPoint$geoPoint class]])
                {
                    TLGeoPoint$geoPoint *geoPoint = (TLGeoPoint$geoPoint *)concreteContact.location;
                    latitude = geoPoint.lat;
                    longitude = geoPoint.n_long;
                }
                else if ([concreteContact.location isKindOfClass:[TLGeoPoint$geoPlace class]])
                {
                    TLGeoPoint$geoPlace *geoPlace = (TLGeoPoint$geoPlace *)concreteContact.location;
                    latitude = geoPlace.lat;
                    longitude = geoPlace.n_long;
                }
                
                user.customProperties = [[NSDictionary alloc] initWithObjectsAndKeys:[[NSNumber alloc] initWithDouble:latitude], @"latitude", [[NSNumber alloc] initWithDouble:longitude], @"longitude", [[NSNumber alloc] initWithInt:concreteContact.date], @"date", [[NSNumber alloc] initWithInt:concreteContact.distance], @"distance", nil];
                
                [usersLocated addObject:user];
            }
        }
        else if ([contactDesc isKindOfClass:contactLocatedPreviewClass])
        {
            TLContactLocated$contactLocatedPreview *concreteContact = (TLContactLocated$contactLocatedPreview *)contactDesc;
            
            [hiddenUsersLocated addObject:[[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithString:concreteContact.n_hash], @"hash", [[NSNumber alloc] initWithInt:concreteContact.date], @"date", nil]];
        }
    }
    
    std::set<int> currentUids;
    for (TGUser *user in [_currentResults objectForKey:@"usersLocated"])
    {
        currentUids.insert(user.uid);
    }
    
    if (!replaceCurrent)
    {
        NSMutableSet *newLocatedUids = [[NSMutableSet alloc] initWithCapacity:usersLocated.count];
        for (TGUser *user in usersLocated)
        {
            [newLocatedUids addObject:[[NSNumber alloc] initWithInt:user.uid]];
        }
        
        NSMutableSet *newLocatedHashes = [[NSMutableSet alloc] initWithCapacity:hiddenUsersLocated.count];
        for (NSDictionary *dict in hiddenUsersLocated)
        {
            [newLocatedHashes addObject:[dict objectForKey:@"hash"]];
        }
        
        NSArray *currentUsersLocated = [_currentResults objectForKey:@"usersLocated"];
        NSArray *currentHiddenUsersLocated = [_currentResults objectForKey:@"hiddenUsersLocated"];
        
        for (TGUser *user in currentUsersLocated)
        {
            if (![newLocatedUids containsObject:[[NSNumber alloc] initWithInt:user.uid]])
                [usersLocated addObject:user];
        }
        
        for (NSDictionary *dict in currentHiddenUsersLocated)
        {
            if (![newLocatedHashes containsObject:[dict objectForKey:@"hash"]])
                [hiddenUsersLocated addObject:dict];
        }
    }
    
    [usersLocated sortUsingComparator:^NSComparisonResult(TGUser *user1, TGUser *user2)
    {
        return [[user1.customProperties objectForKey:@"distance"] intValue] < [[user2.customProperties objectForKey:@"distance"] intValue] ? NSOrderedAscending : NSOrderedDescending;
    }];
    
    [hiddenUsersLocated sortUsingComparator:^NSComparisonResult(NSDictionary *desc1, NSDictionary *desc2)
    {
        return [[desc1 objectForKey:@"distance"] intValue] < [[desc2 objectForKey:@"distance"] intValue] ? NSOrderedAscending : NSOrderedDescending;
    }];
    
    bool hasNew = false;
    for (TGUser *user in usersLocated)
    {
        if (currentUids.find(user.uid) == currentUids.end())
        {
            hasNew = true;
            break;
        }
    }
    
    NSDictionary *result = [[NSDictionary alloc] initWithObjectsAndKeys:usersLocated, @"usersLocated", hiddenUsersLocated, @"hiddenUsersLocated", nil];
    
    _currentResults = result;
    [ActionStageInstance() dispatchResource:@"/tg/liveNearbyResults" resource:[[SGraphObjectNode alloc] initWithObject:result]];
    
    if (hasNew)
    {
        [[TGInterfaceManager instance] displayNearbyBannerIdNeeded:(int)usersLocated.count];
    }
}

- (void)locateFailed
{
}

- (void)cancel
{
    [_timer invalidate];
    _timer = nil;
    
    [ActionStageInstance() removeWatcher:self];
    
    [super cancel];
}

@end
