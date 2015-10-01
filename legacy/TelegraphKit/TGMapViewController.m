#import "TGMapViewController.h"

#import <MapKit/MapKit.h>

#import "TGMapView.h"

#import "TGImageUtils.h"

#import "TGLocationAnnotation.h"

#import "TGMapAnnotationView.h"
#import "TGCalloutView.h"

#import "TGContactMediaAttachment.h"

#import "TGLocationMapModeControl.h"

#import "TGBackdropView.h"

#import "TGFont.h"

#import "TGActionSheet.h"

#import "TGAlertView.h"

typedef enum {
    TGMapViewControllerModePick = 0,
    TGMapViewControllerModeMap = 1
} TGMapViewControllerMode;

static CLLocation *lastUserLocation = nil;

static int selectedMapMode = 0;
static bool selectedMapModeInitialized = false;

@protocol TGApplicationWithCustomURLHandling <NSObject>

- (BOOL)openURL:(NSURL *)url forceNative:(BOOL)forceNative;

@end

static int defaultMapMode()
{
    if (!selectedMapModeInitialized)
    {
        selectedMapModeInitialized = true;
        
        selectedMapMode = [[[NSUserDefaults standardUserDefaults] objectForKey:@"TGMapViewController.defaultMapMode"] intValue];
    }
    
    return selectedMapMode;
}

static void setDefaultMapMode(int mode)
{
    selectedMapModeInitialized = true;
    selectedMapMode = mode;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[[NSNumber alloc] initWithInt:mode] forKey:@"TGMapViewController.defaultMapMode"];
    [userDefaults synchronize];
}

#pragma mark -

@interface TGMapViewController () <MKMapViewDelegate>
{
    CLLocationManager *_locationManager;
}

@property (nonatomic) TGMapViewControllerMode mode;

@property (nonatomic) bool locationServicesDisabled;

@property (nonatomic, strong) TGUser *user;

@property (nonatomic, strong) TGMapView *mapView;
@property (nonatomic) bool modifiedPinLocation;
@property (nonatomic) bool modifiedRegion;

@property (nonatomic, strong) TGLocationAnnotation *highlightedLocationAnnotation;
@property (nonatomic, strong) CLLocation *mapLocation;

@property (nonatomic, strong) UIButton *locationButton;

@property (nonatomic, strong) UIView *locationIconsContainer;
@property (nonatomic, strong) UIActivityIndicatorView *locationActivityIndicator;
@property (nonatomic, strong) UIImageView *locationNormalIcon;
@property (nonatomic, strong) UIImageView *locationActiveIcon;
@property (nonatomic, strong) UIImageView *locationActiveHeadingIcon;

@property (nonatomic, strong) UISegmentedControl *segmentedControl;

@property (nonatomic) bool mapViewFinished;

@end

@implementation TGMapViewController
{
    TGLocationMapModeControl *_mapModeControl;
}

- (id)initInPickingMode
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:true];
        
        _mode = TGMapViewControllerModePick;
        
        _locationManager = [[CLLocationManager alloc] init];
        if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
            [_locationManager requestWhenInUseAuthorization];
    }
    return self;
}

- (id)initInMapModeWithLatitude:(double)latitude longitude:(double)longitude user:(TGUser *)user
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:true];
        
        _mode = TGMapViewControllerModeMap;
        
        _locationManager = [[CLLocationManager alloc] init];
        if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
            [_locationManager requestWhenInUseAuthorization];
        
        _user = user;
        _mapLocation = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
        _highlightedLocationAnnotation = [[TGLocationAnnotation alloc] initWithCoordinate:CLLocationCoordinate2DMake(latitude, longitude) title:nil];
    }
    return self;
}

- (void)dealloc
{
    [_actionHandle reset];
    [ActionStageInstance() removeWatcher:self];
    
    [self doUnloadView];
}

