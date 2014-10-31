//
//  DateInputTableViewCell.h
//  ODS
//
//  Created by bdt on 10/28/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import "CustomTableViewCell.h"

@protocol DateInputDelegate <NSObject>

@optional
- (void) dateValueChanged:(NSDate*) date;
@end

@interface DateInputTableViewCell : CustomTableViewCell <UIPopoverControllerDelegate> {
    UIPopoverController *popoverController;
    UIToolbar *inputAccessoryView;
}

@property (nonatomic, strong) NSDate *dateValue;
@property (nonatomic, assign) UIDatePickerMode datePickerMode;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) UIDatePicker *datePicker;

@property (nonatomic, assign) id <DateInputDelegate> delegate;

- (void)setMaxDate:(NSDate *)max;
- (void)setMinDate:(NSDate *)min;

@end
