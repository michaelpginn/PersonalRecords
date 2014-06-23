//
//  HistoryTableViewController.m
//  PR: Personal Record Keeper
//
//  Created by Michael Ginn on 6/19/14.
//  Copyright (c) 2014 Michael Ginn. All rights reserved.
//

#import "HistoryTableViewController.h"

@interface HistoryTableViewController ()

@end

@implementation HistoryTableViewController
@synthesize recordName;
@synthesize bgimage;
@synthesize _tableView;
- (NSManagedObjectContext *)managedObjectContext
{
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

- (NSArray *)historyFetch
{
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Previous" inManagedObjectContext:context];
    [request setEntity:entity];
    // retrive the objects with a given value for a certain property
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"name == %@", self.recordName];
    [request setPredicate:predicate];
    NSError *error = nil;
    NSArray *historyArray = [context executeFetchRequest:request error:&error];
    NSSortDescriptor *valueDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
    NSArray *descriptors = [NSArray arrayWithObject:valueDescriptor];
    NSArray *sortedArray = [historyArray sortedArrayUsingDescriptors:descriptors];
    return sortedArray;
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
    bgimage = [bgimage applyDarkEffect];
    UIImageView *blurImageView = [[UIImageView alloc] initWithImage:bgimage];
    [self.view insertSubview:blurImageView belowSubview:self._tableView];
    [_tableView setBackgroundColor:[UIColor clearColor]];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.title = [NSString stringWithFormat:@"%@ History", self.recordName];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //fetch related history
    NSArray *result = [self historyFetch];
    return [result count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //fetch related history
    NSArray *result = [self historyFetch];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"historyCell"];
    
    NSManagedObject *record = result[indexPath.row];
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"historyCell"];
    }
    UIImageView *runImageView = (UIImageView *)[cell viewWithTag:100];
    runImageView.image = [UIImage imageWithData:[record valueForKey:@"image"]];
    
    UILabel *runNameLabel = (UILabel *)[cell viewWithTag:101];
    NSString *dateString = [NSDateFormatter localizedStringFromDate:[record valueForKey:@"date"]
                                                          dateStyle:NSDateFormatterShortStyle
                                                          timeStyle:NSDateFormatterNoStyle];
    runNameLabel.text = dateString;
    
    UILabel *runDetailLabel = (UILabel *)[cell viewWithTag:102];
    runDetailLabel.text = [record valueForKey:@"time"];

    cell.backgroundColor = [UIColor colorWithRed:255.0 green:255.0 blue:255.0 alpha:.4];
    return cell;
}

- (IBAction)clearHistory:(id)sender{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Clear History"
                                                    message:@"Really delete all previous records for this length?"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Yes, delete", nil];
    [alert show];

}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // This method is invoked in response to the user's action. The altert view is about to disappear (or has been disappeard already - I am not sure)
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"Cancel"])
    {
        //do nothing
    }
    else if([title isEqualToString:@"Yes, delete"])
    {
        [_tableView beginUpdates];
        NSManagedObjectContext *context = [self managedObjectContext];
        // Remove the row from data model, after deleting all with the same name
        NSArray *result = [self historyFetch];
        for (NSManagedObject *oldRecord in result){
            NSInteger i = [result indexOfObject:oldRecord];
            [context deleteObject:oldRecord];
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            [_tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
        [_tableView reloadData];
        [_tableView endUpdates];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObjectContext *context = [self managedObjectContext];
    NSArray *result = [self historyFetch];
    [context deleteObject:result[indexPath.row]];
    [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];

}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([[segue identifier] isEqualToString:@"viewHistoryDetail"]){
        RecordDetailViewController *destViewController = segue.destinationViewController;
        NSArray *result = [self historyFetch];
        NSIndexPath *indexPath = [self._tableView indexPathForSelectedRow];
        destViewController.record = result[indexPath.row];
    }
}
@end
