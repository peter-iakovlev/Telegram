#import "TGSwitchItemCell.h"

#import "TGImageUtils.h"

#import "TGSwitchView.h"

@interface TGSwitchItemCell () <TGSwitchViewDelegate>

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) TGSwitchView *switchView;

@end

@implementation TGSwitchItemCell

@synthesize watcherHandle = _watcherHandle;
@synthesize itemId = _itemId;

@synthesize title = _title;
@synthesize isOn = _isOn;

@synthesize titleLabel = _titleLabel;
@synthesize switchView = _switchView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {   
        _switchView = [[TGSwitchView alloc] init];
        _switchView.delegate = self;
        _switchView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        _switchView.frame = CGRectOffset(_switchView.frame, self.contentView.frame.size.width - _switchView.frame.size.width - 9, 8);
        [self.contentView addSubview:_switchView];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(11, 12, self.contentView.frame.size.width - 28 - _switchView.frame.size.width, 20)];
        _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _titleLabel.font = [UIFont boldSystemFontOfSize:17];
        _titleLabel.backgroundColor = [UIColor whiteColor];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.highlightedTextColor = [UIColor whiteColor];
        [self.contentView addSubview:_titleLabel];
        
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognized:)]];
    }
    return self;
}

- (void)setGroupedCellPosition:(int)groupedCellPosition
{
    [super setGroupedCellPosition:groupedCellPosition];
    
    _switchView.frame = CGRectMake(self.contentView.frame.size.width - _switchView.frame.size.width - 9, (groupedCellPosition & (TGGroupedCellPositionFirst | TGGroupedCellPositionLast)) ? 7.5f : 8.0f, _switchView.frame.size.width, _switchView.frame.size.height);
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    
    _titleLabel.text = title;
}

- (void)setCustomBackgroundColor:(UIColor *)color
{
    _titleLabel.backgroundColor = color;
}

- (void)setIsOn:(bool)isOn
{
    [self setIsOn:isOn animated:false];
}

- (void)setIsOn:(bool)isOn animated:(bool)animated
{
    _isOn = isOn;
    
    [_switchView setOn:isOn animated:animated];
}

- (void)switchView:(TGSwitchView *)__unused switchView didChangeIsOn:(bool)__unused isOn
{
    [self fireChangeEvent];
}

- (void)fireChangeEvent
{
    id<ASWatcher> watcher = _watcherHandle.delegate;
    if (_itemId != nil && watcher != nil && [watcher respondsToSelector:@selector(actionStageActionRequested:options:)])
    {
        [watcher actionStageActionRequested:@"toggleSwitchItem" options:[[NSDictionary alloc] initWithObjectsAndKeys:_itemId, @"itemId", [NSNumber numberWithBool:_switchView.isOn], @"value", nil]];
    }
}

- (void)tapGestureRecognized:(UITapGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateRecognized)
    {
        [_switchView setOn:!_switchView.isOn animated:true notifyOnCompletion:true];
    }
}

@end
