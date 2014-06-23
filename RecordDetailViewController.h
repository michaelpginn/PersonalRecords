//
//  RecordDetailViewController.h
//  PR: Personal Record Keeper
//
//  Created by Michael Ginn on 4/19/14.
//  Copyright (c) 2014 Michael Ginn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddRecordViewController.h"
#import "HistoryTableViewController.h"
#import <MessageUI/MessageUI.h>
#import "Util.h"

@interface RecordDetailViewController : UIViewController <MFMailComposeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *recordPhoto;
@property (weak, nonatomic) IBOutlet UILabel *recordTime;
@property (weak, nonatomic) IBOutlet UILabel *recordLocation;
@property (weak, nonatomic) IBOutlet UILabel *recordDate;
- (IBAction)showWorldRecord:(id)sender;
@property (weak,nonatomic) IBOutlet UILabel *worldRecord;

@property (nonatomic, strong) NSManagedObject *record;
@property (strong, nonatomic) NSArray* runLengths;
@property (strong, nonatomic) NSArray* swimLengths;
@property (strong, nonatomic) NSArray* triathlonLengths;
@property (strong, nonatomic) NSMutableArray* runKeys;
@property (strong, nonatomic) NSMutableArray* swimKeys;
@property (strong, nonatomic) NSMutableArray* triathlonKeys;
@property(nonatomic, retain) IBOutlet UIToolbar *toolBar;
- (IBAction)share:(id)sender;

@end
