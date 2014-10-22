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
//  NSURL+HTTPURLUtils.m
//

#import "NSURL+HTTPURLUtils.h"
#import "NSDictionary+URLEncoding.h"

@implementation NSURL (HTTPURLUtils)

- (NSURL *)URLByAppendingParameterString:(NSString *)otherParameterString
{
	ODSLogTrace(@"NSURL absoluteString: %@", self.absoluteString);
	ODSLogTrace(@"NSURL parameterString: %@", self.parameterString);
	
	if (otherParameterString)
    {
		NSString *urlString = ( (self.parameterString || self.query)
							    ? [self.absoluteString stringByAppendingFormat:@"&%@", otherParameterString]
							    : [self.absoluteString stringByAppendingFormat:@"?%@", otherParameterString] );
		return [NSURL URLWithString:urlString];
	}
    return self;
}

- (NSURL *)URLByAppendingParameterDictionary:(NSDictionary *)parameterdictionary
{
	return [self URLByAppendingParameterString:[parameterdictionary urlEncodedParameterString]];
}

- (NSDictionary *)queryPairs
{
    NSString *q = [self query];
    NSArray *qpa = [q componentsSeparatedByString:@"&"];
    NSMutableDictionary *qp = [NSMutableDictionary dictionary];
    for (NSString *p in qpa)
    {
        NSArray *b = [p componentsSeparatedByString:@"="];
        if (0 == [b count]) continue;
        NSString *k = (NSString *)[b objectAtIndex:0];
        k = [k stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *v = @"";
        if ([b count] > 1)
        {
            v = (NSString *)[b objectAtIndex:1];
            v = [v stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        }
        
        [qp setObject:v forKey:k];
    }

    return qp;
}

@end
