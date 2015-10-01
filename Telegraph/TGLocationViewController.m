#import "TGLocationViewController.h"

#import <MapKit/MapKit.h>

#import "TGFont.h"
#import "TGImageUtils.h"
#import "TGLocationUtils.h"
#import "TGActionSheet.h"

#import "TGAccessChecker.h"

#import "TGUser.h"
#import "TGConversation.h"
#import "TGLocationVenue.h"
#import "TGLocationAnnotation.h"
#import "TGLocationMediaAttachment.h"

#import "TGLocationTitleView.h"
#import "TGLocationMapView.h"
#import "TGLocationTrackingButton.h"
#import "TGLocationMapModeControl.h"
#import "TGLocationPinAnnotationView.h"

@interface TGLocationViewController () <MKMapViewDelegate>
{
    CLLocationManager *_locationManager;
    
    bool _locationServicesDisabled;
    CLLocation *_location;
    TGVenueAttachment *_venue;
    TGLocationAnnotation *_annotation;
    
    CLLocation *_lastDirectionsStartLocation;
    MKDirections *_directions;
    
    TGLocationTitleView *_titleView;
    TGLocationMapView *_mapView;
    
    UIView *_toolbarView;
    TGLocationTrackingButton *_trackingButton;
    TGLocationMapModeControl *_mapModeControl;
    id _peer;
}
@end

@implementation TGLocationViewController

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        self.titleText = TGLocalized(@"Map.LocationTitle");
        
        _locationManager = [[CLLocationManager alloc] init];
    }
    return self;
}

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate venue:(TGVenueAttachment *)venue peer:(id)peer
{
    self = [self init];
    if (self != nil)
    {
        _location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
        _venue = venue;
        _peer = peer;
        NSString *title = @"";
        if ([peer isKindOfClass:[TGUser class]]) {
            title = ((TGUser *)peer).displayName;
        } else if ([peer isKindOfClass:[TGConversation class]]) {
            title = ((TGConversation *)peer).chatTitle;
        }
        _annotation = [[TGLocationAnnotation alloc] initWithCoordinate:coordinate title:title];
    }
    return self;
}

- (void)dealloc
{
    _mapView.delegate = nil;
}

