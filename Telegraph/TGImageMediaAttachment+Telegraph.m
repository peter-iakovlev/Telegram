#import "TGImageMediaAttachment+Telegraph.h"

#import "TGImageInfo+Telegraph.h"

@implementation TGImageMediaAttachment (Telegraph)

- (id)initWithTelegraphDesc:(TLPhoto *)desc
{
    self = [super init];
    if (self != nil)
    {
        self.type = TGImageMediaAttachmentType;
        
        if ([desc isKindOfClass:[TLPhoto$photo class]])
        {
            TLPhoto$photo *concretePhoto = (TLPhoto$photo *)desc;
            
            self.imageId = concretePhoto.n_id;
            self.accessHash = concretePhoto.access_hash;
            self.date = concretePhoto.date;
            
            self.imageInfo = [[TGImageInfo alloc] initWithTelegraphSizesDescription:concretePhoto.sizes];

            self.hasLocation = false;
            self.hasStickers = concretePhoto.flags & (1 << 0);
        }
        else if ([desc isKindOfClass:[TLPhoto$wallPhoto class]])
        {
            TLPhoto$wallPhoto *concretePhoto = (TLPhoto$wallPhoto *)desc;
            
            self.imageId = concretePhoto.n_id;
            self.date = concretePhoto.date;
            
            self.imageInfo = [[TGImageInfo alloc] initWithTelegraphSizesDescription:concretePhoto.sizes];
            
            if ([concretePhoto.geo isKindOfClass:[TLGeoPoint$geoPoint class]])
            {
                self.hasLocation = true;
                self.locationLatitude = ((TLGeoPoint$geoPoint *)concretePhoto.geo).lat;
                self.locationLongitude = ((TLGeoPoint$geoPoint *)concretePhoto.geo).n_long;
            }
            else
            {
                self.hasLocation = false;
            }
        }
    }
    return self;
}

@end
