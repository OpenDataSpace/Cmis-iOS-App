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

@interface AccountViewController ()
@property (nonatomic, strong) NSMutableArray *fieldArray;
@end

@implementation AccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIBarButtonItem *cancelBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(processCancelButtonAction:)];
    [self.navigationItem setLeftBarButtonItem:cancelBarItem];
    
    UIBarButtonItem *saveBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(processSaveButtonAction:)];
    [saveBarItem setEnabled:NO];
    [self.navigationItem setRightBarButtonItem:saveBarItem];
    
    if (self.isNew) {
        //new a account
        self.acctInfo = [[AccountInfo alloc] init];
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
            [checkMarkController setSelectedIndex:[[self.acctInfo cmisType] integerValue]];
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
    if ([self.acctInfo username] != nil && [[self.acctInfo username] length] > 0) {
        [cellUser.textField setText:[self.acctInfo username]];
    }
    [cellUser setModelIdentifier:kServerUsername];
    [cellUser.textField setDelegate:self];
    [cellUser.textField addTarget:self action:@selector(updateValue:) forControlEvents:UIControlEventEditingChanged];
    [cellUser.textField setReturnKeyType:UIReturnKeyNext];
    [self.fieldArray addObject:cellUser.textField];
    
    TextFieldTableViewCell *cellPassword = (TextFieldTableViewCell*)[self createTableViewCellFromNib:@"TextFieldTableViewCell"];
    [cellPassword.lblTitle setText:NSLocalizedString(@"accountdetails.fields.password", @"Password")];
    [cellPassword.textField setSecureTextEntry:YES];
    [cellPassword.textField setPlaceholder:NSLocalizedString(@"accountdetails.placeholder.optional", @"optional")];
    if ([self.acctInfo password] != nil && [[self.acctInfo password] length] > 0) {
        [cellPassword.textField setText:[self.acctInfo password]];
    }
    [cellPassword setModelIdentifier:kServerPassword];
    [cellPassword.textField setDelegate:self];
    [cellPassword.textField addTarget:self action:@selector(updateValue:) forControlEvents:UIControlEventEditingChanged];
    [cellPassword.textField setReturnKeyType:UIReturnKeyNext];
    [self.fieldArray addObject:cellPassword.textField];
    
    TextFieldTableViewCell *cellServer = (TextFieldTableViewCell*)[self createTableViewCellFromNib:@"TextFieldTableViewCell"];
    [cellServer.lblTitle setText:NSLocalizedString(@"accountdetails.fields.hostname", @"Server Address")];
    [cellServer.textField setPlaceholder:NSLocalizedString(@"accountdetails.placeholder.required", @"required")];
    if ([self.acctInfo hostname] != nil && [[self.acctInfo hostname] length] > 0) {
        [cellServer.textField setText:[self.acctInfo hostname]];
    }
    [cellServer setModelIdentifier:kServerHostName];
    [cellServer.textField setDelegate:self];
    [cellServer.textField addTarget:self action:@selector(updateValue:) forControlEvents:UIControlEventEditingChanged];
    [cellServer.textField setReturnKeyType:UIReturnKeyNext];
    [self.fieldArray addObject:cellServer.textField];
    
    TextFieldTableViewCell *cellDesc = (TextFieldTableViewCell*)[self createTableViewCellFromNib:@"TextFieldTableViewCell"];
    [cellDesc.lblTitle setText:NSLocalizedString(@"accountdetails.fields.description", @"Description")];
    [cellDesc.textField setPlaceholder:NSLocalizedString(@"accountdetails.placeholder.serverdescription", @"CMIS Provider")];
    if ([self.acctInfo vendor] != nil && [[self.acctInfo vendor] length] > 0) {
        [cellDesc.textField setText:[self.acctInfo vendor]];
    }
    [cellDesc setModelIdentifier:kServerVendor];
    [cellDesc.textField setDelegate:self];
    [cellDesc.textField addTarget:self action:@selector(updateValue:) forControlEvents:UIControlEventEditingChanged];
    [cellDesc.textField setReturnKeyType:UIReturnKeyNext];
    [self.fieldArray addObject:cellDesc.textField];
    
    UISwitchTableViewCell *cellProtocol = (UISwitchTableViewCell*)[self createTableViewCellFromNib:@"UISwitchTableViewCell"];
    [cellProtocol.labelTitle setText:NSLocalizedString(@"accountdetails.fields.protocol", @"HTTPS")];
    [cellProtocol.switchButton setOn:[self.acctInfo.protocol isEqualToCaseInsensitiveString:kFDHTTPS_Protocol]];
    [cellProtocol.switchButton addTarget:self action:@selector(processSwitchButtonAction:) forControlEvents:UIControlEventValueChanged];
    [cellProtocol setModelIdentifier:kServerProtocol];
    [self.tableSections addObject:[NSArray arrayWithObjects:cellUser, cellPassword, cellServer, cellDesc, cellProtocol, nil]];
    
    //advanced
    [self.tableHeaders addObject:NSLocalizedString(@"accountdetails.header.advanced", @"Advanced")];
    
    TextFieldTableViewCell *cellPort = (TextFieldTableViewCell*)[self createTableViewCellFromNib:@"TextFieldTableViewCell"];
    [cellPort.lblTitle setText:NSLocalizedString(@"accountdetails.fields.port", @"Port")];
    [cellPort.textField setPlaceholder:NSLocalizedString(@"accountdetails.placeholder.required", @"required")];
    [cellPort.textField setText:[self.acctInfo port]];
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
    [cellCmisProtocol setSelectedIndex:[[self.acctInfo cmisType] integerValue]];
    
    TextFieldTableViewCell *cellServiceDoc = (TextFieldTableViewCell*)[self createTableViewCellFromNib:@"TextFieldTableViewCell"];
    [cellServiceDoc.lblTitle setText:NSLocalizedString(@"accountdetails.fields.servicedoc", @"Service Document")];
    [cellServiceDoc.textField setPlaceholder:NSLocalizedString(@"accountdetails.placeholder.required", @"required")];
    [cellServiceDoc.textField setText:[self.acctInfo serviceDocumentRequestPath]];
    [cellServiceDoc setModelIdentifier:kServerServiceDocumentRequestPath];
    [cellServiceDoc.textField setDelegate:self];
    [cellServiceDoc.textField addTarget:self action:@selector(updateValue:) forControlEvents:UIControlEventEditingChanged];
    [cellServiceDoc.textField setReturnKeyType:UIReturnKeyDone];
    [self.fieldArray addObject:cellServiceDoc.textField];
    
    [self.tableSections addObject:[NSArray arrayWithObjects:cellPort, cellCmisProtocol, cellServiceDoc, nil]];
    
}