- (void)loadView
{
    [super loadView];
    
    _mapView = [[TGMapView alloc] initWithFrame:self.view.bounds];
    _mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _mapView.zoomEnabled = true;
    _mapView.scrollEnabled = true;
    _mapView.delegate = self;
    _mapView.userInteractionEnabled = true;
    
    _mapView.showsUserLocation = true;
    
    _mapView.mapType = defaultMapMode();

    if (iosMajorVersion() >= 6)
    {
        for (UIView *subview in _mapView.subviews)
        {
            if ([subview isKindOfClass:[UILabel class]])
            {
                subview.autoresizingMask = 0;
                CGRect frame = subview.frame;
                frame.origin.y = 5;
                frame.origin.x = 5;
                subview.frame = frame;
                
                break;
            }
        }
    }
    
    if (_mode == TGMapViewControllerModePick)
    {
        self.titleText = TGLocalized(@"Map.ChooseLocationTitle");
        
        [self setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonPressed)]];
        [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Map.Send") style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonPressed)]];
        
        self.navigationItem.rightBarButtonItem.enabled = false;
        
        UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(mapLongPressed:)];
        [_mapView addGestureRecognizer:longPressRecognizer];
        
        if (lastUserLocation != nil)
        {
            MKCoordinateRegion mapRegion;
            mapRegion.center = lastUserLocation.coordinate;
            mapRegion.span.latitudeDelta = 0.008;
            mapRegion.span.longitudeDelta = 0.008;
            
            @try
            {
                [_mapView setRegion:mapRegion animated:false];
            }
            @catch (NSException *exception) { TGLog(@"%@", exception); }
        }
    }
    else if (_mode == TGMapViewControllerModeMap)
    {   
        self.titleText = TGLocalized(@"Map.MapTitle");
        
        if (TGIsPad())
        {
            [self setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Done") style:UIBarButtonItemStyleDone target:self action:@selector(dismissButtonPressed)]];
        }
        
        if (iosMajorVersion() >= 7)
        {
            [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionsButtonPressed)]];
        }
        else
        {
            [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.More") style:UIBarButtonItemStylePlain target:self action:@selector(actionsButtonPressed)]];
        }
        
        MKCoordinateRegion mapRegion;
        mapRegion.center = _highlightedLocationAnnotation.coordinate;
        mapRegion.span.latitudeDelta = 0.008;
        mapRegion.span.longitudeDelta = 0.008;
        
        @try
        {
            [_mapView setRegion:mapRegion animated:false];
        }
        @catch (NSException *exception)
        {
            TGLog(@"%@", exception);
        }
        
        [_mapView addAnnotation:_highlightedLocationAnnotation];
        [_mapView selectAnnotation:_highlightedLocationAnnotation animated:false];
    }
    
    [self.view addSubview:_mapView];
    
    float retinaPixel = TGIsRetina() ? 0.5f : 0.0f;
    
    UIView *_backgroundView;
    
    if (TGBackdropEnabled())
    {
        _backgroundView = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, self.view.frame.size.height - 44.0f, self.view.frame.size.width, 44.0f)];
        [self.view addSubview:_backgroundView];
    }
    else
    {
        _backgroundView = [TGBackdropView viewWithLightNavigationBarStyle];
        _backgroundView.frame = CGRectMake(0.0f, self.view.frame.size.height - 44.0f, self.view.frame.size.width, 44.0f);
        [self.view addSubview:_backgroundView];
        
        UIView *_stripeView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, _backgroundView.frame.size.width, TGIsRetina() ? 0.5f : 1.0f)];
        _stripeView.backgroundColor = UIColorRGB(0xb2b2b2);
        [_backgroundView addSubview:_stripeView];
    }
    
    _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
    _locationButton = [[UIButton alloc] initWithFrame:CGRectMake(6, self.view.frame.size.height - 44.0f, 44, 44.0f)];
    [_locationButton addTarget:self action:@selector(locationButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    _locationButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:_locationButton];
    
    CGPoint iconOffset = {1.0f, 6.0f};
    
    _locationIconsContainer = [[UIView alloc] initWithFrame:_locationButton.bounds];
    _locationIconsContainer.userInteractionEnabled = false;
    [_locationButton addSubview:_locationIconsContainer];
    
    _locationNormalIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MapLocationIcon.png"]];
    _locationNormalIcon.frame = CGRectOffset(_locationNormalIcon.frame, 9 + iconOffset.x, 7 + iconOffset.y);
    [_locationIconsContainer addSubview:_locationNormalIcon];
    
    _locationActiveIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MapLocationIcon_Active.png"]];
    _locationActiveIcon.frame = CGRectOffset(_locationActiveIcon.frame, 9 + iconOffset.x, 7 + iconOffset.y);
    _locationActiveIcon.alpha = 0.0f;
    [_locationIconsContainer addSubview:_locationActiveIcon];
    
    _locationActiveHeadingIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MapLocationIcon_ActiveHeading.png"]];
    _locationActiveHeadingIcon.frame = CGRectOffset(_locationActiveIcon.frame, 1 + iconOffset.x, -6 + iconOffset.y);
    _locationActiveHeadingIcon.alpha = 0.0f;
    [_locationIconsContainer addSubview:_locationActiveHeadingIcon];
    
    _locationActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _locationActivityIndicator.userInteractionEnabled = false;
    _locationActivityIndicator.frame = CGRectOffset(_locationActivityIndicator.frame, CGFloor((_locationButton.frame.size.width - _locationActivityIndicator.frame.size.width) / 2.0f) + retinaPixel, CGFloor((_locationButton.frame.size.height - _locationActivityIndicator.frame.size.height) / 2.0f) + retinaPixel);
    _locationActivityIndicator.alpha = 0.0f;
    _locationActivityIndicator.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
    [_locationButton addSubview:_locationActivityIndicator];
    
    static UIImage *clearImage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(4.0f, 4.0f), false, 0.0f);
        clearImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    });
    
