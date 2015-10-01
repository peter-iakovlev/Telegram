#import "TGLoginWelcomeController.h"

#import "TGImageUtils.h"

#import "TGLoginPhoneController.h"

#import "TGHacks.h"
#import "TGFont.h"

#import "TGTelegramNetworking.h"
#import "TGAppDelegate.h"

#import "TGHighlightableButton.h"

#import "TGPagerView.h"

#import "TGModernButton.h"

@interface TGLoginWelcomeController () <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) TGPagerView *pagerView;

@property (nonatomic) int maxPage;

@end

@implementation TGLoginWelcomeController

- (id)init
{
    self = [super initWithNibName:nil bundle:nil];
    if (self != nil)
    {
        self.wantsFullScreenLayout = true;
        
        self.automaticallyManageScrollViewInsets = false;
        self.autoManageStatusBarBackground = false;
        
        self.navigationBarShouldBeHidden = true;
    }
    return self;
}

- (void)dealloc
{
    _scrollView.delegate = nil;
}

- (bool)shouldBeRemovedFromNavigationAfterHiding
{
    return false;
}

- (void)loadView
{
    [super loadView];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    bool isWidescreen = [TGViewController isWidescreen];
    CGSize screenSize = [TGViewController screenSizeForInterfaceOrientation:UIInterfaceOrientationPortrait];
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, screenSize.width, screenSize.height)];
    [self.view addSubview:_scrollView];
    _scrollView.delaysContentTouches = false;
    _scrollView.pagingEnabled = true;
    _scrollView.delegate = self;
    _scrollView.contentSize = CGSizeMake(screenSize.width * 6.0f, screenSize.height);
    _scrollView.showsVerticalScrollIndicator = false;
    _scrollView.showsHorizontalScrollIndicator = false;

    TGModernButton *startButton = [[TGModernButton alloc] init];
    startButton.backgroundColor = [UIColor clearColor];
    [startButton setTitleColor:TGAccentColor()];
    startButton.titleLabel.font = TGSystemFontOfSize(21.0f);
    [startButton setTitle:TGLocalized(@"Tour.StartButton") forState:UIControlStateNormal];
    [startButton setContentEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 20.0f)];
    [startButton sizeToFit];
    CGSize buttonSize = startButton.frame.size;
    startButton.frame = CGRectMake(CGFloor((screenSize.width - buttonSize.width) / 2.0f) + 10.0f, screenSize.height - 20.0f - buttonSize.height - 10.0f, buttonSize.width, buttonSize.height + 20.0f);
    
    UIImageView *arrowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ModernTourButtonRightArrow.png"]];
    CGSize arrowSize = arrowView.frame.size;
    arrowView.frame = CGRectMake(startButton.frame.size.width - arrowSize.width, CGFloor((startButton.frame.size.height - arrowView.frame.size.height) / 2.0f) + 2.0f + TGRetinaPixel, arrowSize.width, arrowSize.height);
    
    [startButton addSubview:arrowView];
    [startButton addTarget:self action:@selector(nextButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:startButton];
    
    _pagerView = [[TGPagerView alloc] initWithDotColors:@[UIColorRGB(0x2ca5e0), UIColorRGB(0xe74c3c), UIColorRGB(0xe74c3c), UIColorRGB(0x2f5a83), UIColorRGB(0x7a8185), UIColorRGB(0x3097f6)]];
    [_pagerView setPagesCount:6];
    _pagerView.frame = CGRectMake(0.0f, isWidescreen ? 487.0f : 400.0f, screenSize.width, 7.0f);
    [self.view addSubview:_pagerView];
    
    NSArray *images = @[
        [UIImage imageNamed:@"Tour.bundle/TourLogo.png"],
        [UIImage imageNamed:@"Tour.bundle/TourIcon1.png"],
        [UIImage imageNamed:@"Tour.bundle/TourIcon5.png"],
        [UIImage imageNamed:@"Tour.bundle/TourIcon2.png"],
        [UIImage imageNamed:@"Tour.bundle/TourIcon3.png"],
        [UIImage imageNamed:@"Tour.bundle/TourIcon4.png"]
    ];
    NSArray *titles = @[
        TGLocalized(@"Tour.Title1"),
        TGLocalized(@"Tour.Title2"),
        TGLocalized(@"Tour.Title6"),
        TGLocalized(@"Tour.Title3"),
        TGLocalized(@"Tour.Title4"),
        TGLocalized(@"Tour.Title5")
    ];
    NSArray *texts = @[
        TGLocalized(@"Tour.Text1"),
        TGLocalized(@"Tour.Text2"),
        TGLocalized(@"Tour.Text6"),
        TGLocalized(@"Tour.Text3"),
        TGLocalized(@"Tour.Text4"),
        TGLocalized(@"Tour.Text5")
    ];
    
    for (int i = 0; i < 6; i++)
    {
        [self addPageAtIndex:i withIcon:images[i] withTitle:titles[i] withText:texts[i]];
    }
    
    [self updateImages];
    
    dispatch_async(dispatch_get_main_queue(), ^
    {
        UITextField *textField = [[UITextField alloc] init];
        [self.view.window addSubview:textField];
        [textField becomeFirstResponder];
        [textField resignFirstResponder];
        [textField removeFromSuperview];
    });
}

