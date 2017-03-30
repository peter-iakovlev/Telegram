//
//  STPSwitchTableViewCell.m
//  Stripe
//
//  Created by Jack Flintermann on 5/6/16.
//  Copyright © 2016 Stripe, Inc. All rights reserved.
//

#import "STPSwitchTableViewCell.h"
#import "STPColorUtils.h"

@interface STPSwitchTableViewCell()

@property(nonatomic, weak)UILabel *captionLabel;
@property(nonatomic, weak)UISwitch *switchView;
@property(nonatomic, weak)id<STPSwitchTableViewCellDelegate> delegate;

@end

@implementation STPSwitchTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UISwitch *switchView = [[UISwitch alloc] init];
		switchView.layer.cornerRadius = CGRectGetHeight(switchView.frame) / 2.0f;
        [self.contentView addSubview:switchView];
        [switchView addTarget:self action:@selector(switchToggled:) forControlEvents:UIControlEventValueChanged];
        _switchView = switchView;
        
        UILabel *captionLabel = [[UILabel alloc] init];
        [self.contentView addSubview:captionLabel];
        _captionLabel = captionLabel;
        _theme = [STPTheme new];
        [self updateAppearance];
    }
    return self;
}

- (void)setTheme:(STPTheme *)theme {
    _theme = theme;
    [self updateAppearance];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat padding = 15;
    self.switchView.center = CGPointMake(self.bounds.size.width - (self.switchView.bounds.size.width / 2) - padding, self.bounds.size.height / 2);
    self.captionLabel.frame = CGRectMake(padding, 0, CGRectGetMinX(self.switchView.frame) - padding, self.bounds.size.height);
}

- (void)switchToggled:(UISwitch *)sender {
    [self.delegate switchTableViewCell:self didToggleSwitch:sender.on];
}

- (void)updateAppearance {
    UIColor *thumbTintColor = [STPColorUtils brighterColor:self.theme.primaryForegroundColor
                                                    color2:self.theme.secondaryBackgroundColor];
    // Thumb tint color changes the shadow's tint as well, so we only want to set it when the switch is off-white anyway.
    if (![thumbTintColor isEqual:[UIColor whiteColor]]) {
        self.switchView.thumbTintColor = thumbTintColor;
    }
    self.backgroundColor = [UIColor clearColor];
	self.switchView.tintColor = self.theme.tertiaryBackgroundColor;
	self.switchView.backgroundColor = self.theme.tertiaryBackgroundColor;
    self.switchView.onTintColor = self.theme.accentColor;
    self.captionLabel.font = self.theme.font;
    self.contentView.backgroundColor = self.theme.secondaryBackgroundColor;
	self.captionLabel.textColor = self.theme.primaryForegroundColor;
}

- (void)configureWithLabel:(NSString *)label
                  delegate:(id<STPSwitchTableViewCellDelegate>)delegate {
    self.captionLabel.text = label;
    self.switchView.accessibilityLabel = label;
    self.delegate = delegate;
}

- (void)setSelected:(__unused BOOL)selected animated:(__unused BOOL)animated {
}

- (BOOL)on {
    return self.switchView.on;
}


- (void)setOn:(BOOL)on {
    self.switchView.on = on;
}
@end
