//
//  RecordDetailViewController.m
//  PR: Personal Record Keeper
//
//  Created by Michael Ginn on 4/19/14.
//  Copyright (c) 2014 Michael Ginn. All rights reserved.
//

#import "RecordDetailViewController.h"


@interface RecordDetailViewController ()

@end

@implementation RecordDetailViewController

@synthesize recordPhoto;
@synthesize recordTime;
@synthesize recordLocation;
@synthesize recordDate;
@synthesize worldRecord;

@synthesize record;
@synthesize runLengths;
@synthesize swimLengths;
@synthesize triathlonLengths;
@synthesize runKeys;
@synthesize swimKeys;
@synthesize triathlonKeys;
@synthesize worldRecordButton;
@synthesize shareButton;

- (NSManagedObjectContext *)managedObjectContext
{
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}


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
    // Do any additional setup after loading the view.
    if ([MFMailComposeViewController canSendMail])
		shareButton.enabled = YES;
}
- (void)viewDidAppear:(BOOL)animated
{
    
    self.title = [record valueForKey:@"name"];
    self.recordTime.text = [record valueForKey:@"time"];
    self.recordLocation.text = [record valueForKey:@"location"];
    self.recordDate.text = [NSDateFormatter localizedStringFromDate:[record valueForKey:@"date"] dateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterNoStyle];
    self.recordPhoto.image = [UIImage imageWithData:[record valueForKey:@"image"]];
    //get information from plist
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Types" ofType:@"plist"];
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:path];
    NSDictionary *runDict = [dict objectForKey:@"Runs"];
    NSDictionary *swimDict = [dict objectForKey:@"Swims"];
    NSDictionary *triathlonDict = [dict objectForKey:@"Triathlons"];
    //feed dictionaries into arrays
    runLengths = [[runDict allKeys] sortedArrayUsingSelector:@selector(localizedStandardCompare:)];
    swimLengths = [[swimDict allKeys] sortedArrayUsingSelector:@selector(localizedStandardCompare:)];
    triathlonLengths = [[triathlonDict allKeys] sortedArrayUsingSelector:@selector(localizedStandardCompare:)];
    runKeys = [NSMutableArray new];
    swimKeys = [NSMutableArray new];
    triathlonKeys = [NSMutableArray new];
    //make array of parsed keys
    for(int i = 0; i <= runLengths.count-1; i++){
        NSString *s = [runLengths objectAtIndex:i];
        NSString *newStr = [s substringWithRange:NSMakeRange(3, [s length]-3)];
        [runKeys addObject:newStr];
    }
    for(int i = 1; i <= swimLengths.count-1; i++){
        NSString *s = [swimLengths objectAtIndex:i];
        NSString *newStr = [s substringWithRange:NSMakeRange(3, [s length]-3)];
        [swimKeys addObject:newStr];
    }
    for(int i = 1; i <= triathlonLengths.count-1; i++){
        NSString *s = [triathlonLengths objectAtIndex:i];
        NSString *newStr = [s substringWithRange:NSMakeRange(3, [s length]-3)];
        [triathlonKeys addObject:newStr];
    }
    //show world record
    NSString *recordName = [record valueForKey:@"name"];
    if ([runKeys containsObject:recordName]){
        worldRecordButton.hidden = false;
        NSUInteger index;
        index = [runKeys indexOfObject:recordName];
        NSString *runLength = [runLengths objectAtIndex:(index+1)];
        worldRecord.text = [runDict objectForKey:runLength];
    }
    if ([swimKeys containsObject:[record valueForKey:@"name"]]){
        worldRecordButton.hidden = false;
        NSUInteger index;
        index = [swimKeys indexOfObject:recordName];
        NSString *swimLength = [swimLengths objectAtIndex:(index+1)];
        worldRecord.text = [swimDict objectForKey:swimLength];
        
    }
    if ([triathlonKeys containsObject:[record valueForKey:@"name"]]){
        worldRecordButton.hidden = false;
        NSUInteger index;
        index = [triathlonKeys indexOfObject:recordName];
        NSString *triathlonLength = [triathlonLengths objectAtIndex:(index+1)];
        worldRecord.text = [triathlonDict objectForKey:triathlonLength];
        
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation

*/
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"updateRecord"]){
        AddRecordViewController *destViewController = segue.destinationViewController;
        destViewController.record = self.record;
        destViewController.bgimage = [Util captureTotalView:self.view];
        destViewController.sentActivity = [[self.record entity] name];
    }
}
-(IBAction)showWorldRecord:(id)sender{
    if ([worldRecordButton.titleLabel.text  isEqual: @"View World Record"]){
    worldRecord.alpha = 0;
    worldRecord.hidden = false;
    
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseIn
                     animations:^{ worldRecord.alpha = 1;}
                     completion:nil];
    [worldRecordButton setTitle:@"Hide World Record" forState:UIControlStateNormal];
    } else{
        worldRecord.alpha = 1;
        
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseIn
                         animations:^{ worldRecord.alpha = 0;}
                         completion:nil];
        worldRecord.hidden = true;
        [worldRecordButton setTitle:@"View World Record" forState:UIControlStateNormal];
    }
}

-(IBAction)share:(id)sender{
    [shareButton setBackgroundImage:[Util imageWithColor:[UIColor colorWithRed:51/255.0 green:221/255.0 blue:236/255.0 alpha:1.0]] forState:UIControlStateHighlighted];
    MFMailComposeViewController *emailController = [[MFMailComposeViewController alloc] init];
    emailController.mailComposeDelegate = self;
	[emailController setSubject:[NSString stringWithFormat:@"My new %@ record", self.title]];
    NSString *html = [NSString stringWithFormat:@" <h3>My %@:</h3> <p> I got a time of %@ at %@ on %@!</p> <p> Sent from PR: Personal Record Keeper</p> </body> </html>",self.title, self.recordTime.text, self.recordLocation.text, self.recordDate.text];
    NSData *data = UIImagePNGRepresentation(self.recordPhoto.image);
    [emailController addAttachmentData:data mimeType:@"image/png" fileName:@"Record Image"];
	[emailController setMessageBody:html isHTML:YES];
    [[emailController navigationBar] setTintColor:[UIColor whiteColor]];
    
	[self presentViewController:emailController animated:YES completion:nil];
}
-(IBAction)shareHover:(id)sender{
    [shareButton setBackgroundImage:[UIImage imageNamed:@"sharefilled"] forState:UIControlStateHighlighted];
}

- (IBAction)shareOff:(id)sender {
    [shareButton setBackgroundImage:[UIImage imageNamed:@"share"] forState:UIControlStateHighlighted];

}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
	[self becomeFirstResponder];
	[self dismissViewControllerAnimated:YES completion:nil];
}
@end
