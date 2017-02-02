#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#ifdef __cplusplus
extern "C" {
#endif
    
CGSize TGFitSize(CGSize size, CGSize maxSize);
bool TGOrientationIsSideward(UIImageOrientation orientation, bool *mirrored);
    
#ifdef __cplusplus
}
#endif
