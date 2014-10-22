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
 *
 * ***** END LICENSE BLOCK ***** */
//
//  DownloadFailureTableViewCell.h
//

#import <UIKit/UIKit.h>
@class DownloadInfo;

@interface DownloadFailureTableViewCell : UITableViewCell

@property (nonatomic, retain) DownloadInfo *downloadInfo;

- (id)initWithIdentifier:(NSString *)reuseIdentifier;

@end

extern NSString * const kDownloadFailureCellIdentifier;
