#import "TGLoginResetAccountControllerView.h"

#import "TGImageUtils.h"
#import "TGFont.h"
#import "TGViewController.h"

#import "TGModernButton.h"

#import "TGStringUtils.h"

#import "TGTimerTarget.h"

@interface TGLoginResetAccountControllerView () {
    UIView *_grayBackground;
    UIView *_grayBackgroundSeparator;
    UILabel *_titleLabel;
    
    UILabel *_textLabel;
    UILabel *_counterTitleLabel;
    UILabel *_counterLabel;
    
    TGModernButton *_resetButton;
    
    NSTimeInterval _protectedUntilDate;
    int32_t _timerSeconds;
    
    NSTimer *_timer;
}

@end

@implementation TGLoginResetAccountControllerView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        self.backgroundColor = [UIColor whiteColor];
        
        _grayBackground = [[UIView alloc] init];
        _grayBackground.backgroundColor = UIColorRGB(0xf2f2f2);
        [self addSubview:_grayBackground];
        
        _grayBackgroundSeparator = [[UIView alloc] init];
        _grayBackgroundSeparator.backgroundColor = TGSeparatorColor();
        [self addSubview:_grayBackgroundSeparator];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.font = TGIsPad() ? TGUltralightSystemFontOfSize(48.0f) : TGSystemFontOfSize(26.0f);
        _titleLabel.text = TGLocalized(@"Login.ResetAccountProtected.Title");
        [_titleLabel sizeToFit];
        [self addSubview:_titleLabel];
        
        _textLabel = [[UILabel alloc] init];
        _textLabel.backgroundColor = [UIColor clearColor];
        _textLabel.textColor = [UIColor blackColor];
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.numberOfLines = 0;
        _textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self addSubview:_textLabel];
        
        _counterTitleLabel = [[UILabel alloc] init];
        _counterTitleLabel.backgroundColor = [UIColor clearColor];
        _counterTitleLabel.textColor = [UIColor blackColor];
        _counterTitleLabel.font = TGSystemFontOfSize(16.0f);
        _counterTitleLabel.text = TGLocalized(@"Login.ResetAccountProtected.TimerTitle");
        _counterTitleLabel.textAlignment = NSTextAlignmentCenter;
        _counterTitleLabel.numberOfLines = 0;
        _counterTitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self addSubview:_counterTitleLabel];
        
        _counterLabel = [[UILabel alloc] init];
        _counterLabel.backgroundColor = [UIColor clearColor];
        _counterLabel.textColor = [UIColor blackColor];
        [self addSubview:_counterLabel];
        
        _resetButton = [[TGModernButton alloc] init];
        _resetButton.modernHighlight = true;
        [_resetButton addTarget:self action:@selector(resetPressed) forControlEvents:UIControlEventTouchUpInside];
        _resetButton.titleLabel.font = TGSystemFontOfSize(21.0f);
        [_resetButton setTitle:TGLocalized(@"Login.ResetAccountProtected.Reset") forState:UIControlStateNormal];
        [_resetButton sizeToFit];
        _resetButton.extendedEdgeInsets = UIEdgeInsetsMake(10.0f, 20.0f, 10.0f, 20.0f);
        [_resetButton setTitleColor:UIColorRGB(0x999999)];
        _resetButton.userInteractionEnabled = false;
        [self addSubview:_resetButton];
        
        _timerSeconds = -1;
        _timer = [TGTimerTarget scheduledMainThreadTimerWithTarget:self action:@selector(updateTimer) interval:2.0 repeat:true];
    }
    return self;
}

- (void)dealloc {
    [_timer invalidate];
}