//    _segmentedControl = [[UISegmentedControl alloc] initWithItems:@[TGLocalized(@"Map.Map"), TGLocalized(@"Map.Satellite"), TGLocalized(@"Map.Hybrid")]];
//    _segmentedControl.frame = CGRectMake(_backgroundView.frame.size.width - 240, 0.0f, 240, _backgroundView.frame.size.height);
//    _segmentedControl.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
//    
//    [_segmentedControl setBackgroundImage:clearImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
//    [_segmentedControl setBackgroundImage:clearImage forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
//    [_segmentedControl setBackgroundImage:clearImage forState:UIControlStateSelected | UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
//    [_segmentedControl setBackgroundImage:clearImage forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
//    [_segmentedControl setDividerImage:clearImage forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
//    [_segmentedControl setDividerImage:clearImage forLeftSegmentState:UIControlStateHighlighted rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
//    [_segmentedControl setDividerImage:clearImage forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
//    
//    [_segmentedControl setTitleTextAttributes:@{UITextAttributeTextColor: UIColorRGB(0x666666), UITextAttributeTextShadowColor: [UIColor clearColor], UITextAttributeFont: TGSystemFontOfSize(14)} forState:UIControlStateNormal];
//    [_segmentedControl setTitleTextAttributes:@{UITextAttributeTextColor: TGAccentColor(), UITextAttributeTextShadowColor: [UIColor clearColor], UITextAttributeFont: TGSystemFontOfSize(14)} forState:UIControlStateSelected];
//    
//    [_backgroundView addSubview:_segmentedControl];
//    
//    [_segmentedControl setSelectedSegmentIndex:MIN(2, MAX(0, _mapView.mapType))];
//    [_segmentedControl addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
    
    _mapModeControl = [[TGLocationMapModeControl alloc] init];
    _mapModeControl.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _mapModeControl.frame = CGRectMake(55, (_backgroundView.frame.size.height - 29) / 2 + 0.5f, _backgroundView.frame.size.width - 55 - 7.5f, 29);
    _mapModeControl.selectedSegmentIndex = MAX(0, MIN(2, (NSInteger)_mapView.mapType));
    [_mapModeControl addTarget:self action:@selector(mapModeControlValueChanged:) forControlEvents:UIControlEventValueChanged];
    [_backgroundView addSubview:_mapModeControl];
    
    /*_buttonGroupView = [[TGButtonGroupView alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 219 - 6, self.view.frame.size.height - rawButtonLeft.size.height - 7, 219, rawButtonLeft.size.height) buttonLeftImage:buttonLeft buttonLeftHighlightedImage:buttonLeftHighlighted buttonCenterImage:buttonCenter buttonCenterHighlightedImage:buttonCenterHighlighted buttonRightImage:buttonRight buttonRightHighlightedImage:buttonRightHighlighted buttonSeparatorImage:buttonSeparator buttonSeparatorLeftHighlightedImage:buttonSeparatorLeftHighlighted buttonSeparatorRightHighlightedImage:buttonSeparatorRightHighlighted];
    _buttonGroupView.delegate = self;
    _buttonGroupView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    _buttonGroupView.selectedIndex = MIN(2, MAX(0, _mapView.mapType));
    _buttonGroupView.buttonTopTextInset = 1;
    _buttonGroupView.buttonSideTextInset = 3;
    _buttonGroupView.buttonTextColorHighlighted = UIColorRGB(0x046dd0);
    _buttonGroupView.buttonTextColor = UIColorRGB(0x595959);
    _buttonGroupView.buttonShadowColor = UIColorRGBA(0xffffff, 0.6f);
    _buttonGroupView.buttonShadowOffset = CGSizeMake(0, 1);
    _buttonGroupView.buttonFont = [UIFont boldSystemFontOfSize:12];
    _buttonGroupView.buttonsAreAlwaysDeselected = true;
    [_buttonGroupView addButton:TGLocalized(@"Map.Map")];
    [_buttonGroupView addButton:TGLocalized(@"Map.Satellite")];
    [_buttonGroupView addButton:TGLocalized(@"Map.Hybrid")];
    [self.view addSubview:_buttonGroupView];*/
}

