//
//  AccountViewController.m
//  ODS
//
//  Created by bdt on 9/25/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import "AccountViewController.h"
#import "TextFieldTableViewCell.h"
#import "UISwitchTableViewCell.h"
#import "CheckMarkTableViewCell.h"

#import "AccountManager.h"

#import "CMISSession.h"
#import "CMISErrors.h"

@interface AccountViewController ()
@property (nonatomic, strong) NSMutableArray *fieldArray;
@property (nonatomic, strong) AccountInfo   *tempAcctInfo;
@end

@implementation AccountViewController
@synthesize tempAcctInfo = _tempAcctInfo;
@synthesize acctInfo = _acctInfo;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIBarButtonItem *cancelBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(processCancelButtonAction:)];
    [self.navigationItem setLeftBarButtonItem:cancelBarItem];
    
    UIBarButtonItem *saveBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(processSaveButtonAction:)];
    [saveBarItem setEnabled:NO];
    [self.navigationItem setRightBarButtonItem:saveBarItem];
    
     _tempAcctInfo = [[AccountInfo alloc] init];
    if (!self.isNew) {
        //new a account
        _tempAcctInfo = [[AccountInfo alloc] init];
        _tempAcctInfo.vendor = _acctInfo.vendor;
        _tempAcctInfo.description = _acctInfo.description;
        _tempAcctInfo.protocol = _acctInfo.protocol;
        _tempAcctInfo.hostname = _acctInfo.hostname;
        _tempAcctInfo.port = _acctInfo.port;
        _tempAcctInfo.serviceDocumentRequestPath = _acctInfo.serviceDocumentRequestPath;
        _tempAcctInfo.username = _acctInfo.username;
        _tempAcctInfo.password = _acctInfo.password;
        _tempAcctInfo.accountStatus = _acctInfo.accountStatus;
        _tempAcctInfo.isDefaultAccount = _acctInfo.isDefaultAccount;
        _tempAcctInfo.cmisType = _acctInfo.cmisType;
    }
    
    [self createAccountComponents];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL) enableRefreshController {
    return NO;
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

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *optionsOfSection = nil;
    
    if (self.tableSections) {
        optionsOfSection = [self.tableSections objectAtIndex:indexPath.section];
        UITableViewCell *cell =  [optionsOfSection objectAtIndex:indexPath.row];
        if ([cell isKindOfClass:[CheckMarkTableViewCell class]]) {
            CheckMarkTableViewCell *checkMarkCell = (CheckMarkTableViewCell*)cell;
            CheckMarkViewController *checkMarkController = [[CheckMarkViewController alloc] initWithStyle:UITableViewStyleGrouped];
            [checkMarkController setCheckMarkDelegate:self];
            [checkMarkController setOptions:[checkMarkCell checkOptions]];
            [checkMarkController setSelectedIndex:[[_tempAcctInfo cmisType] integerValue]];
            [checkMarkController setViewTitle:checkMarkCell.textLabel.text];
            [checkMarkController setCheckMarkCell:checkMarkCell];
            
            [self.navigationController pushViewController:checkMarkController animated:YES];
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0f;
}

- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (self.tableHeaders && [self.tableHeaders count] > section) {
        return [self.tableHeaders objectAtIndex:section];
    }
    return @"";
}

#pragma mark -
#pragma mark UI Helpers

- (void) createAccountComponents {
    self.tableHeaders = [NSMutableArray array];
    self.tableSections = [NSMutableArray array];
    self.fieldArray = [NSMutableArray array];
    
    //account authentication
    [self.tableHeaders addObject:NSLocalizedString(@"accountdetails.header.authentication", @"Account Authentication")];
    
    TextFieldTableViewCell *cellUser = (TextFieldTableViewCell*)[self createTableViewCellFromNib:@"TextFieldTableViewCell"];
    [cellUser.lblTitle setText:NSLocalizedString(@"accountdetails.fields.username", @"Username")];
    [cellUser.textField setPlaceholder:NSLocalizedString(@"accountdetails.placeholder.required", @"required")];
    if ([_tempAcctInfo username] != nil && [[_tempAcctInfo username] length] > 0) {
        [cellUser.textField setText:[_tempAcctInfo username]];
    }
    [cellUser setModelIdentifier:kServerUsername];
    [cellUser.textField setDelegate:self];
    [cellUser.textField addTarget:self action:@selector(updateValue:) forControlEvents:UIControlEventEditingChanged];
    [cellUser.textField setReturnKeyType:UIReturnKeyNext];
    [self.fieldArray addObject:cellUser.textField];
    
    TextFieldTableViewCell *cellPassword = (TextFieldTableViewCell*)[self createTableViewCellFromNib:@"TextFieldTableViewCell"];
    [cellPassword.lblTitle setText:NSLocalizedString(@"accountdetails.fields.password", @"Password")];
    [cellPassword.textField setSecureTextEntry:YES];
    [cellPassword.textField setPlaceholder:NSLocalizedString(@"accountdetails.placeholder.required", @"required")];
    if ([_tempAcctInfo password] != nil && [[_tempAcctInfo password] length] > 0) {
        [cellPassword.textField setText:[_tempAcctInfo password]];
    }
    [cellPassword setModelIdentifier:kServerPassword];
    [cellPassword.textField setDelegate:self];
    [cellPassword.textField addTarget:self action:@selector(updateValue:) forControlEvents:UIControlEventEditingChanged];
    [cellPassword.textField setReturnKeyType:UIReturnKeyNext];
    [self.fieldArray addObject:cellPassword.textField];
    
    TextFieldTableViewCell *cellServer = (TextFieldTableViewCell*)[self createTableViewCellFromNib:@"TextFieldTableViewCell"];
    [cellServer.lblTitle setText:NSLocalizedString(@"accountdetails.fields.hostname", @"Server Address")];
    [cellServer.textField setPlaceholder:NSLocalizedString(@"accountdetails.placeholder.required", @"required")];
    if ([_tempAcctInfo hostname] != nil && [[_tempAcctInfo hostname] length] > 0) {
        [cellServer.textField setText:[_tempAcctInfo hostname]];
    }
    [cellServer setModelIdentifier:kServerHostName];
    [cellServer.textField setDelegate:self];
    [cellServer.textField addTarget:self action:@selector(updateValue:) forControlEvents:UIControlEventEditingChanged];
    [cellServer.textField setReturnKeyType:UIReturnKeyNext];
    [self.fieldArray addObject:cellServer.textField];
    
    TextFieldTableViewCell *cellDesc = (TextFieldTableViewCell*)[self createTableViewCellFromNib:@"TextFieldTableViewCell"];
    [cellDesc.lblTitle setText:NSLocalizedString(@"accountdetails.fields.description", @"Description")];
    [cellDesc.textField setPlaceholder:NSLocalizedString(@"accountdetails.placeholder.serverdescription", @"CMIS Provider")];
    if ([_tempAcctInfo vendor] != nil && [[_tempAcctInfo vendor] length] > 0) {
        [cellDesc.textField setText:[_tempAcctInfo vendor]];
    }
    [cellDesc setModelIdentifier:kServerVendor];
    [cellDesc.textField setDelegate:self];
    [cellDesc.textField addTarget:self action:@selector(updateValue:) forControlEvents:UIControlEventEditingChanged];
    [cellDesc.textField setReturnKeyType:UIReturnKeyNext];
    [self.fieldArray addObject:cellDesc.textField];
    
    UISwitchTableViewCell *cellProtocol = (UISwitchTableViewCell*)[self createTableViewCellFromNib:@"UISwitchTableViewCell"];
    [cellProtocol.labelTitle setText:NSLocalizedString(@"accountdetails.fields.protocol", @"HTTPS")];
    [cellProtocol.switchButton setOn:[_tempAcctInfo.protocol isEqualToCaseInsensitiveString:kFDHTTPS_Protocol]];
    [cellProtocol.switchButton addTarget:self action:@selector(processSwitchButtonAction:) forControlEvents:UIControlEventValueChanged];
    [cellProtocol setModelIdentifier:kServerProtocol];
    [self.tableSections addObject:[NSArray arrayWithObjects:cellUser, cellPassword, cellServer, cellDesc, cellProtocol, nil]];
    
    //advanced
    [self.tableHeaders addObject:NSLocalizedString(@"accountdetails.header.advanced", @"Advanced")];
    
    TextFieldTableViewCell *cellPort = (TextFieldTableViewCell*)[self createTableViewCellFromNib:@"TextFieldTableViewCell"];
    [cellPort.lblTitle setText:NSLocalizedString(@"accountdetails.fields.port", @"Port")];
    [cellPort.textField setPlaceholder:NSLocalizedString(@"accountdetails.placeholder.required", @"required")];
    [cellPort.textField setText:[_tempAcctInfo port]];
    [cellPort setModelIdentifier:kServerPort];
    [cellPort.textField setDelegate:self];
    [cellPort.textField addTarget:self action:@selector(updateValue:) forControlEvents:UIControlEventEditingChanged];
    [cellPort.textField setReturnKeyType:UIReturnKeyNext];
    [self.fieldArray addObject:cellPort.textField];
    
    CheckMarkTableViewCell *cellCmisProtocol = (CheckMarkTableViewCell*) [self createTableViewCellFromNib:@"CheckMarkTableViewCell"];
    NSArray *protocolOptions = [NSArray arrayWithObjects:
                                [CMISUtility cmisProtocolToString:[NSNumber numberWithInteger:CMISBindingTypeAtomPub]],
                                [CMISUtility cmisProtocolToString:[NSNumber numberWithInteger:CMISBindingTypeBrowser]],nil];
    [cellCmisProtocol setModelIdentifier:kServerCMISProtocol];
    [cellCmisProtocol.textLabel setText:NSLocalizedString(@"accountdetails.fields.serviceprotocol", @"CMIS Protocol")];
    [cellCmisProtocol setCheckOptions:protocolOptions];
    [cellCmisProtocol setSelectedIndex:[[_tempAcctInfo cmisType] integerValue]];
    
    TextFieldTableViewCell *cellServiceDoc = (TextFieldTableViewCell*)[self createTableViewCellFromNib:@"TextFieldTableViewCell"];
    [cellServiceDoc.lblTitle setText:NSLocalizedString(@"accountdetails.fields.servicedoc", @"Service Document")];
    [cellServiceDoc.textField setPlaceholder:NSLocalizedString(@"accountdetails.placeholder.required", @"required")];
    [cellServiceDoc.textField setText:[_tempAcctInfo serviceDocumentRequestPath]];
    [cellServiceDoc setModelIdentifier:kServerServiceDocumentRequestPath];
    [cellServiceDoc.textField setDelegate:self];
    [cellServiceDoc.textField addTarget:self action:@selector(updateValue:) forControlEvents:UIControlEventEditingChanged];
    [cellServiceDoc.textField setReturnKeyType:UIReturnKeyDone];
    [self.fieldArray addObject:cellServiceDoc.textField];
    
    [self.tableSections addObject:[NSArray arrayWithObjects:cellPort, cellCmisProtocol, cellServiceDoc, nil]];
    
}

- (BOOL) validateAccountSettings {
    BOOL usernameValid = YES;
    BOOL passwordValid = YES;
    BOOL serverValid = YES;
    BOOL portValid = YES;
    BOOL serviceDocValid = YES;
    BOOL vendorValid = YES;
    
    
    NSString *username = [_tempAcctInfo username];
    NSString *password = [_tempAcctInfo password];
    NSString *hostname = [_tempAcctInfo hostname];
    NSString *port = [_tempAcctInfo port];
    NSString *serviceDoc = [_tempAcctInfo serviceDocumentRequestPath];
    NSString *vendor = [_tempAcctInfo vendor];
    
    NSRange hostnameRange = [hostname rangeOfString:@"^[a-zA-Z0-9_\\-\\.]+$" options:NSRegularExpressionSearch];
    usernameValid = ![username isNotEmpty];
    serverValid = ( !hostname || (hostnameRange.location == NSNotFound) );
    portValid = ([port rangeOfString:@"^[0-9]*$" options:NSRegularExpressionSearch].location == NSNotFound);
    serviceDocValid = ![serviceDoc isNotEmpty];
    vendorValid = ![vendor isNotEmpty];
    passwordValid = ![password isNotEmpty];
    
    
    return !usernameValid && !portValid && !serverValid && !serviceDocValid && !vendorValid && !passwordValid;
}

- (void) saveTextFieldValue:(TextFieldTableViewCell*) cell {
    if ([[cell modelIdentifier] isEqualToCaseInsensitiveString:kServerUsername]) {
        [_tempAcctInfo setUsername:[cell.textField text]];
    }else if ([[cell modelIdentifier] isEqualToCaseInsensitiveString:kServerPassword]) {
        [_tempAcctInfo setPassword:[cell.textField text]];
    }else if ([[cell modelIdentifier] isEqualToCaseInsensitiveString:kServerHostName]) {
        [_tempAcctInfo setHostname:[cell.textField text]];
    }else if ([[cell modelIdentifier] isEqualToCaseInsensitiveString:kServerPort]) {
        [_tempAcctInfo setPort:[cell.textField text]];
    }else if ([[cell modelIdentifier] isEqualToCaseInsensitiveString:kServerServiceDocumentRequestPath]) {
        [_tempAcctInfo setServiceDocumentRequestPath:[cell.textField text]];
    }else if ([[cell modelIdentifier] isEqualToCaseInsensitiveString:kServerVendor]) {
        [_tempAcctInfo setVendor:[cell.textField text]];
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
    
    [self.navigationItem.rightBarButtonItem setEnabled:[self validateAccountSettings]];
}

- (void) dismissViewcontroller {    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark Actions of Bar Item

- (void) saveAccount {
    if (self.isNew) {
        [[AccountManager sharedManager] saveAccountInfo:_tempAcctInfo];
    }else {
        _acctInfo.vendor = _tempAcctInfo.vendor;
        _acctInfo.description = _tempAcctInfo.description;
        _acctInfo.protocol = _tempAcctInfo.protocol;
        _acctInfo.hostname = _tempAcctInfo.hostname;
        _acctInfo.port = _tempAcctInfo.port;
        _acctInfo.serviceDocumentRequestPath = _tempAcctInfo.serviceDocumentRequestPath;
        _acctInfo.username = _tempAcctInfo.username;
        _acctInfo.password = _tempAcctInfo.password;
        _acctInfo.accountStatus = _tempAcctInfo.accountStatus;
        _acctInfo.isDefaultAccount = _tempAcctInfo.isDefaultAccount;
        _acctInfo.cmisType = _tempAcctInfo.cmisType;
        [[AccountManager sharedManager] saveAccountInfo:_acctInfo];
    }
}

- (void) processSaveButtonAction:(id) sender {
    //try to connect server
    __block CMISSessionParameters *params = getSessionParametersWithAccountInfo(_tempAcctInfo, nil);
    [self startHUD];
    
    [CMISSession arrayOfRepositories:params completionBlock:^(NSArray *repos, NSError *error){
        [self stopHUD];
        if (error != nil) {
            ODSLogError(@"%@", error);
            [CMISUtility handleCMISRequestError:error isAuthentication:YES];
        }else {
            [self saveAccount];
            dispatch_main_sync_safe(^{
                [self dismissViewcontroller];
            });
        }
    }]; 
}

- (void) processCancelButtonAction:(id) sender {
    [self dismissViewcontroller];
}

- (void) processSwitchButtonAction:(id) sender {
    UISwitch *switchButton = (UISwitch*) sender;
    
    [_tempAcctInfo setProtocol:[switchButton isOn]?kFDHTTPS_Protocol:kFDHTTP_Protocol];
    [_tempAcctInfo setPort:[switchButton isOn]?kFDHTTPS_DefaultPort:kFDHTTP_DefaultPort];
    TextFieldTableViewCell *cellPort = (TextFieldTableViewCell*)[self findeCellByModeIdentifier:kServerPort];
    [cellPort.textField setText:[_tempAcctInfo port]];
    [self.navigationItem.rightBarButtonItem setEnabled:[self validateAccountSettings]];
}

- (void) selectCheckMarkOption:(NSInteger) index withCell:(CheckMarkTableViewCell*) cell {
    [cell setSelectedIndex:index];
    [_tempAcctInfo setCmisType:[NSNumber numberWithInteger:index]];
    [_tempAcctInfo setServiceDocumentRequestPath:[CMISUtility defaultCmisDocumentServicePathWithType:index]];
    
    TextFieldTableViewCell *cellServiceDoc = (TextFieldTableViewCell*)[self findeCellByModeIdentifier:kServerServiceDocumentRequestPath];
    [cellServiceDoc.textField setText:[_tempAcctInfo serviceDocumentRequestPath]];
    [self.navigationItem.rightBarButtonItem setEnabled:[self validateAccountSettings]];
}
@end
