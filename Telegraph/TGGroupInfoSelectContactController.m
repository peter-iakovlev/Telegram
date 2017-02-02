/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGGroupInfoSelectContactController.h"

#import "TGGroupInfoContactListCreateLinkCell.h"

@implementation TGGroupInfoSelectContactController

- (void)loadView
{
    [super loadView];
    
    [self setTitleText:TGLocalized(@"GroupInfo.AddParticipantTitle")];
    [self setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(cancelPressed)]];
}

- (void)singleUserSelected:(TGUser *)user
{
    [self deselectRow];
    
    id<TGGroupInfoSelectContactControllerDelegate> delegate = _delegate;
    if ([delegate respondsToSelector:@selector(selectContactControllerDidSelectUser:)])
        [delegate selectContactControllerDidSelectUser:user];
}

- (void)cancelPressed
{
    [self.presentingViewController dismissViewControllerAnimated:true completion:nil];
}

- (NSInteger)numberOfRowsInFirstSection
{
    if (self.contactsMode & TGContactsModeCreateGroupLink)
        return 1;
    return 0;
}

- (CGFloat)itemHeightForFirstSection
{
    return 56.0f;
}

- (UITableViewCell *)cellForRowInFirstSection:(NSInteger)__unused row
{
    TGGroupInfoContactListCreateLinkCell *cell = (TGGroupInfoContactListCreateLinkCell *)[self.tableView dequeueReusableCellWithIdentifier:@"TGGroupInfoContactListCreateLinkCell"];
    if (cell == nil)
    {
        cell = [[TGGroupInfoContactListCreateLinkCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TGGroupInfoContactListCreateLinkCell"];
    }
    
    return cell;
}

- (void)didSelectRowInFirstSection:(NSInteger)__unused row
{
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:true];
    id<TGGroupInfoSelectContactControllerDelegate> delegate = _delegate;
    [delegate selectContactControllerDidSelectCreateLink];
}

@end