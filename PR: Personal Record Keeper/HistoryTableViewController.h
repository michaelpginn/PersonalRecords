//
//  HistoryTableViewController.h
//  PR: Personal Record Keeper
//
//  Created by Michael Ginn on 6/19/14.
//  Copyright (c) 2014 Michael Ginn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImage+ImageEffects.h"
#import "RecordDetailViewController.h"

@interface HistoryTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property NSString *recordName;
@property UIImage *bgimage;
@property IBOutlet UITableView*_tableView;

- (IBAction)clearHistory:(id)sender;
@end