- (void)doUnloadView
{
    _mapView.delegate = nil;
    _mapView = nil;
}

- (void)viewDidUnload
{
    [self doUnloadView];
    
    [super viewDidUnload];
}

- (BOOL)_shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if ([self presentedViewController] != nil)
        return false;
    
    return toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

- (BOOL)shouldAutorotate
{
    return [self _shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationPortrait];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [_mapView setCenterCoordinate:_mapView.region.center animated:NO];
    
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

#pragma mark -

- (void)mapView:(MKMapView *)__unused mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{   
    if (userLocation.coordinate.latitude == 0.0 && userLocation.coordinate.longitude == 0.0)
        return;
    
    _locationServicesDisabled = false;
        
    lastUserLocation = userLocation.location;
    
    if (_mode == TGMapViewControllerModePick)
    {
        if (!_modifiedPinLocation)
        {
            if (!_modifiedRegion)
            {
                _modifiedRegion = true;
                
                MKCoordinateRegion mapRegion;
                mapRegion.center = userLocation.coordinate;
                mapRegion.span.latitudeDelta = 0.008;
                mapRegion.span.longitudeDelta = 0.008;
             
                @try
                {
                    [_mapView setRegion:mapRegion animated:true];
                }
                @catch (NSException *exception) { TGLog(@"%@", exception); }
            }
        
            if (_highlightedLocationAnnotation != nil)
            {
                [_highlightedLocationAnnotation setCoordinate:userLocation.coordinate];
            }
            else
            {
                _highlightedLocationAnnotation = [[TGLocationAnnotation alloc] initWithCoordinate:userLocation.coordinate title:nil];
                [_mapView addAnnotation:_highlightedLocationAnnotation];
            }
        }
    }
    
    if (_locationActivityIndicator.alpha > FLT_EPSILON)
    {
        [_mapView setUserTrackingMode:MKUserTrackingModeFollow animated:true];
        [self updateLocationIcons];
    }
    
    [self updateLocationAvailability];
    
    if (_mode == TGMapViewControllerModeMap)
    {
        //TGDispatchAfter(1.0, dispatch_get_main_queue(), ^{
            [self updateAnnotationView:(TGMapAnnotationView *)[_mapView viewForAnnotation:_highlightedLocationAnnotation]];
        //});
    }
    
    [self updateDoneButton];
}

- (void)mapView:(MKMapView *)__unused mapView annotationView:(MKAnnotationView *)__unused annotationView didChangeDragState:(MKAnnotationViewDragState)__unused newState fromOldState:(MKAnnotationViewDragState)__unused oldState
{
    if (!_modifiedPinLocation)
        _modifiedPinLocation = true;
    
    if (newState == MKAnnotationViewDragStateEnding)
        [self updateDoneButton];
}

- (void)mapView:(MKMapView *)__unused mapView didFailToLocateUserWithError:(NSError *)__unused error
{
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)
    {
        _locationServicesDisabled = true;
        
        [self updateLocationAvailability];
        
        if (_locationServicesDisabled && _mode == TGMapViewControllerModePick)
        {
            TGAlertView *alertView = [[TGAlertView alloc] initWithTitle:nil message:TGLocalized(@"Map.AccessDeniedError") delegate:nil cancelButtonTitle:TGLocalized(@"Common.OK") otherButtonTitles:nil];
            [alertView show];
        }
    }
}

