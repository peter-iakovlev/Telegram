#import "TGTimelineItem.h"

#import "TGSchema.h"

#import "TGImageInfo+Telegraph.h"

#import "TGStringUtils.h"

@implementation TGTimelineItem

@synthesize itemId = _itemId;
@synthesize date = _date;
@synthesize imageInfo = _imageInfo;
@synthesize hasLocation = _hasLocation;
@synthesize locationLatitude = _locationLatitude;
@synthesize locationLongitude = _locationLongitude;
@synthesize locationComponents = _locationComponents;

@synthesize cachedLayoutData = _cachedLayoutData;

@synthesize uploading = _uploading;

@synthesize localImageUrl = _localImageUrl;

- (id)initWithDescription:(TLPhoto *)photoDesc
{
    self = [super init];
    if (self != nil)
    {
        _itemId = photoDesc.n_id;
        
        if ([photoDesc isKindOfClass:[TLPhoto$photo class]] || [photoDesc isKindOfClass:[TLPhoto$wallPhoto class]])
        {
            TLPhoto$photo *concretePhoto = (TLPhoto$photo *)photoDesc;
            _date = concretePhoto.date;
            
            _imageInfo = [[TGImageInfo alloc] initWithTelegraphSizesDescription:concretePhoto.sizes];
            
            if ([concretePhoto.geo isKindOfClass:[TLGeoPoint$geoPoint class]])
            {
                _hasLocation = true;
                _locationLatitude = ((TLGeoPoint$geoPoint *)concretePhoto.geo).lat;
                _locationLongitude = ((TLGeoPoint$geoPoint *)concretePhoto.geo).n_long;
            }
            else if ([concretePhoto.geo isKindOfClass:[TLGeoPoint$geoPlace class]])
            {
                _hasLocation = true;
                _locationLatitude = ((TLGeoPoint$geoPlace *)concretePhoto.geo).lat;
                _locationLongitude = ((TLGeoPoint$geoPlace *)concretePhoto.geo).n_long;
                
                TLGeoPlaceName *geoPlaceName = ((TLGeoPoint$geoPlace *)concretePhoto.geo).name;
                if ([geoPlaceName isKindOfClass:[TLGeoPlaceName$geoPlaceName class]])
                {
                    NSMutableDictionary *components = [[NSMutableDictionary alloc] init];
                    if (geoPlaceName.country != nil)
                        [components setObject:[TGStringUtils stringByUnescapingFromHTML:geoPlaceName.country] forKey:@"country"];
                    if (geoPlaceName.state != nil)
                        [components setObject:[TGStringUtils stringByUnescapingFromHTML:geoPlaceName.state] forKey:@"state"];
                    if (geoPlaceName.city != nil)
                        [components setObject:[TGStringUtils stringByUnescapingFromHTML:geoPlaceName.city] forKey:@"city"];
                    if (geoPlaceName.district != nil)
                        [components setObject:[TGStringUtils stringByUnescapingFromHTML:geoPlaceName.district] forKey:@"district"];
                    if (geoPlaceName.street != nil)
                        [components setObject:[TGStringUtils stringByUnescapingFromHTML:geoPlaceName.street] forKey:@"street"];
                    _locationComponents = components;
                }
            }
            else
            {
                _hasLocation = false;
            }
        }
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self != nil)
    {
        _imageInfo = [[TGImageInfo alloc] init];
    }
    return self;
}

@end