- (void)addPageAtIndex:(int)index withIcon:(UIImage *)icon withTitle:(NSString *)title withText:(NSString *)text
{
    bool isWidescreen = [TGViewController isWidescreen];
    CGSize screenSize = [TGViewController screenSizeForInterfaceOrientation:UIInterfaceOrientationPortrait];
    
    UIImageView *iconView = [[UIImageView alloc] initWithImage:icon];
    iconView.frame = CGRectMake(index * screenSize.width + CGFloor((screenSize.width - icon.size.width) / 2.0f), (isWidescreen ? 92 : 74) + CGFloor((140 - icon.size.height) / 2.0f), icon.size.width, icon.size.height);
    [_scrollView addSubview:iconView];
    
#ifdef INTERNAL_RELEASE
    if (index == 0)
    {
        iconView.userInteractionEnabled = true;
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewDoubleTapped:)];
        tapRecognizer.numberOfTapsRequired = 2;
        [iconView addGestureRecognizer:tapRecognizer];
    }
#endif
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.font = TGLightSystemFontOfSize(36.0f);
    titleLabel.text = title;
    [titleLabel sizeToFit];
    titleLabel.frame = CGRectMake(index * screenSize.width + CGFloor((screenSize.width - titleLabel.frame.size.width) / 2.0f), isWidescreen ? 274 : 240, titleLabel.frame.size.width, titleLabel.frame.size.height);
    [_scrollView addSubview:titleLabel];
    
    UILabel *textLabel = [[UILabel alloc] init];
    textLabel.backgroundColor = [UIColor clearColor];
    textLabel.textColor = [UIColor blackColor];
    textLabel.font = TGSystemFontOfSize(17.0f);
    textLabel.textAlignment = NSTextAlignmentCenter;
    textLabel.numberOfLines = 0;
    
    NSMutableArray *boldRanges = [[NSMutableArray alloc] init];
    
    NSMutableString *cleanText = [[NSMutableString alloc] initWithString:text];
    while (true)
    {
        NSRange startRange = [cleanText rangeOfString:@"**"];
        if (startRange.location == NSNotFound)
            break;
        
        [cleanText deleteCharactersInRange:startRange];
        
        NSRange endRange = [cleanText rangeOfString:@"**"];
        if (endRange.location == NSNotFound)
            break;
        
        [cleanText deleteCharactersInRange:endRange];
        
        [boldRanges addObject:[NSValue valueWithRange:NSMakeRange(startRange.location, endRange.location - startRange.location)]];
    }
    
    if ([textLabel respondsToSelector:@selector(setAttributedText:)])
    {
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.lineSpacing = 5;
        style.lineBreakMode = NSLineBreakByWordWrapping;
        style.alignment = NSTextAlignmentCenter;
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:cleanText attributes:@{
            NSFontAttributeName: textLabel.font,
            NSForegroundColorAttributeName: textLabel.textColor
        }];
        
        [attributedString addAttributes:@{NSParagraphStyleAttributeName: style} range:NSMakeRange(0, attributedString.length)];
        
        NSDictionary *boldAttributes = @{NSFontAttributeName: TGMediumSystemFontOfSize(17.0f)};
        for (NSValue *nRange in boldRanges)
        {
            [attributedString addAttributes:boldAttributes range:[nRange rangeValue]];
        }
        
        textLabel.attributedText = attributedString;
    }
    else
        textLabel.text = cleanText;
    
    CGSize textSize = [textLabel sizeThatFits:CGSizeMake(screenSize.width - 20, CGFLOAT_MAX)];
    textLabel.frame = CGRectMake(index * screenSize.width + CGFloor((screenSize.width - textSize.width) / 2), isWidescreen ? 329 : 300, textSize.width, textSize.height);
    [_scrollView addSubview:textLabel];
}