- (void)mapView:(MKMapView *)__unused mapView didAddAnnotationViews:(NSArray *)views
{
    if (_mode != TGMapViewControllerModePick)
        return;
    
    for (MKAnnotationView *annotationView in views)
    {
        if ([annotationView.annotation isKindOfClass:[MKUserLocation class]])
            continue;
        
        MKMapPoint point =  MKMapPointForCoordinate(annotationView.annotation.coordinate);
        if (!MKMapRectContainsPoint(self.mapView.visibleMapRect, point))
            continue;
        
        CGRect endFrame = annotationView.frame;
        
        annotationView.frame = CGRectMake(annotationView.frame.origin.x, annotationView.frame.origin.y - self.view.frame.size.height, annotationView.frame.size.width, annotationView.frame.size.height);
        
        id<MKAnnotation> annotation = annotationView.annotation;
        
        [UIView animateWithDuration:0.5 delay:(0.04 * [views indexOfObject:annotationView]) options:0 animations:^
        {
            annotationView.frame = endFrame;
        } completion:^(BOOL finished)
        {
            if (finished)
            {
                [UIView animateWithDuration:0.05 animations:^
                {
                    annotationView.transform = CGAffineTransformMakeScale(1.0f, 0.8f);
                } completion:^(BOOL finished)
                {
                    [mapView selectAnnotation:annotation animated:true];
                    if (finished)
                    {
                        [UIView animateWithDuration:0.1 animations:^
                        {
                            annotationView.transform = CGAffineTransformIdentity;
                        }];
                    }
                }];
            }
        }];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if (annotation == mapView.userLocation)
    {
        
        return nil;
    }
    
    MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"Pin"];
    if (annotationView == nil)
    {
        if (_mode == TGMapViewControllerModeMap)
        {
            annotationView = [[TGMapAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Pin"];
            ((TGMapAnnotationView *)annotationView).watcherHandle = _actionHandle;
        }
        else
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Pin"];
    }
    annotationView.canShowCallout = false;
    annotationView.animatesDrop = false;
    if (_mode == TGMapViewControllerModePick)
        annotationView.draggable = true;
    else
        [self updateAnnotationView:(TGMapAnnotationView *)annotationView];
    
    return annotationView;
}

- (void)mapView:(MKMapView *)__unused mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    if (_highlightedLocationAnnotation != nil && view.annotation == _highlightedLocationAnnotation)
    {
        if (_mode == TGMapViewControllerModeMap)
        {
            
        }
    }
}

- (void)mapView:(MKMapView *)__unused mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
    if (_highlightedLocationAnnotation != nil && view.annotation == _highlightedLocationAnnotation)
    {
        if (_mode == TGMapViewControllerModeMap)
        {
            
        }
    }
}

#pragma mark -

- (void)updateAnnotationView:(TGMapAnnotationView *)annotationView
{
    [annotationView.calloutView setTitleText:_user.displayName];
    
    if (_mapView.userLocation != nil && _mapView.userLocation.location != nil)
    {
        static bool metricUnits = true;
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
        {
            NSLocale *locale = [NSLocale currentLocale];
            metricUnits = [[locale objectForKey:NSLocaleUsesMetricSystem] boolValue];
        });
        
        NSString *distanceString = nil;
        
        double distance = [_mapLocation distanceFromLocation:_mapView.userLocation.location];
        
        if (metricUnits)
        {
            if (distance >= 1000 * 1000)
                distanceString = [[NSString alloc] initWithFormat:@"%.1fK km away", distance / (1000.0 * 1000.0)];
            else if (distance > 1000)
                distanceString = [[NSString alloc] initWithFormat:@"%.1f km away", distance / 1000.0];
            else
                distanceString = [[NSString alloc] initWithFormat:@"%d m away", (int)distance];
        }
        else
        {
            double feetDistance = distance / 0.3048;
            
            if (feetDistance >= 5280)
            {
                char buf[32];
                snprintf(buf, 32, "%.1f", feetDistance / 5280.0);
                bool dot = false;
                for (int i = 0; i < 32; i++)
                {
                    char c = buf[i];
                    if (c == '\0')
                        break;
                    else if (c < '0' || c > '9')
                    {
                        dot = true;
                        break;
                    }
                }
                distanceString = [[NSString alloc] initWithFormat:@"%s mile%s away", buf, dot || feetDistance / 5280.0 > 1.0 ? "s" : ""];
            }
            else
            {
                distanceString = [[NSString alloc] initWithFormat:@"%d %s away", (int)feetDistance, (int)feetDistance != 1 ? "feet" : "foot"];
            }
        }
        
        [annotationView.calloutView setSubtitleText:distanceString];
    }
    else
        [annotationView.calloutView setSubtitleText:nil];
    
    [annotationView.calloutView sizeToFit];
    [annotationView setNeedsLayout];
    if (annotationView.calloutView.frame.origin.y < 0)
    {
        [UIView animateWithDuration:0.2 animations:^
        {
            [annotationView layoutIfNeeded];
        }];
    }
}

