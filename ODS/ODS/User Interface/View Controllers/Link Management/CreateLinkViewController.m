//
//  CreateLinkViewController.m
//  ODS
//
//  Created by bdt on 10/28/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import "CreateLinkViewController.h"
#import "TextFieldTableViewCell.h"
#import "TextViewTableViewCell.h"
#import "CMISUtility.h"
#import "CMISConstants+ODS.h"
#import "CMISFolder.h"

static NSString * const kLinkEmailModelIdentifier = @"email";
static NSString * const kLinkSubjectModelIdentifier = @"subject";
static NSString * const kLinkExpirationDateModelIdentifier = @"expirationdate";
static NSString * const kLinkPasswordModelIdentifier = @"password";
static NSString * const kLinkMessageModelIdentifier = @"message";

@interface CreateLinkViewController ()
@property (nonatomic, strong) NSMutableArray *fieldArray;

/* properities of creating link */
@property (nonatomic, copy) NSString *emailAddress;
@property (nonatomic, copy) NSString *subject;
@property (nonatomic, strong) NSDate *expirationDate;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, copy) NSString *message;
@end

@implementation CreateLinkViewController
@synthesize delegate = _delegate;
@synthesize createButton = _createButton;
@synthesize repositoryItem = _repositoryItem;
@synthesize accountUUID = _accountUUID;
@synthesize parentItem = _parentItem;
@synthesize progressHUD = _progressHUD;
@synthesize viewTitle = _viewTitle;

@synthesize emailAddress = _emailAddress;
@synthesize subject = _subject;
@synthesize expirationDate = _expirationDate;
@synthesize password = _password;
@synthesize message = _message;

- (void) dealloc {
    _delegate = nil;
    _createButton = nil;
    _repositoryItem = nil;
    _accountUUID = nil;
    _parentItem = nil;
    _progressHUD = nil;
    _viewTitle = nil;
}

