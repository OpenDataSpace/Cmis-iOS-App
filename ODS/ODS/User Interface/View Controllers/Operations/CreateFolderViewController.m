//
//  CreateFolderViewController.m
//  ODS
//
//  Created by bdt on 8/27/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import "CreateFolderViewController.h"
#import "TextFieldTableViewCell.h"

#import "CMISConstants.h"

static NSString * const kCreateFolderCellIdentifier = @"CreateFolderCellIdentifier";

@interface CreateFolderViewController () {
    TextFieldTableViewCell *folderNameCell;
}

@end

@implementation CreateFolderViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        folderNameCell = nil;
        self.regexNameValidation = [NSRegularExpression regularExpressionWithPattern:@"(.*[\"*\\\\><\\\?/:|]+.*)|(.*[.]?.*[.]+$)|(.*[ ]+$)" options:0 error:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // Title
    [self.navigationItem setTitle:NSLocalizedString(@"add.actionsheet.create-folder", @"Create Folder")];
    
    // Cancel button
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(handleCancelButton:)];
    cancelButton.title = NSLocalizedString(@"cancelButton", @"Cancel");
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    // Create button
    UIBarButtonItem *createButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Create", @"Create")
                                                                      style:UIBarButtonItemStyleDone
                                                                     target:self
                                                                     action:@selector(handleCreateButton:)];
    
    createButton.enabled = NO;
    self.navigationItem.rightBarButtonItem = createButton;
    self.createButton = createButton;
    
    //register table cell class
    [self.tableView registerNib:[UINib nibWithNibName:@"TextFieldTableViewCell" bundle:nil] forCellReuseIdentifier:kCreateFolderCellIdentifier];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;  //only folder name
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TextFieldTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:kCreateFolderCellIdentifier forIndexPath:indexPath];
    
    if (indexPath.row == 0 && indexPath.section == 0) {
        folderNameCell = (TextFieldTableViewCell*) cell;
        [folderNameCell.lblTitle setText:NSLocalizedString(@"create-folder.fields.name", @"Name")];
        [folderNameCell.textField setPlaceholder:NSLocalizedString(@"create-folder.placeholder.required", @"Required")];
        [folderNameCell.textField addTarget:self
                      action:@selector(textFieldDidChange:)
            forControlEvents:UIControlEventEditingChanged];
        [folderNameCell.textField setDelegate:self];
    }
    
    return cell;
}

- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return NSLocalizedString(@"create-folder.header.details", "NEW FOLDER DETAILS");
    }
    
    return @"";
}

#pragma mark - UI event handlers

- (void)handleCancelButton:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^(void) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(createFolderCancelled:)])
        {
            [self.delegate performSelector:@selector(createFolderCancelled:) withObject:self];
        }
    }];
}

- (void)handleCreateButton:(id)sender
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = NSLocalizedString(@"create-folder.in-progress", @"Creating folder...");
    self.progressHUD = hud;
    [folderNameCell.textField resignFirstResponder];
    
	//create folder
    [self createFolder:[[folderNameCell textField ]text]];
}

#pragma mark - UITextField Delegate
- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    return YES;
}

-(void)textFieldDidChange :(UITextField *)theTextField{
    
    //Validate Folder Name, and enable or disable create button
    [self.createButton setEnabled:[self ValidateFolderName:theTextField.text]];
}

#pragma mark - Helpers
- (BOOL) ValidateFolderName:(NSString*) text {
    if ([text length] > 0) {
        NSArray *matches = [self.regexNameValidation matchesInString:text options:0 range:NSMakeRange(0, text.length)];
        
        return (matches.count == 0);
    }
    
    return NO;
}

- (void) createFolder:(NSString*) folderName {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    [params setObject:kCMISPropertyObjectTypeIdValueFolder forKey:kCMISPropertyObjectTypeId];
    [params setObject:folderName forKey:kCMISPropertyName];
    
    self.folderName = folderName;
    
    [self.parentFolder createFolder:params completionBlock:^(NSString* objectId, NSError* error) {
        stopProgressHUD(self.progressHUD);
        if (objectId == nil) {
            ODSLogError(@"%@", error);
            if (self.delegate && [self.delegate respondsToSelector:@selector(createFolder:failedForName:)])
            {
                [self.delegate performSelector:@selector(createFolder:failedForName:) withObject:self withObject:self.folderName];
            }
        }else {
            [self dismissViewControllerAnimated:YES completion:^(void) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(createFolder:succeededForName:)])
                {
                    [self.delegate performSelector:@selector(createFolder:succeededForName:) withObject:self withObject:self.folderName];
                }
            }];
        }
    }];
}

@end