- (void)mapView:(MKMapView *)__unused mapView regionDidChangeAnimated:(BOOL)__unused animated
{
    //TGLog(@"region change");
}

- (void)mapView:(MKMapView *)__unused mapView didChangeUserTrackingMode:(MKUserTrackingMode)__unused mode animated:(BOOL)__unused animated
{
    [self updateLocationIcons];
}

- (void)updateDoneButton
{
    if (_mode == TGMapViewControllerModePick)
    {
        self.navigationItem.rightBarButtonItem.enabled = ABS(_highlightedLocationAnnotation.coordinate.latitude) > DBL_EPSILON || ABS(_highlightedLocationAnnotation.coordinate.longitude) > DBL_EPSILON;
    }
}

- (void)mapViewWillStartLoadingMap:(MKMapView *)__unused mapView
{
    _mapViewFinished = false;
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)__unused mapView
{
    _mapViewFinished = true;
}

#pragma mark - Actions

- (void)mapLongPressed:(UILongPressGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        _modifiedPinLocation = true;

        if (_highlightedLocationAnnotation != nil)
        {
            [_mapView removeAnnotation:_highlightedLocationAnnotation];
            _highlightedLocationAnnotation = nil;
        }
        
        CGPoint touchPoint = [recognizer locationInView:_mapView];
        CLLocationCoordinate2D touchMapCoordinate = [_mapView convertPoint:touchPoint toCoordinateFromView:_mapView];
        _highlightedLocationAnnotation = [[TGLocationAnnotation alloc] initWithCoordinate:touchMapCoordinate title:nil];
        [_mapView addAnnotation:_highlightedLocationAnnotation];
        
        [self updateDoneButton];
    }
}

- (void)dismissButtonPressed
{
    [self.presentingViewController dismissViewControllerAnimated:true completion:nil];
}

- (void)cancelButtonPressed
{
    id<ASWatcher> watcherDelegate = _watcher == nil ? nil : _watcher.delegate;
    if (watcherDelegate != nil && [watcherDelegate respondsToSelector:@selector(actionStageActionRequested:options:)])
    {
        [watcherDelegate actionStageActionRequested:@"mapViewFinished" options:nil];
    }
}

- (void)doneButtonPressed
{
    id<ASWatcher> watcherDelegate = _watcher == nil ? nil : _watcher.delegate;
    if (watcherDelegate != nil && [watcherDelegate respondsToSelector:@selector(actionStageActionRequested:options:)])
    {
        NSMutableDictionary *options = [[NSMutableDictionary alloc] init];
        if (_highlightedLocationAnnotation != nil && (_highlightedLocationAnnotation.coordinate.latitude != 0.0 || _highlightedLocationAnnotation.coordinate.longitude != 0.0))
        {
            [options setObject:[NSNumber numberWithDouble:_highlightedLocationAnnotation.coordinate.latitude] forKey:@"latitude"];
            [options setObject:[NSNumber numberWithDouble:_highlightedLocationAnnotation.coordinate.longitude] forKey:@"longitude"];
        }
        else if (_mapView.userLocation != nil && (_mapView.userLocation.coordinate.latitude != 0.0 || _mapView.userLocation.coordinate.longitude != 0.0))
        {
            [options setObject:[NSNumber numberWithDouble:_mapView.userLocation.coordinate.latitude] forKey:@"latitude"];
            [options setObject:[NSNumber numberWithDouble:_mapView.userLocation.coordinate.longitude] forKey:@"longitude"];
        }
        
        if (_mapViewFinished)
        {
            
        }
        
        [watcherDelegate actionStageActionRequested:@"mapViewFinished" options:options];
    }
}

