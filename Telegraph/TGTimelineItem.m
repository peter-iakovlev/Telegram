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
            
            _hasLocation = false;
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
