/* ***** BEGIN LICENSE BLOCK *****
 * Version: MPL 1.1
 *
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 * for the specific language governing rights and limitations under the
 * License.
 *
 * The Original Code is the Alfresco Mobile App.
 *
 * The Initial Developer of the Original Code is Zia Consulting, Inc.
 * Portions created by the Initial Developer are Copyright (C) 2011-2012
 * the Initial Developer. All Rights Reserved.
 *
 *
 * ***** END LICENSE BLOCK ***** */
//
//  SelectDocumentController.m
//

#import "SelectDocumentController.h"
#import "FolderTableViewDataSource.h"
#import "Utility.h"

@implementation SelectDocumentController
@synthesize multiSelection = _multiSelection;
@synthesize noDocumentsFooterTitle = _noDocumentsFooterTitle;
@synthesize delegate = _delegate;

- (void)dealloc
{
    _noDocumentsFooterTitle = nil;
}

- (void)viewDidLoad 
{
    [super viewDidLoad];
    // If the VC's title was already configured do not override
    if (!self.title)
    {
        [self setTitle:NSLocalizedString(@"select-document", @"SelectDocument View Title")];
    }
    
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(performCancel:)]];
    if (!self.doneOnTap || self.multiSelection)
    {
        UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(performDone:)];
        [button setEnabled:NO];
        styleButtonAsDefaultAction(button);
        [self.navigationItem setRightBarButtonItem:button];
    }
    else
    {
        [self.navigationItem setRightBarButtonItem:nil];
    }
    
    [self.tableView setAllowsMultipleSelectionDuringEditing:self.multiSelection];
    [self.tableView setEditing:self.multiSelection];
    [(FolderTableViewDataSource *)self.tableView.dataSource setMultiSelection:self.multiSelection];
    if (self.noDocumentsFooterTitle)
    {
        [(FolderTableViewDataSource *)self.tableView.dataSource setNoDocumentsFooterTitle:self.noDocumentsFooterTitle];
    }
}

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.doneOnTap || self.multiSelection)
    {
        NSInteger selectedCount = [[tableView indexPathsForSelectedRows] count];
        [self.navigationItem.rightBarButtonItem setEnabled:(selectedCount != 0)];
    }
    else
    {
        [self performDone:self];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.multiSelection) {
        NSInteger selectedCount = [[tableView indexPathsForSelectedRows] count];
        [self.navigationItem.rightBarButtonItem setEnabled:(selectedCount != 0)];
    }
}

#pragma mark - Button handlers
- (void)performCancel:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(savedDocumentPickerDidCancel:)])
    {
        [self.delegate savedDocumentPickerDidCancel: (SavedDocumentPickerController *)self.navigationController];
    }
}

- (void)performDone:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(savedDocumentPicker:didPickDocuments:)])
    {
        FolderTableViewDataSource *datasource = [self folderDatasource];
        [self.delegate savedDocumentPicker:(SavedDocumentPickerController *)self.navigationController didPickDocuments:[datasource selectedDocumentsURLs]];
    }
}

@end