- (void)loadView
{
    [super loadView];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _mapView = [[TGLocationMapView alloc] initWithFrame:self.view.bounds];
    _mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _mapView.delegate = self;
    _mapView.showsUserLocation = true;
    _mapView.tapEnabled = false;
    [self.view addSubview:_mapView];
    
    _toolbarView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, self.view.frame.size.height - 44.0f, self.view.frame.size.width, 44.0f)];
    _toolbarView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    _toolbarView.backgroundColor = UIColorRGBA(0xf7f7f7, 1.0f);
    UIView *stripeView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, _toolbarView.frame.size.width, TGIsRetina() ? 0.5f : 1.0f)];
    stripeView.backgroundColor = UIColorRGB(0xb2b2b2);
    stripeView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [_toolbarView addSubview:stripeView];
    [self.view addSubview:_toolbarView];
    
    _trackingButton = [[TGLocationTrackingButton alloc] initWithFrame:CGRectMake(4, 2, 44, 44)];
    [_trackingButton addTarget:self action:@selector(trackingModePressed) forControlEvents:UIControlEventTouchUpInside];
    [_toolbarView addSubview:_trackingButton];
    
    _mapModeControl = [[TGLocationMapModeControl alloc] init];
    _mapModeControl.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _mapModeControl.frame = CGRectMake(55, (_toolbarView.frame.size.height - 29) / 2 + 0.5f, _toolbarView.frame.size.width - 55 - 7.5f, 29);
    _mapModeControl.selectedSegmentIndex = MAX(0, MIN(2, (NSInteger)_mapView.mapType));
    [_mapModeControl addTarget:self action:@selector(mapModeControlValueChanged:) forControlEvents:UIControlEventValueChanged];
    [_toolbarView addSubview:_mapModeControl];
    
    NSString *backButtonTitle = TGLocalized(@"Common.Back");
    if (TGIsPad())
    {
        backButtonTitle = TGLocalized(@"Common.Done");
        [self setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:backButtonTitle style:UIBarButtonItemStyleDone target:self action:@selector(dismissButtonPressed)]];
    }
    
    CGFloat actionsButtonWidth = 0.0f;
    if (iosMajorVersion() >= 7)
    {
        [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionsButtonPressed)]];
        actionsButtonWidth = 48.0f;
    }
    else
    {
        NSString *actionsButtonTitle = TGLocalized(@"Common.More");
        [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:actionsButtonTitle style:UIBarButtonItemStylePlain target:self action:@selector(actionsButtonPressed)]];
        
        actionsButtonWidth = 16.0f;
        if ([actionsButtonTitle respondsToSelector:@selector(sizeWithAttributes:)])
            actionsButtonWidth += CGCeil([actionsButtonTitle sizeWithAttributes:@{ NSFontAttributeName:TGSystemFontOfSize(16.0f) }].width);
        else
            actionsButtonWidth += CGCeil([actionsButtonTitle sizeWithFont:TGSystemFontOfSize(16.0f)].width);
    }
    
    if (_venue.title.length > 0)
    {
        CGFloat backButtonWidth = 27.0f + 8.0f;
        if ([backButtonTitle respondsToSelector:@selector(sizeWithAttributes:)])
            backButtonWidth += CGCeil([backButtonTitle sizeWithAttributes:@{ NSFontAttributeName:TGSystemFontOfSize(16.0f) }].width);
        else
            backButtonWidth += CGCeil([backButtonTitle sizeWithFont:TGSystemFontOfSize(16.0f)].width);
    
        _titleView = [[TGLocationTitleView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
        _titleView.title = _venue.title;
        _titleView.address = _venue.address;
        _titleView.interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
        _titleView.backButtonWidth = backButtonWidth;
        _titleView.actionsButtonWidth = actionsButtonWidth;
        [self setTitleView:_titleView];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [_mapView addAnnotation:_annotation];
    [_mapView selectAnnotation:_annotation animated:false];
    
    _mapView.region = MKCoordinateRegionMake(_location.coordinate, MKCoordinateSpanMake(0.008, 0.008));
    
    [TGLocationUtils requestWhenInUserLocationAuthorizationWithLocationManager:_locationManager];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    _titleView.interfaceOrientation = toInterfaceOrientation;
}

#pragma mark - Actions

- (void)dismissButtonPressed
{
    [self.presentingViewController dismissViewControllerAnimated:true completion:nil];
}

- (void)actionsButtonPressed
{
    NSMutableArray *actions = [[NSMutableArray alloc] init];
    if (self.forwardPressed != nil)
        [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Map.ForwardViaTelegram") action:@"forward"]];
    
    if (_venue.venueId.length > 0)
    {
        if ([_venue.provider isEqualToString:TGLocationGooglePlacesVenueProvider])
            [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Map.OpenInGooglePlus") action:@"openInGooglePlus"]];
        else if ([_venue.provider isEqualToString:TGLocationFoursquareVenueProvider])
            [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Map.OpenInFoursquare") action:@"openInFoursquare"]];
    }
    
    [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Map.OpenInMaps") action:@"openInMaps"]];
    
    NSMutableArray *openInActions = [[NSMutableArray alloc] init];
    
    if ([TGLocationUtils isGoogleMapsInstalled])
        [openInActions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Map.OpenInGoogleMaps") action:@"openInGoogleMaps"]];
    
    if ([TGLocationUtils isHereMapsInstalled])
        [openInActions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Map.OpenInHereMaps") action:@"openInHereMaps"]];
    
    if ([TGLocationUtils isYandexMapsInstalled])
        [openInActions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Map.OpenInYandexMaps") action:@"openInYandexMaps"]];
    
    TGActionSheetAction *cancelAction = [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.Cancel") action:@"cancel" type:TGActionSheetActionTypeCancel];
    
    if (openInActions.count < 3)
    {
        [actions addObjectsFromArray:openInActions];
    }
    else
    {
        [actions addObject:openInActions.firstObject];
        [openInActions removeObjectAtIndex:0];
        [openInActions addObject:cancelAction];
        
        [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Map.More") action:@"more"]];
    }
    
    [actions addObject:cancelAction];
    
    void (^actionBlock)(TGLocationViewController *, NSString *) = ^(TGLocationViewController *controller, NSString *action)
    {
        if ([action isEqualToString:@"more"])
        {
            [[[TGActionSheet alloc] initWithTitle:TGLocalized(@"Map.OpenIn") actions:openInActions actionBlock:^(TGLocationViewController *controller, NSString *action)
            {
                [controller _performActionSheetAction:action];
            } target:controller] showInView:controller.view];
        }
        else
        {
            [controller _performActionSheetAction:action];
        }
    };
    
    [[[TGActionSheet alloc] initWithTitle:nil actions:actions actionBlock:actionBlock target:self] showInView:self.view];
}

- (void)_performActionSheetAction:(NSString *)action
{
    if ([action isEqualToString:@"forward"])
        self.forwardPressed();
    else if ([action isEqualToString:@"openInMaps"])
        [TGLocationUtils openMapsWithCoordinate:_location.coordinate withDirections:false locationName:_annotation.title];
    else if ([action isEqualToString:@"openInGoogleMaps"])
        [TGLocationUtils openGoogleMapsWithCoordinate:_location.coordinate withDirections:false];
    else if ([action isEqualToString:@"openInHereMaps"])
        [TGLocationUtils openHereMapsWithCoordinate:_location.coordinate];
    else if ([action isEqualToString:@"openInYandexMaps"])
        [TGLocationUtils openYandexMapsWithCoordinate:_location.coordinate withDirections:false];
    else if ([action isEqualToString:@"openInGooglePlus"])
        [TGLocationUtils openGoogleWithPlaceId:_venue.venueId];
    else if ([action isEqualToString:@"openInFoursquare"])
        [TGLocationUtils openFoursquareWithVenueId:_venue.venueId];
}

- (void)trackingModePressed
{
    if (![self _hasUserLocation])
    {
        if (![TGLocationUtils requestWhenInUserLocationAuthorizationWithLocationManager:_locationManager])
        {
            if (_locationServicesDisabled)
                [TGAccessChecker checkLocationAuthorizationStatusForIntent:TGLocationAccessIntentTracking alertDismissComlpetion:nil];
        }
        
        [self updateLocationAvailability];
        return;
    }

    TGLocationTrackingMode newMode = TGLocationTrackingModeNone;

    switch ([TGLocationTrackingButton locationTrackingModeWithUserTrackingMode:_mapView.userTrackingMode])
    {
        case TGLocationTrackingModeFollow:
            newMode = TGLocationTrackingModeFollowWithHeading;
            break;
            
        case TGLocationTrackingModeFollowWithHeading:
            newMode = TGLocationTrackingModeNone;
            break;
            
        default:
            newMode = TGLocationTrackingModeFollow;
            break;
    }
    
    [_mapView setUserTrackingMode:[TGLocationTrackingButton userTrackingModeWithLocationTrackingMode:newMode] animated:true];
    [_trackingButton setTrackingMode:newMode animated:true];
}

- (void)mapModeControlValueChanged:(TGLocationMapModeControl *)sender
{
    NSInteger mapMode = MAX(0, MIN(2, sender.selectedSegmentIndex));
    [_mapView setMapType:(MKMapType)mapMode];
}

- (void)getDirectionsPressed
{
    bool googleMapsInstalled = [TGLocationUtils isGoogleMapsInstalled];
    bool yandexMapsInstalled = [TGLocationUtils isYandexMapsInstalled];
    bool yandexNavigatorInstalled = [TGLocationUtils isYandexNavigatorInstalled];
    bool anyThirdPartyAppInstalled = googleMapsInstalled || yandexNavigatorInstalled;
    
    if (!anyThirdPartyAppInstalled)
    {
        [TGLocationUtils openMapsWithCoordinate:_location.coordinate withDirections:true locationName:_annotation.title];
    }
    else
    {
        NSMutableArray *actions = [[NSMutableArray alloc] init];
        
        [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Map.OpenInMaps") action:@"openInMaps"]];
        
        if (googleMapsInstalled)
            [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Map.OpenInGoogleMaps") action:@"openInGoogleMaps"]];

        if (yandexMapsInstalled)
            [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Map.OpenInYandexMaps") action:@"openInYandexMaps"]];
        
        if (yandexNavigatorInstalled)
            [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Map.OpenInYandexNavigator") action:@"openInYandexNavigator"]];
        
        [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.Cancel") action:@"cancel" type:TGActionSheetActionTypeCancel]];
        
        [[[TGActionSheet alloc] initWithTitle:TGLocalized(@"Map.GetDirections") actions:actions actionBlock:^(TGLocationViewController *controller, NSString *action)
        {
            if ([action isEqualToString:@"openInMaps"])
                [TGLocationUtils openMapsWithCoordinate:controller->_location.coordinate withDirections:true locationName:_annotation.title];
            else if ([action isEqualToString:@"openInGoogleMaps"])
                [TGLocationUtils openGoogleMapsWithCoordinate:controller->_location.coordinate withDirections:true];
            else if ([action isEqualToString:@"openInYandexMaps"])
                [TGLocationUtils openYandexMapsWithCoordinate:controller->_location.coordinate withDirections:true];
            else if ([action isEqualToString:@"openInYandexNavigator"])
                [TGLocationUtils openDirectionsInYandexNavigatorWithCoordinate:controller->_location.coordinate];
        } target:self] showInView:self.view];
    }
}

#pragma mark - Map View Delegate

- (void)mapView:(MKMapView *)__unused mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    userLocation.title = @"";
    
    _locationServicesDisabled = false;
    
    [self updateAnnotation];
    [self updateLocationAvailability];
}

- (void)mapView:(MKMapView *)__unused mapView didFailToLocateUserWithError:(NSError *)__unused error
{
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted)
    {
        _locationServicesDisabled = true;
        [self updateLocationAvailability];
    }
}

- (bool)_hasUserLocation
{
    return (_mapView.userLocation != nil && _mapView.userLocation.location != nil);
}

- (void)updateLocationAvailability
{
    bool locationAvailable = [self _hasUserLocation] || _locationServicesDisabled;
    [_trackingButton setLocationAvailable:locationAvailable animated:true];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if (annotation == mapView.userLocation)
        return nil;
    
    TGLocationPinAnnotationView *view = (TGLocationPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:TGLocationPinAnnotationKind];
    if (view == nil)
        view = [[TGLocationPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:TGLocationPinAnnotationKind];
    else
        view.annotation = annotation;
    
    view.selectable = false;
    view.canShowCallout = false;
    view.animatesDrop = false;
    
    __weak TGLocationViewController *weakSelf = self;
    view.calloutPressed = self.calloutPressed;
    view.getDirectionsPressed = ^
    {
        __strong TGLocationViewController *strongSelf = weakSelf;
        if (strongSelf != nil)
            [strongSelf getDirectionsPressed];
    };

    [view sizeToFit];
    [view setNeedsLayout];
    
    return view;
}

- (void)updateAnnotation
{
    if (_mapView.userLocation == nil || _mapView.userLocation.location == nil)
        return;
    
    CLLocationDistance distanceToLocation =  [_location distanceFromLocation:_mapView.userLocation.location];
    _annotation.subtitle = [NSString stringWithFormat:TGLocalized(@"Map.DistanceAway"), [TGLocationUtils stringFromDistance:distanceToLocation]];
    [self _updateAnnotationView];
    
    [self _updateDirectionsETA];
}

- (void)_updateAnnotationView
{
    TGLocationPinAnnotationView *annotationView = (TGLocationPinAnnotationView *)[_mapView viewForAnnotation:_annotation];
    annotationView.annotation = _annotation;
    [annotationView sizeToFit];
    [annotationView setNeedsLayout];
    
    if (annotationView.appeared)
    {
        [UIView animateWithDuration:0.2f animations:^
        {
            [annotationView layoutIfNeeded];
        }];
    }
}

- (void)_updateDirectionsETA
{
    if (iosMajorVersion() < 7)
        return;
    
    if (_lastDirectionsStartLocation == nil || [_mapView.userLocation.location distanceFromLocation:_lastDirectionsStartLocation] > 100)
    {
        if (_directions != nil)
            [_directions cancel];
        
        MKPlacemark *destinationPlacemark = [[MKPlacemark alloc] initWithCoordinate:_location.coordinate addressDictionary:nil];
        MKMapItem *destinationMapItem = [[MKMapItem alloc] initWithPlacemark:destinationPlacemark];
        
        MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
        request.source = [MKMapItem mapItemForCurrentLocation];
        request.destination = destinationMapItem;
        request.transportType = MKDirectionsTransportTypeAutomobile;
        request.requestsAlternateRoutes = false;
        
        _directions = [[MKDirections alloc] initWithRequest:request];
        [_directions calculateETAWithCompletionHandler:^(MKETAResponse *response, NSError *error)
         {
             if (error != nil)
                 return;
             
             _annotation.userInfo = @{ TGLocationETAKey: @(response.expectedTravelTime) };
             [self _updateAnnotationView];
         }];
        
        _lastDirectionsStartLocation = _mapView.userLocation.location;
    }
}

@end