- (BOOL) validateAccountSettings {
    BOOL usernameValid = YES;
    BOOL serverValid = YES;
    BOOL portValid = YES;
    BOOL serviceDocValid = YES;
    BOOL vendorValid = YES;
    
    
    NSString *username = [self.acctInfo username];
    NSString *hostname = [self.acctInfo hostname];
    NSString *port = [self.acctInfo port];
    NSString *serviceDoc = [self.acctInfo serviceDocumentRequestPath];
    NSString *vendor = [self.acctInfo vendor];
    
    NSRange hostnameRange = [hostname rangeOfString:@"^[a-zA-Z0-9_\\-\\.]+$" options:NSRegularExpressionSearch];
    usernameValid = ![username isNotEmpty];
    serverValid = ( !hostname || (hostnameRange.location == NSNotFound) );
    portValid = ([port rangeOfString:@"^[0-9]*$" options:NSRegularExpressionSearch].location == NSNotFound);
    serviceDocValid = ![serviceDoc isNotEmpty];
    vendorValid = ![vendor isNotEmpty];
    
    return !usernameValid && !portValid && !serverValid && !serviceDocValid && !vendorValid;
}

- (void) saveTextFieldValue:(TextFieldTableViewCell*) cell {
    if ([[cell modelIdentifier] isEqualToCaseInsensitiveString:kServerUsername]) {
        [self.acctInfo setUsername:[cell.textField text]];
    }else if ([[cell modelIdentifier] isEqualToCaseInsensitiveString:kServerPassword]) {
        [self.acctInfo setPassword:[cell.textField text]];
    }else if ([[cell modelIdentifier] isEqualToCaseInsensitiveString:kServerHostName]) {
        [self.acctInfo setHostname:[cell.textField text]];
    }else if ([[cell modelIdentifier] isEqualToCaseInsensitiveString:kServerPort]) {
        [self.acctInfo setPort:[cell.textField text]];
    }else if ([[cell modelIdentifier] isEqualToCaseInsensitiveString:kServerServiceDocumentRequestPath]) {
        [self.acctInfo setServiceDocumentRequestPath:[cell.textField text]];
    }else if ([[cell modelIdentifier] isEqualToCaseInsensitiveString:kServerVendor]) {
        [self.acctInfo setVendor:[cell.textField text]];
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

- (void) processSaveButtonAction:(id) sender {
    //try to connect server
    __block CMISSessionParameters *params = getSessionParametersWithAccountInfo(self.acctInfo, nil);
    [self startHUD];
    [CMISSession arrayOfRepositories:params completionBlock:^(NSArray *repos, NSError *error){
        [self stopHUD];
        if (error != nil) {
            ODSLogError(@"%@", error);
        }else {
            [[AccountManager sharedManager] saveAccountInfo:self.acctInfo];
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
    
    [self.acctInfo setProtocol:[switchButton isOn]?kFDHTTPS_Protocol:kFDHTTP_Protocol];
    [self.acctInfo setPort:[switchButton isOn]?kFDHTTPS_DefaultPort:kFDHTTP_DefaultPort];
    TextFieldTableViewCell *cellPort = (TextFieldTableViewCell*)[self findeCellByModeIdentifier:kServerPort];
    [cellPort.textField setText:[self.acctInfo port]];
}

- (void) selectCheckMarkOption:(NSInteger) index withCell:(CheckMarkTableViewCell*) cell {
    [cell setSelectedIndex:index];
    [self.acctInfo setCmisType:[NSNumber numberWithInteger:index]];
    [self.acctInfo setServiceDocumentRequestPath:[CMISUtility defaultCmisDocumentServicePathWithType:index]];
    
    TextFieldTableViewCell *cellServiceDoc = (TextFieldTableViewCell*)[self findeCellByModeIdentifier:kServerServiceDocumentRequestPath];
    [cellServiceDoc.textField setText:[self.acctInfo serviceDocumentRequestPath]];
}
@end
