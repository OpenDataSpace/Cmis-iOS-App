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
//  SavedDocumentPickerController.m
//

#import "SavedDocumentPickerController.h"
#import "SelectDocumentController.h"

@implementation SavedDocumentPickerController
@synthesize multiSelection = _multiSelection;

- (void) dealloc {
    selectDocument = nil;
}

- (id)init
{
    self = [super init];
    
    if(self) {
        selectDocument = [[SelectDocumentController alloc] initWithStyle:UITableViewStylePlain]; 
        [self pushViewController:selectDocument animated:NO];
    }
    
    return self;
}

- (id)initWithMultiSelection:(BOOL)multiSelection 
{
    self = [super init];
    
    if(self) {
        [self setMultiSelection:multiSelection];
        selectDocument = [[SelectDocumentController alloc] initWithStyle:UITableViewStylePlain];
        [selectDocument setMultiSelection:multiSelection];
        [self pushViewController:selectDocument animated:NO];
        
    }
    
    return self;
}

- (void) setDelegate:(id<UINavigationControllerDelegate, SavedDocumentPickerDelegate>)delegate {
    if([delegate conformsToProtocol:@protocol(SavedDocumentPickerDelegate)]) {
        selectDocument.delegate = delegate;
    } else {
        [super setDelegate:delegate];
    }
    
}

- (id) delegate {
    if(selectDocument.delegate) {
        return selectDocument.delegate;
    }
    return [super delegate];
}

@end
