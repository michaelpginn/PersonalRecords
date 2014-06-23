//
//  AboutViewController.m
//  PR: Personal Record Keeper
//
//  Created by Michael Ginn on 5/28/14.
//  Copyright (c) 2014 Michael Ginn. All rights reserved.
//

#import "AboutViewController.h"

@interface AboutViewController ()

@end

@implementation AboutViewController
@synthesize bgimage;
@synthesize versionLabel;
@synthesize nameLabel;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    bgimage = [bgimage applyDarkEffect];
    UIImageView *blurImageView = [[UIImageView alloc] initWithImage:bgimage];
    [self.view insertSubview:blurImageView atIndex:0];

    // Do any additional setup after loading the view.
    NSString * appVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    appVersionString = [@"v" stringByAppendingString:appVersionString];
    versionLabel.text = appVersionString;
    versionLabel.textColor = [UIColor whiteColor];
    nameLabel.textColor = [UIColor whiteColor];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)featureRequest:(id)sender {
    MFMailComposeViewController *emailController = [[MFMailComposeViewController alloc] init];
    emailController.mailComposeDelegate = self;
    [emailController setSubject:@"PR Feature Request"];
    [emailController setToRecipients:@[@"pr@quaritate.com"]];
    [emailController.navigationBar setTintColor:[UIColor whiteColor]];
    [self presentViewController:emailController animated:YES completion:nil];
}

- (IBAction)support:(id)sender {
    MFMailComposeViewController *emailController = [[MFMailComposeViewController alloc] init];
    emailController.mailComposeDelegate = self;
    [emailController setSubject:@"PR Support"];
    [emailController setToRecipients:@[@"pr@quaritate.com"]];
    [emailController.navigationBar setTintColor:[UIColor whiteColor]];
    [self presentViewController:emailController animated:YES completion:nil];
}

- (IBAction)shareByEmail:(id)sender{
    MFMailComposeViewController *emailController = [[MFMailComposeViewController alloc] init];
    emailController.mailComposeDelegate = self;
    [emailController setSubject:@"PR"];
    [emailController.navigationBar setTintColor:[UIColor whiteColor]];
    [self presentViewController:emailController animated:YES completion:nil];
}
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
	[self becomeFirstResponder];
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)done:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)rate:(id)sender{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        // The device is an iPad running iOS 3.2 or later.
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/us/app/pr-personal-record-keeper/id887571707?mt=8&uo=4"]];
    }
    else
    {
        // The device is an iPhone or iPod touch.
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/us/app/pr-personal-record-keeper/id887571707?mt=8&uo=4"]];
    }
}
@end
