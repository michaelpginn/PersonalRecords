//
//  RecordViewController.h
//  PR: Personal Record Keeper
//
//  Created by Michael Ginn on 4/19/14.
//  Copyright (c) 2014 Michael Ginn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RecordDetailViewController.h"
#import "AddRecordViewController.h"
#import "UIImage+ImageEffects.h"
#import <QuartzCore/QuartzCore.h>
#import "Util.h"
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface RecordViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, strong) IBOutlet UITableView *_tableView;


@end
