#import "TGCacheIndexingItemView.h"

#import <LegacyComponents/LegacyComponents.h>

@interface TGCacheIndexingItemView () {
    UIActivityIndicatorView *_activityIndicator;
    UILabel *_label;
}

@end

@implementation TGCacheIndexingItemView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self.contentView addSubview:_activityIndicator];
        [_activityIndicator startAnimating];
        
        _label = [[UILabel alloc] init];
        _label.backgroundColor = [UIColor clearColor];
        _label.textColor = UIColorRGB(0x6d6b72);
        _label.font = TGSystemFontOfSize(14.0f);
        _label.text = TGLocalized(@"Cache.Indexing");
        _label.numberOfLines = 0;
        _label.lineBreakMode = NSLineBreakByWordWrapping;
        _label.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_label];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _activityIndicator.frame = CGRectMake(CGFloor((self.bounds.size.width - _activityIndicator.frame.size.width) / 2.0f), 18.0f, _activityIndicator.frame.size.width, _activityIndicator.frame.size.height);
    
    CGSize labelSize = [_label.text sizeWithFont:_label.font constrainedToSize:CGSizeMake(self.bounds.size.width - 20.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    labelSize.width = CGCeil(MIN(self.bounds.size.width - 20.0f, labelSize.width));
    labelSize.height = CGCeil(labelSize.height);
    
    _label.frame = CGRectMake(CGFloor((self.bounds.size.width - labelSize.width) / 2.0f), 50.0f, labelSize.width, labelSize.height);
}

@end
