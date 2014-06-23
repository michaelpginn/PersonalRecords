//
//  AboutViewController.h
//  PR: Personal Record Keeper
//
//  Created by Michael Ginn on 5/28/14.
//  Copyright (c) 2014 Michael Ginn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImage+ImageEffects.h"
#import <MessageUI/MessageUI.h>


@interface AboutViewController : UIViewController <MFMailComposeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
- (IBAction)featureRequest:(id)sender;
- (IBAction)support:(id)sender;
- (IBAction)shareByEmail:(id)sender;
- (IBAction)done:(id)sender;
- (IBAction)rate:(id)sender;
@property (nonatomic, strong)UIImage *bgimage;
@end