- (id)initWithRepositoryItem:(CMISObject *)repoItem parentItem:(CMISFolder*) parentItem accountUUID:(NSString *)accountUUID {
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        _repositoryItem = repoItem;
        _accountUUID = accountUUID;
        _parentItem = parentItem;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.navigationItem setTitle:_viewTitle];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(handleCancelButton:)];
    cancelButton.title = NSLocalizedString(@"cancelButton", @"Cancel");
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    UIBarButtonItem *createButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Create", @"Create")
                                                                     style:UIBarButtonItemStyleDone
                                                                    target:self
                                                                    action:@selector(handleCreateButton:)];
    createButton.enabled = NO;
    styleButtonAsDefaultAction(createButton);
    self.navigationItem.rightBarButtonItem = createButton;
    self.createButton = createButton;
    
    [self createTableViewCells];
    [self.tableView reloadData];
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark CustomTableView
- (void) createTableViewCells {
    self.tableSections = [NSMutableArray array];
    self.fieldArray = [NSMutableArray array];
    
    NSMutableArray *linkConf = [NSMutableArray array];
    
    //email
    TextFieldTableViewCell *emailCell = (TextFieldTableViewCell*)[self createTableViewCellFromNib:@"TextFieldTableViewCell"];
    [emailCell.textField setKeyboardType:UIKeyboardTypeEmailAddress];
    [emailCell.lblTitle setText:NSLocalizedString(@"create-link.fields.email", @"Email")];
    [emailCell.textField setPlaceholder:NSLocalizedString(@"create-link.placeholder.required", @"required")];
    [emailCell.textField addTarget:self action:@selector(updateValue:) forControlEvents:UIControlEventEditingChanged];
    [emailCell.textField setReturnKeyType:UIReturnKeyNext];
    [[emailCell textField] setDelegate:self];
    [emailCell setModelIdentifier:kLinkEmailModelIdentifier];
    
    [linkConf addObject:emailCell];
    [self.fieldArray addObject:[emailCell textField]];
    
    //subject
    TextFieldTableViewCell *subjectCell = (TextFieldTableViewCell*)[self createTableViewCellFromNib:@"TextFieldTableViewCell"];
    [subjectCell.textField setKeyboardType:UIKeyboardTypeAlphabet];
    [subjectCell.lblTitle setText:NSLocalizedString(@"create-link.fields.subject", @"Subject")];
    [subjectCell.textField setPlaceholder:NSLocalizedString(@"create-link.placeholder.required", @"required")];
    [subjectCell.textField addTarget:self action:@selector(updateValue:) forControlEvents:UIControlEventEditingChanged];
    [subjectCell.textField setReturnKeyType:UIReturnKeyNext];
    [[subjectCell textField] setDelegate:self];
    [subjectCell setModelIdentifier:kLinkSubjectModelIdentifier];
    
    [linkConf addObject:subjectCell];
    [self.fieldArray addObject:[subjectCell textField]];
    
    //expirationdate
    DateInputTableViewCell *dateCell = [[DateInputTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    [dateCell.textLabel setText:NSLocalizedString(@"create-link.fields.expirationdate", @"ExpirationDate")];
    [dateCell setModelIdentifier:kLinkExpirationDateModelIdentifier];
    [dateCell setDelegate:self];
    
    [linkConf addObject:dateCell];
    
    //password
    TextFieldTableViewCell *passwordCell = (TextFieldTableViewCell*)[self createTableViewCellFromNib:@"TextFieldTableViewCell"];
    [passwordCell.textField setKeyboardType:UIKeyboardTypeDefault];
    [passwordCell.textField setSecureTextEntry:YES];
    [passwordCell.lblTitle setText:NSLocalizedString(@"create-link.fields.password", @"Password")];
    [passwordCell.textField setPlaceholder:NSLocalizedString(@"create-link.placeholder.optional", @"optional")];
    [passwordCell.textField addTarget:self action:@selector(updateValue:) forControlEvents:UIControlEventEditingChanged];
    [passwordCell.textField setReturnKeyType:UIReturnKeyNext];
    [[passwordCell textField] setDelegate:self];
    [passwordCell setModelIdentifier:kLinkPasswordModelIdentifier];
    
    [linkConf addObject:passwordCell];
    [self.fieldArray addObject:[passwordCell textField]];
    
    //message
    TextViewTableViewCell *messageCell = (TextViewTableViewCell*)[self createTableViewCellFromNib:@"TextViewTableViewCell"];
    [messageCell.textView setKeyboardType:UIKeyboardTypeDefault];
    [messageCell.labelTitle setText:NSLocalizedString(@"create-link.fields.message", @"")];
    [messageCell.textView setDelegate:self];
    [messageCell.textView setReturnKeyType:UIReturnKeyDefault];
    [[messageCell textView] setDelegate:self];
    [messageCell setModelIdentifier:kLinkMessageModelIdentifier];
    
    [linkConf addObject:messageCell];
    [self.fieldArray addObject:[messageCell textView]];
    
    [self.tableSections addObject:linkConf];
}

#pragma mark -
#pragma mark UITableView delegate & datasource

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.tableSections) {
        return [self.tableSections count];
    }
    
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.tableSections) {
        NSArray *itemsOfSection = [self.tableSections objectAtIndex:section];
        if (itemsOfSection) {
            return [itemsOfSection count];
        }
    }
    
    return 0;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.tableSections) {
        NSArray *itemsOfSection = [self.tableSections objectAtIndex:indexPath.section];
        if (itemsOfSection) {
            UITableViewCell *cell = [itemsOfSection objectAtIndex:indexPath.row];
            if (cell) {
                return cell;
            }
        }
    }
    return nil;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *optionsOfSection = nil;
    
    if (self.tableSections) {
        optionsOfSection = [self.tableSections objectAtIndex:indexPath.section];
        CustomTableViewCell *cell =  [optionsOfSection objectAtIndex:indexPath.row];
        if ([cell.modelIdentifier isEqualToCaseInsensitiveString:kLinkMessageModelIdentifier]) {
            return 132.0f;
        }
    }
    
    return 44.0f;
}

- (BOOL) enableRefreshController {
    return NO;
}

- (BOOL)validateFormValues {
    BOOL isValid = YES;
    
    if (_emailAddress == nil  || [_emailAddress rangeOfString:@"^.+@.+\\..{2,}$" options:NSRegularExpressionSearch].location == NSNotFound)
    {
        // Name check against regex - requires no match
        isValid = NO;
    }
    
    if (_subject == nil || [_subject length] < 1) {
        isValid = NO;
    }
    
    if ( _message == nil || [_message length] < 1) {
        isValid = NO;
    }
    
    return isValid;
}

- (void) saveTextFieldValue:(TextFieldTableViewCell*) cell {
    if ([[cell modelIdentifier] isEqualToCaseInsensitiveString:kLinkEmailModelIdentifier]) {
        _emailAddress = [cell.textField text];
    }else if ([[cell modelIdentifier] isEqualToCaseInsensitiveString:kLinkSubjectModelIdentifier]) {
        _subject = [cell.textField text];
    }else if ([[cell modelIdentifier] isEqualToCaseInsensitiveString:kLinkPasswordModelIdentifier]) {
        _password = [cell.textField text];
    }else if ([[cell modelIdentifier] isEqualToCaseInsensitiveString:kLinkMessageModelIdentifier]) {
        _message = [cell.textField text];
    }else {
        ODSLogDebug(@"is a not valid mode identifier:%@", [cell modelIdentifier]);
    }
}