- (NSAttributedString *)stringForTimerWithDays:(int)days hours:(int)hours minutes:(int)minutes {
    NSString *daysString = @"";
    if (days > 0) {
        daysString = [[NSString stringWithFormat:TGLocalized([TGStringUtils integerValueFormat:@"MessageTimer.Days_" value:days]), [NSString stringWithFormat:@"%d", days]] stringByAppendingString:@" "];
    }
    
    NSString *hoursString = @"";
    if (hours > 0 || days > 0) {
        hoursString = [[NSString stringWithFormat:TGLocalized([TGStringUtils integerValueFormat:@"MessageTimer.Hours_" value:hours]), [NSString stringWithFormat:@"%d", hours]] stringByAppendingString:@" "];
    }
    
    NSString *minutesString = [NSString stringWithFormat:TGLocalized([TGStringUtils integerValueFormat:@"MessageTimer.Minutes_" value:minutes]), [NSString stringWithFormat:@"%d", minutes]];
    
    NSString *string = [[NSString alloc] initWithFormat:@"%@%@%@", daysString, hoursString, minutesString];
    
    NSMutableString *formattedString = [[NSMutableString alloc] init];
    for (NSUInteger i = 0; i < string.length; i++) {
        unichar previousC = i == 0 ? 0 : [string characterAtIndex:i - 1];
        unichar c = [string characterAtIndex:i];
        if (c >= '0' && c <= '9' && !(previousC >= '0' && previousC <= '9')) {
            unichar ast = '*';
            [formattedString appendString:[NSString stringWithCharacters:&ast length:1]];
            [formattedString appendString:[NSString stringWithCharacters:&ast length:1]];
        } else if (!(c >= '0' && c <= '9') && (previousC >= '0' && previousC <= '9')) {
            unichar ast = '*';
            [formattedString appendString:[NSString stringWithCharacters:&ast length:1]];
            [formattedString appendString:[NSString stringWithCharacters:&ast length:1]];
        }
        
        [formattedString appendString:[NSString stringWithCharacters:&c length:1]];
    }
    
    return [formattedString attributedFormattedStringWithRegularFont:TGSystemFontOfSize(21.0f) boldFont:TGMediumSystemFontOfSize(21.0f) lineSpacing:0.0f paragraphSpacing:0.0f alignment:NSTextAlignmentLeft];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat topOffset = 0.0f;
    CGFloat titleLabelOffset = 0.0f;
    CGFloat noticeLabelOffset = 0.0f;
    CGFloat sideInset = 0.0f;
    CGFloat hintOffset = 0.0f;
    CGFloat helpOffset = 0.0f;
    CGFloat buttonOffset = 0.0f;
    
    CGFloat resetFirstButtonOffset = 0.0f;
    CGFloat resetSecondButtonOffset = 0.0f;
    
    if (TGIsPad())
    {
        if (self.frame.size.width < self.frame.size.height)
        {
            topOffset = 305.0f;
            titleLabelOffset = topOffset - 108.0f;
        }
        else
        {
            topOffset = 135.0f;
            titleLabelOffset = topOffset - 78.0f;
        }
        
        noticeLabelOffset = topOffset + 143.0f;
        sideInset = 130.0f;
        hintOffset = 13.0f;
        helpOffset = 24.0f;
        buttonOffset = 0.0f;
        resetFirstButtonOffset = 24.0f;
        resetSecondButtonOffset = 6.0f;
    }
    else
    {
        topOffset = [TGViewController isWidescreen] ? 131.0f : 90.0f;
        titleLabelOffset = ([TGViewController isWidescreen] ? 66.0f : 48.0f) + 9.0f;
        noticeLabelOffset = [TGViewController isWidescreen] ? 274.0f : 214.0f;
        hintOffset = [TGViewController isWidescreen] ? 13.0f : 13.0f;
        helpOffset = [TGViewController isWidescreen] ? 24.0f : 24.0f;
        buttonOffset = [TGViewController isWidescreen] ? 0.0f : 0.0f;
        sideInset = 32.0f;
        resetFirstButtonOffset = 24.0f;
        resetSecondButtonOffset = 6.0f;
    }
    
    _grayBackground.frame = CGRectMake(0.0f, 0.0f, self.frame.size.width, topOffset);
    _grayBackgroundSeparator.frame = CGRectMake(0.0f, topOffset, self.frame.size.width, TGScreenPixel);
    
    _titleLabel.frame = CGRectMake(CGFloor((self.frame.size.width - _titleLabel.frame.size.width) / 2), titleLabelOffset, _titleLabel.frame.size.width, _titleLabel.frame.size.height);
    
    CGFloat contentAreaHeight = self.bounds.size.height - topOffset;
    CGFloat maxTextCounterSpacing = 94.0f;
    
    CGSize textSize = [_textLabel.attributedText boundingRectWithSize:CGSizeMake(self.bounds.size.width - 40.0f, 1000.0f) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    textSize.width = CGCeil(textSize.width);
    textSize.height = CGCeil(textSize.height);
    CGFloat textOrigin = topOffset + CGFloor(((contentAreaHeight / 2.0f) - textSize.height) / 2.0f);
    
    CGSize counterTitleSize = [_counterTitleLabel.text sizeWithFont:_counterTitleLabel.font constrainedToSize:CGSizeMake(self.bounds.size.width - 40.0f, 1000.0f) lineBreakMode:NSLineBreakByWordWrapping];
    [_counterLabel sizeToFit];
    CGSize counterSize = _counterLabel.bounds.size;
    CGFloat counterTitleSpacing = 15.0f;
    CGFloat counterButtonSpacing = 9.0f;
    
    CGSize resetButtonSize = _resetButton.bounds.size;
    
    CGFloat counterAreaHeight = counterTitleSize.height + counterTitleSpacing + counterSize.height + counterButtonSpacing + resetButtonSize.height;
    
    CGFloat counterAreaOrigin = topOffset + CGFloor(((contentAreaHeight * 0.75f) - counterAreaHeight / 2.0f));
    
    CGFloat textCounterSpacing = counterAreaOrigin - (textOrigin + textSize.height);
    if (textCounterSpacing > maxTextCounterSpacing) {
        textOrigin -= (maxTextCounterSpacing - textCounterSpacing) / 2.0f;
        counterAreaOrigin += (maxTextCounterSpacing - textCounterSpacing) / 2.0f;
    }
    
    textOrigin = CGFloor(textOrigin);
    counterAreaOrigin = CGFloor(counterAreaOrigin);
    
    _textLabel.frame = CGRectMake(CGFloor((self.bounds.size.width - textSize.width) / 2.0f), textOrigin, textSize.width, textSize.height);
    
    _counterTitleLabel.frame = CGRectMake(CGFloor((self.bounds.size.width - counterTitleSize.width) / 2.0f), counterAreaOrigin, counterTitleSize.width, counterTitleSize.height);
    _counterLabel.frame = CGRectMake(CGFloor((self.bounds.size.width - counterSize.width) / 2.0f), CGRectGetMaxY(_counterTitleLabel.frame) + counterTitleSpacing, counterSize.width, counterSize.height);
    _resetButton.frame = CGRectMake(CGFloor((self.bounds.size.width - resetButtonSize.width) / 2.0f), CGRectGetMaxY(_counterLabel.frame) + counterButtonSpacing, resetButtonSize.width, resetButtonSize.height);
}

- (void)setPhoneNumber:(NSString *)phoneNumber {
    _textLabel.attributedText = [[NSString stringWithFormat:TGLocalized(@"Login.ResetAccountProtected.Text"), [NSString stringWithFormat:@"**%@**", phoneNumber]] attributedFormattedStringWithRegularFont:TGSystemFontOfSize(16.0f) boldFont:TGMediumSystemFontOfSize(16.0f) lineSpacing:1.0f paragraphSpacing:0.0f alignment:NSTextAlignmentCenter];
    [self setNeedsLayout];
}

- (void)setProtectedUntilDate:(NSTimeInterval)protectedUntilDate {
    _protectedUntilDate = protectedUntilDate;
    [self updateTimer];
}

- (void)updateTimer {
    int32_t timerSeconds = MAX(0, (int32_t)(_protectedUntilDate - CFAbsoluteTimeGetCurrent()));
    if (timerSeconds != _timerSeconds) {
        _timerSeconds = timerSeconds;
        
        int32_t secondsInAMinute = 60;
        int32_t secondsInAnHour = 60 * secondsInAMinute;
        int32_t secondsInADay = 24 * secondsInAnHour;
        
        int32_t days = timerSeconds / secondsInADay;
        
        int32_t hourSeconds = timerSeconds % secondsInADay;
        int32_t hours = hourSeconds / secondsInAnHour;
        
        int32_t minuteSeconds = hourSeconds % secondsInAnHour;
        int32_t minutes = minuteSeconds / secondsInAMinute;
        
        if (days == 0 && hours == 0 && minutes == 0 && timerSeconds > 0) {
            minutes = 1;
        }
        
        _counterLabel.attributedText = [self stringForTimerWithDays:days hours:hours minutes:minutes];
        [self setNeedsLayout];
        
        if (timerSeconds == 0) {
            [_resetButton setTitleColor:TGAccentColor()];
            _resetButton.userInteractionEnabled = true;
        } else {
            [_resetButton setTitleColor:UIColorRGB(0x999999)];
            _resetButton.userInteractionEnabled = false;
        }
    }
}

- (void)resetPressed {
    if (_resetAccount) {
        _resetAccount();
    }
}

@end
