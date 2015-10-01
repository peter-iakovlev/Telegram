#import "TGGoogleDriveDirectoryController.h"

#import "GDFileManager.h"
#import "GDURLMetadata.h"
#import "GDGoogleDriveMetadata.h"
#import "GDGoogleDriveURLMetadata.h"

#import "TGFont.h"

#import "TGGoogleDriveItemCell.h"

static NSComparator TGGoogleDriveDirectoryFileComparator = ^NSComparisonResult(GDURLMetadata *metadata1, GDURLMetadata *metadata2){
    NSComparisonResult result = [metadata1.filename localizedStandardCompare:metadata2.filename];
    if (result == NSOrderedSame)
        result = [[metadata1.canonicalURL absoluteString] compare:[metadata2.canonicalURL absoluteString]];
    return result;
};

@interface TGGoogleDriveDirectoryController () <UITableViewDataSource, UITableViewDelegate>
{
    GDFileManager *_fileManager;
    GDURLMetadata *_metadata;
    
    NSArray *_items;
    
    UITableView *_tableView;
    UIActivityIndicatorView *_activityIndicator;
    UILabel *_messageLabel;
}
@end

@implementation TGGoogleDriveDirectoryController

- (instancetype)initWithFileManager:(GDFileManager *)fileManager
{
    return [self initWithFileManager:fileManager url:nil metadata:nil];
}

- (instancetype)initWithFileManager:(GDFileManager *)fileManager url:(NSURL *)directoryUrl metadata:(GDURLMetadata *)metadata
{
    self = [super init];
    if (self != nil)
    {
        _fileManager = fileManager;
        _directoryUrl = directoryUrl;
        _metadata = metadata;
        
        if (_metadata.filename.length > 0)
            self.title = _metadata.filename;
        else
            self.title = TGLocalized(@"GoogleDrive.Title");
        
        if (_directoryUrl == nil)
        {
            [self setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"GoogleDrive.Logout") style:UIBarButtonItemStylePlain target:self action:@selector(logoutButtonPressed)]];
        }
        
        [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonPressed)]];
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.rowHeight = 52.0f;
    _tableView.scrollEnabled = false;
    [self.view addSubview:_tableView];
    
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    
    CGRect frame = _activityIndicator.frame;
    frame.origin.x = CGFloor(self.view.bounds.size.width / 2 - frame.size.width / 2);
    frame.origin.y = 68;
    _activityIndicator.frame = frame;
    
    [_activityIndicator startAnimating];
    _activityIndicator.userInteractionEnabled = false;
    [_tableView addSubview:_activityIndicator];
    
    _messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 68, self.view.bounds.size.width, 20)];
    _messageLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _messageLabel.backgroundColor = [UIColor clearColor];
    _messageLabel.font = TGSystemFontOfSize(17);
    _messageLabel.hidden = true;
    _messageLabel.textAlignment = NSTextAlignmentCenter;
    _messageLabel.textColor = UIColorRGB(0x808080);
    _messageLabel.userInteractionEnabled = false;
    [_tableView addSubview:_messageLabel];
    
    if (![self _updateControllerInset:false])
        [self controllerInsetUpdated:UIEdgeInsetsZero];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (_tableView.indexPathForSelectedRow != nil)
        [_tableView deselectRowAtIndexPath:_tableView.indexPathForSelectedRow animated:true];
    
    if (_directoryUrl != nil && _items.count == 0)
        [self reloadData];
}

- (void)cancelButtonPressed
{
    if (self.cancelPressed != nil)
        self.cancelPressed();
}

- (void)logoutButtonPressed
{
    if (self.logoutPressed != nil)
        self.logoutPressed();
}

- (void)reloadData
{
    if (_items.count == 0)
        [self setIsLoading:true];
    
    [_fileManager getContentsOfDirectoryAtURL:_directoryUrl success:^(NSArray *contents)
    {
        NSMutableArray *items = [[NSMutableArray alloc] init];
        for (GDURLMetadata *urlMetadata in contents)
        {
            GDGoogleDriveURLMetadata *driveUrlMetadata = urlMetadata.driveMetadata;
            GDGoogleDriveMetadata *metadata = nil;
            if (driveUrlMetadata != nil)
                metadata = driveUrlMetadata.metadata;
            
            if (metadata.exportUrls.count == 0)
                [items addObject:urlMetadata];
        }
        
        _items = [items sortedArrayUsingComparator:TGGoogleDriveDirectoryFileComparator];
        [_tableView reloadData];
        _tableView.scrollEnabled = true;
        if (_items.count == 0)
        {
            _messageLabel.hidden = false;
            _messageLabel.text = TGLocalized(@"GoogleDrive.FolderIsEmpty");
        }
        else
        {
            _messageLabel.hidden = true;
        }
        
        [self setIsLoading:false];
        
    } failure:^(__unused NSError *error)
    {
        if (_items.count == 0)
        {
            _messageLabel.hidden = false;
            _messageLabel.text = TGLocalized(@"GoogleDrive.FolderLoadError");
        }
        
        [self setIsLoading:false];
    }];
}

- (void)setIsLoading:(bool)isLoading
{
    if (isLoading)
        [_activityIndicator startAnimating];
    else
        [_activityIndicator stopAnimating];
}

#pragma mark - Table View Data Source & Delegate

- (NSInteger)tableView:(UITableView *)__unused tableView numberOfRowsInSection:(NSInteger)__unused section
{
    return _items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TGGoogleDriveItemCell *cell = [tableView dequeueReusableCellWithIdentifier:TGGoogleDriveItemCellKind];
    if (cell == nil)
        cell = [[TGGoogleDriveItemCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TGGoogleDriveItemCellKind];
    
    GDURLMetadata *metadata = _items[indexPath.row];
    [cell configureWithMetadata:metadata];
    
    return cell;
}

- (void)tableView:(UITableView *)__unused tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    GDURLMetadata *metadata = _items[indexPath.row];
    
    if (metadata.isDirectory)
    {
        TGGoogleDriveDirectoryController *controller = [[TGGoogleDriveDirectoryController alloc] initWithFileManager:_fileManager url:metadata.url metadata:metadata];
        controller.filePicked = self.filePicked;
        controller.cancelPressed = self.cancelPressed;
        
        [self.navigationController pushViewController:controller animated:true];
    }
    else
    {
        if (self.filePicked != nil)
            self.filePicked(metadata);
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)__unused indexPath
{
    return tableView.rowHeight;
}

@end
