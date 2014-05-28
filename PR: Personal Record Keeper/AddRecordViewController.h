//
//  AddRecordViewController.h
//  PR: Personal Record Keeper
//
//  Created by Michael Ginn on 4/20/14.
//  Copyright (c) 2014 Michael Ginn. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "QRTAppDelegate.h"
#import "UIImage+ImageEffects.h"


@interface AddRecordViewController : UIViewController <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate,UIPickerViewDataSource, UIPickerViewDelegate,UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UISegmentedControl *activitySegment;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *timeTextField;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UITextField *locationTextField;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextField *customNameTextField;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;

@property (nonatomic, strong) NSString *sentActivity;
@property (nonatomic, strong)NSManagedObject *record;
@property (nonatomic, strong)UIImage *bgimage;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;

@property (strong, nonatomic) NSArray* runLengths;
@property (strong, nonatomic) NSArray* swimLengths;
@property (strong, nonatomic) NSArray * triathlonLengths;
- (IBAction)segmentChanged:(id)sender;

@end