#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    for (int i = 0; i < [self.fieldArray count]; i++) {
        UITextField *field = [self.fieldArray objectAtIndex:i];
        if ([field isEqual:textField] && i != ([self.fieldArray count] - 1)) {
            [[self.fieldArray objectAtIndex:i+1] becomeFirstResponder];
            return YES;
        }
    }
    
    [textField resignFirstResponder];
    [self resignFirstResponder];
    
    return YES;
}

- (void)updateValue:(id)sender {
    UIView *senderView = (UIView*)sender;
    TextFieldTableViewCell *cell = (TextFieldTableViewCell *) senderView.superview;
    while (1) {
        if ([cell isKindOfClass:[TextFieldTableViewCell class]]) {  //find cell class
            break;
        }
        cell = (TextFieldTableViewCell *) cell.superview;
    }
    
    [self saveTextFieldValue:cell];
    
    [self.navigationItem.rightBarButtonItem setEnabled:[self validateFormValues]];
}

#pragma mark UITextViewDelegate

- (BOOL) textViewShouldBeginEditing:(UITextView *)textViewIn {
   
    return YES;
}

- (void)textViewDidChange:(UITextView *)textViewIn {
    _message = textViewIn.text;
    [self.navigationItem.rightBarButtonItem setEnabled:[self validateFormValues]];
}

#pragma mark -
#pragma mark Date Input Delegate
- (void) dateValueChanged:(NSDate*) date {
    _expirationDate = date;
}

#pragma mark -
#pragma mark Handle Expiration Date
- (NSDate *) handleExpirationDate:(NSDate*) orgDate {
    
    NSInteger unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit;
    NSDateComponents *orgDateComponents = [[NSCalendar currentCalendar] components:unitFlags fromDate:orgDate == nil?[NSDate date]: orgDate];
    [orgDateComponents setDay:[orgDateComponents day] + 1];
    [orgDateComponents setHour:0];
    [orgDateComponents setMinute:0];
    [orgDateComponents setSecond:0];
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    [cal setTimeZone:[NSTimeZone localTimeZone]];
    [cal setLocale:[NSLocale currentLocale]];
    
    NSDate *newDate = [cal dateFromComponents:orgDateComponents];
    
    return newDate;
}

#pragma mark - UI event handlers

- (void)handleCancelButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^(void) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(createLinkCancelled:)])
        {
            [self.delegate performSelector:@selector(createLinkCancelled:) withObject:self];
        }
    }];
}

- (void)handleCreateButton:(id)sender {
    [self showProgressHUD];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyy-MM-dd'T'HH:mm:ss'Z'"];
    NSDate *dateSelected = [self handleExpirationDate:_expirationDate];
   
    NSDictionary *linkInfo =[NSDictionary dictionaryWithObjectsAndKeys:_emailAddress, kCMISPropertyGDSEmailAddressId,
                             _subject, kCMISPropertyGDSSubjectId,
                             _message, kCMISPropertyGDSMessageId,
                             dateSelected==nil?[NSDate date]:dateSelected, kCMISPropertyCmisExpirationDateId,
                             [NSArray arrayWithObjects:_repositoryItem.identifier, nil] , kCMISPropertyGDSObjectIdsId,
                             _password, kCMISPropertyGDSPasswordId,
                             nil];
    
    CMISProperties *properties = [CMISUtility linkParametersToCMISProperties:linkInfo];
    [_parentItem createLinkWithProperties:properties completionBlock:^(NSString *objectId, NSError *error) {
        stopProgressHUD(self.progressHUD);
        if (error) {
            ODSLogError(@"createLinkWithProperties:%@", error);
            if (self.delegate && [self.delegate respondsToSelector:@selector(createLink:failedForName:)])
            {
                [self.delegate performSelector:@selector(createLink:failedForName:) withObject:self withObject:_emailAddress];
            }
        }else {
            [self dismissViewControllerAnimated:YES completion:^(void) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(createLink:succeededForName:)])
                {
                    [self.delegate performSelector:@selector(createLink:succeededForName:) withObject:self withObject:_emailAddress];
                }
            }];
        }
    }];
}

#pragma mark - Show ProgressHUD
- (void) showProgressHUD {
    self.progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.progressHUD.mode = MBProgressHUDModeIndeterminate;
    self.progressHUD.labelText = NSLocalizedString(@"creating.link", @"Creating link...");
}
@end