#ifdef INTERNAL_RELEASE
- (void)viewDoubleTapped:(UITapGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateRecognized)
    {
        [self.view removeGestureRecognizer:recognizer];
        
        CGSize screenSize = [TGViewController screenSizeForInterfaceOrientation:UIInterfaceOrientationPortrait];
        
        TGModernButton *startButton = [[TGModernButton alloc] init];
        startButton.backgroundColor = [UIColor clearColor];
        [startButton setTitleColor:TGAccentColor()];
        startButton.titleLabel.font = TGSystemFontOfSize(21.0f);
        [startButton setTitle:TGAppDelegateInstance.useDifferentBackend ? @"Switch to debug DC" : @"Switch to production DC" forState:UIControlStateNormal];
        [startButton sizeToFit];
        startButton.frame = CGRectMake(CGFloor((screenSize.width - startButton.frame.size.width) / 2.0f) - 20.0f, screenSize.height - 20.0f - startButton.frame.size.height - 10.0f - 40, startButton.frame.size.width + 40.0f, startButton.frame.size.height + 20.0f);
        [startButton addTarget:self action:@selector(switchButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:startButton];
        
    }
}

- (void)switchButtonPressed
{
    [[TGTelegramNetworking instance] switchBackends];
}
#endif

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

- (BOOL)shouldAutorotate
{
    return true;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

#pragma mark -

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == _scrollView)
    {
        [self updateImages];
    }
}

#pragma mark -

- (void)nextButtonPressed
{
    TGLoginPhoneController *phoneController = [[TGLoginPhoneController alloc] init];
    [self.navigationController pushViewController:phoneController animated:true];
}

- (void)updateImages
{
    int lastIndex = 6;
    CGSize frameSize = _scrollView.frame.size;
    float contentOffsetX = MAX((float)-_scrollView.frame.size.width / 2, MIN((float)_scrollView.contentOffset.x, (float)(_scrollView.contentSize.width - _scrollView.frame.size.width / 2 - 1)));
    [_pagerView setPage:MAX(0, MIN(((float)(contentOffsetX / frameSize.width)), lastIndex))];
    

    /*
    int currentTopImage = (int)((contentOffsetX + frameSize.width / 2) / frameSize.width);
    currentTopImage = MAX(0, MIN(currentTopImage, lastIndex));
    
    int currentBottomImage = ((int)(contentOffsetX + frameSize.width / 2)) % ((int)frameSize.width) < frameSize.width / 2 ? currentTopImage - 1 : currentTopImage + 1;
    currentBottomImage = MAX(0, MIN(currentBottomImage, lastIndex));
    
    if (currentTopImage != _currentTopImage)
    {
        _currentTopImage = currentTopImage;
        _topImageView.image = [_images objectAtIndex:_currentTopImage];
    }
    
    if (currentBottomImage != _currentBottomImage)
    {
        _currentBottomImage = currentBottomImage;
        _bottomImageView.image = [_images objectAtIndex:_currentBottomImage];
    }
    
    float distance = fmodf((float)(contentOffsetX + frameSize.width / 2), (float)frameSize.width);
    
    if (distance > frameSize.width / 2)
        distance = (float)frameSize.width - distance;
    distance += frameSize.width / 2;
    
    distance = MAX((float)-frameSize.width, MIN((float)frameSize.width, distance));
    
    float alpha = distance / ((float)frameSize.width);
    alpha = MAX(0.0f, MIN(1.0f, alpha));
    
    if (_currentTopImage != _currentBottomImage)
        _topImageView.alpha = MAX(0.0f, MIN(1.0f, alpha));
    else
    {
        _topImageView.alpha = 1.0f;
        if (_currentBottomImage == lastIndex)
            alpha = -alpha + 2.0f;
    }
    
    CGRect topImageFrame = _topImageView.frame;
    topImageFrame.origin.x = -20 + (1.0f - alpha) * 20 * (_currentTopImage < _currentBottomImage ? -1 : 1);
    _topImageView.frame = topImageFrame;
    
    CGRect bottomImageFrame = _bottomImageView.frame;
    bottomImageFrame.origin.x = -20 + alpha * 20 * (_currentTopImage < _currentBottomImage ? 1 : -1);
    _bottomImageView.frame = bottomImageFrame;
    
    //TGLog(@"distance = %f, front = %d, back = %d", distance, _currentTopImage, _currentBottomImage);*/
}

@end