- (void)locationButtonPressed
{
    if (_mapView.userLocation != nil && _mapView.userLocation.location != nil)
    {
        if (_mapView.userTrackingMode == MKUserTrackingModeNone)
        {
            [_mapView setUserTrackingMode:MKUserTrackingModeFollow animated:true];
            [self updateLocationIcons];
        }
        else if (_mapView.userTrackingMode == MKUserTrackingModeFollow)
        {
            [_mapView setUserTrackingMode:MKUserTrackingModeFollowWithHeading animated:true];
            [self updateLocationIcons];
        }
        else
        {
            [_mapView setUserTrackingMode:MKUserTrackingModeNone animated:true];
            [self updateLocationIcons];
        }
    }
    else
    {
        if (_locationServicesDisabled)
        {
            TGAlertView *alertView = [[TGAlertView alloc] initWithTitle:nil message:TGLocalized(@"Map.AccessDeniedError") delegate:nil cancelButtonTitle:TGLocalized(@"Common.OK") otherButtonTitles:nil];
            [alertView show];
        }
        [self updateLocationAvailability];
    }
}

- (void)mapModeControlValueChanged:(TGLocationMapModeControl *)sender
{
    NSInteger mapMode = MAX(0, MIN(2, sender.selectedSegmentIndex));
    setDefaultMapMode((int)mapMode);
    [_mapView setMapType:(MKMapType)mapMode];
}

//- (void)segmentedControlChangedValue:(UISegmentedControl *)control
//{
//    int mapMode = control.selectedSegmentIndex < 0 || control.selectedSegmentIndex > 2 ? 0 : control.selectedSegmentIndex;
//    setDefaultMapMode(mapMode);
//    [_mapView setMapType:(MKMapType)mapMode];
//}

/*- (void)buttonGroupViewButtonPressed:(TGButtonGroupView *)__unused buttonGroupView index:(int)index
{
    int mapMode = index < 0 || index > 2 ? 0 : index;
    setDefaultMapMode(mapMode);
    [_mapView setMapType:(MKMapType)mapMode];
}*/

- (void)actionsButtonPressed
{
    NSMutableArray *actions = [[NSMutableArray alloc] init];
    [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Map.GetDirections") action:@"getDirections"]];
    
    if (_message != nil)
        [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Map.ForwardViaTelegram") action:@"forward"]];
    
    if (iosMajorVersion() >= 6 && [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]])
        [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Map.OpenInGoogleMaps") action:@"googleMaps"]];
    
    [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.Cancel") action:@"cancel" type:TGActionSheetActionTypeCancel]];
    
    [[[TGActionSheet alloc] initWithTitle:nil actions:actions actionBlock:^(TGMapViewController *controller, NSString *action)
    {
        if ([action isEqualToString:@"getDirections"])
            [controller _doGetDirections];
        else if ([action isEqualToString:@"forward"])
            [controller _doForward];
        else if ([action isEqualToString:@"googleMaps"])
            [controller _doOpenInGoogleMaps];
    } target:self] showInView:self.view];
}

- (void)_doGetDirections
{
    CLLocation *userLocation = _mapView.userLocation.location;
    NSURL *addressUrl = [[NSURL alloc] initWithString:[[NSString alloc] initWithFormat:@"https://maps.%@.com/?daddr=%f,%f%@", iosMajorVersion() < 6 ? @"google" : @"apple", _mapLocation.coordinate.latitude, _mapLocation.coordinate.longitude, userLocation == nil ? @"" : [[NSString alloc] initWithFormat:@"&saddr=%f,%f", userLocation.coordinate.latitude, userLocation.coordinate.longitude]]];
    
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(openURL:forceNative:)])
        [(id<TGApplicationWithCustomURLHandling>)[UIApplication sharedApplication] openURL:addressUrl forceNative:true];
    else
        [[UIApplication sharedApplication] openURL:addressUrl];
}

- (void)_doForward
{
    if (_message != nil)
    {
        [_watcher requestAction:@"mapViewForward" options:@{
            @"controller": self,
            @"message": _message
        }];
    }
}

- (void)_doOpenInGoogleMaps
{
    CLLocationCoordinate2D centerLocation = _mapView.centerCoordinate;
    NSURL *addressUrl = [[NSURL alloc] initWithString:[[NSString alloc] initWithFormat:@"comgooglemaps-x-callback://?center=%f,%f&q=%f,%f&x-success=telegram://?resume=true&&x-source=Telegram", centerLocation.latitude, centerLocation.longitude, centerLocation.latitude, centerLocation.longitude]];
    
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(openURL:forceNative:)])
        [(id<TGApplicationWithCustomURLHandling>)[UIApplication sharedApplication] openURL:addressUrl forceNative:true];
    else
        [[UIApplication sharedApplication] openURL:addressUrl];
}

