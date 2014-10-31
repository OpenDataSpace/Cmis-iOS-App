//
//  DateInputTableViewCell.m
//  ODS
//
//  Created by bdt on 10/28/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import "DateInputTableViewCell.h"

@implementation DateInputTableViewCell
@synthesize dateValue;
@synthesize dateFormatter;
@synthesize datePicker;
@synthesize delegate = _delegate;

- (void)initalizeInputView {
    dateValue = [NSDate date];
    
    // Initialization code
    self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
    [datePicker setDatePickerMode:UIDatePickerModeDate];
    datePicker.date = self.dateValue;
    [datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
    
    if (IS_IPAD) {
        UIViewController *popoverContent = [[UIViewController alloc] init];
        popoverContent.view = self.datePicker;
        popoverController = [[UIPopoverController alloc] initWithContentViewController:popoverContent];
        popoverController.delegate = self;
    } else {
        CGRect frame = self.inputView.frame;
        frame.size = [self.datePicker sizeThatFits:CGSizeZero];
        self.inputView.frame = frame;
        self.datePicker.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    }
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.timeStyle = NSDateFormatterNoStyle;
    self.dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    
    self.detailTextLabel.text = [self.dateFormatter stringFromDate:self.dateValue];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self initalizeInputView];
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initalizeInputView];
    }
    return self;
}

- (UIView *)inputView {
    if (IS_IPAD) {
        return nil;
    } else {
        return self.datePicker;
    }
}

- (UIView *)inputAccessoryView {
    if (IS_IPAD) {
        return nil;
    } else {
        if (!inputAccessoryView) {
            inputAccessoryView = [[UIToolbar alloc] init];
            inputAccessoryView.barStyle = UIBarStyleBlackTranslucent;
            inputAccessoryView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
            [inputAccessoryView sizeToFit];
            CGRect frame = inputAccessoryView.frame;
            frame.size.height = 44.0f;
            inputAccessoryView.frame = frame;
            
            UIBarButtonItem *doneBtn =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
            UIBarButtonItem *flexibleSpaceLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
            
            NSArray *array = [NSArray arrayWithObjects:flexibleSpaceLeft, doneBtn, nil];
            [inputAccessoryView setItems:array];
        }
        return inputAccessoryView;
    }
}

- (void)done:(id)sender {
    [self resignFirstResponder];
    [self dateUpdated:self.dateValue];
}

- (BOOL)becomeFirstResponder {
    if (IS_IPAD) {
        CGSize pickerSize = [self.datePicker sizeThatFits:CGSizeZero];
        CGRect frame = self.datePicker.frame;
        frame.size = pickerSize;
        self.datePicker.frame = frame;
        popoverController.popoverContentSize = pickerSize;
        [popoverController presentPopoverFromRect:self.detailTextLabel.frame inView:self permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceDidRotate:) name:UIDeviceOrientationDidChangeNotification object:nil];
    } else {
        // Nothing to do
    }
    return [super becomeFirstResponder];
}

- (BOOL)resignFirstResponder {
    if (IS_IPAD) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    } else {
        // Nothing to do
    }
    UITableView *tableView = (UITableView *) self.superview;
    if (![tableView isKindOfClass:[UITableView class]]) {  //add this fixed for ios7
        tableView = (UITableView *) tableView.superview;
    }
    [tableView deselectRowAtIndexPath:[tableView indexPathForCell:self] animated:YES];
    return [super resignFirstResponder];
}

- (void)prepareForReuse {
    self.dateFormatter.timeStyle = NSDateFormatterNoStyle;
    self.dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    self.datePicker.maximumDate = nil;
    self.datePicker.minimumDate = nil;
}

- (void)setDateValue:(NSDate *)value {
    dateValue = value;
    self.detailTextLabel.text = [self.dateFormatter stringFromDate:self.dateValue];
    [self dateUpdated:self.dateValue];
}

- (void)setDatePickerMode:(UIDatePickerMode)mode {
    self.datePicker.datePickerMode = mode;
    self.dateFormatter.dateStyle = (mode==UIDatePickerModeDate||mode==UIDatePickerModeDateAndTime)?NSDateFormatterMediumStyle:NSDateFormatterNoStyle;
    self.dateFormatter.timeStyle = (mode==UIDatePickerModeTime||mode==UIDatePickerModeDateAndTime)?NSDateFormatterShortStyle:NSDateFormatterNoStyle;
    self.detailTextLabel.text = [self.dateFormatter stringFromDate:self.dateValue];
}

- (UIDatePickerMode)datePickerMode {
    return self.datePicker.datePickerMode;
}

- (void)setMaxDate:(NSDate *)max {
    self.datePicker.maximumDate = max;
}

- (void)setMinDate:(NSDate *)min {
    self.datePicker.minimumDate = min;
}

- (void)dateChanged:(id)sender {
    self.dateValue = ((UIDatePicker *)sender).date;
    [self dateUpdated:self.dateValue];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
    if (selected) {
        [self becomeFirstResponder];
    }
}

- (void)deviceDidRotate:(NSNotification*)notification {
    if (IS_IPAD) {
        // we should only get this call if the popover is visible
        [popoverController presentPopoverFromRect:self.detailTextLabel.frame inView:self permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}

#pragma mark -
#pragma mark Respond to touch and become first responder.

- (BOOL)canBecomeFirstResponder {
    return YES;
}

#pragma mark -
#pragma mark UIPopoverControllerDelegate Protocol Methods

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    if (IS_IPAD) {
        UITableView *tableView = (UITableView *) self.superview;
        if (![tableView isKindOfClass:[UITableView class]]) {  //add this fixed for ios7
            tableView = (UITableView *) tableView.superview;
        }
        [tableView deselectRowAtIndexPath:[tableView indexPathForCell:self] animated:YES];
        [self resignFirstResponder];
    }
}

- (void) dateUpdated:(NSDate*) date {
    if (_delegate) {
        [_delegate dateValueChanged:date];
    }
}
@end