#pragma mark -

- (void)updateLocationIcons
{
    bool tracking = _mapView.userTrackingMode != MKUserTrackingModeNone;
    bool trackingHeading = _mapView.userTrackingMode == MKUserTrackingModeFollowWithHeading;
    
    float locationNormalAlpha = tracking ? 0.0f : 1.0f;
    float locationActiveAlpha = tracking && !trackingHeading ? 1.0f : 0.0f;
    float locationActiveHeadingAlpha = tracking && trackingHeading ? 1.0f : 0.0f;
    
    bool animateTransition = (locationActiveHeadingAlpha < FLT_EPSILON) != (_locationActiveHeadingIcon.alpha < FLT_EPSILON);
    
    if (!animateTransition)
    {
        _locationNormalIcon.alpha = locationNormalAlpha;
        _locationActiveIcon.alpha = locationActiveAlpha;
        _locationActiveHeadingIcon.alpha = locationActiveHeadingAlpha;
        
        if (locationActiveHeadingAlpha < FLT_EPSILON)
        {
            _locationNormalIcon.transform = CGAffineTransformIdentity;
            _locationActiveIcon.transform = CGAffineTransformIdentity;
            _locationActiveHeadingIcon.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
        }
        else
        {
            _locationNormalIcon.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
            _locationActiveIcon.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
            _locationActiveHeadingIcon.transform = CGAffineTransformIdentity;
        }
    }
    else
    {
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^
        {
            _locationNormalIcon.alpha = locationNormalAlpha;
            _locationActiveIcon.alpha = locationActiveAlpha;
            _locationActiveHeadingIcon.alpha = locationActiveHeadingAlpha;
            
            if (locationActiveHeadingAlpha < FLT_EPSILON)
            {
                _locationNormalIcon.transform = CGAffineTransformIdentity;
                _locationActiveIcon.transform = CGAffineTransformIdentity;
                _locationActiveHeadingIcon.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
            }
            else
            {
                _locationNormalIcon.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
                _locationActiveIcon.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
                _locationActiveHeadingIcon.transform = CGAffineTransformIdentity;
            }
        } completion:nil];
    }
}

- (void)updateLocationAvailability
{
    bool locationAvailable = (_mapView.userLocation != nil && _mapView.userLocation.location != nil) || _locationServicesDisabled;
    
    if (locationAvailable == _locationActivityIndicator.alpha < FLT_EPSILON)
        return;
    
    if (!locationAvailable)
        [_locationActivityIndicator startAnimating];
    
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^
    {
        _locationIconsContainer.alpha = locationAvailable ? 1.0f : 0.0f;
        _locationActivityIndicator.alpha = locationAvailable ? 0.0f : 1.0f;
        _locationIconsContainer.transform = locationAvailable ? CGAffineTransformIdentity : CGAffineTransformMakeScale(0.1f, 0.1f);
        _locationActivityIndicator.transform = locationAvailable ? CGAffineTransformMakeScale(0.1f, 0.1f) : CGAffineTransformIdentity;
    } completion:^(BOOL finished)
    {
        if (finished)
        {
            if (locationAvailable)
                [_locationActivityIndicator stopAnimating];
        }
    }];
}

#pragma mark -

- (void)actionStageActionRequested:(NSString *)action options:(id)__unused options
{
    if ([action isEqualToString:@"calloutPressed"])
    {
        TGContactMediaAttachment *contactAttachment = [[TGContactMediaAttachment alloc] init];
        contactAttachment.uid = _user.uid;
        [_watcher requestAction:@"openContact" options:[[NSDictionary alloc] initWithObjectsAndKeys:contactAttachment, @"contactAttachment", nil]];
    }
}

@end
