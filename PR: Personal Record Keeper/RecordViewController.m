//
//  RecordViewController.m
//  PR: Personal Record Keeper
//
//  Created by Michael Ginn on 4/19/14.
//  Copyright (c) 2014 Michael Ginn. All rights reserved.
//

#import "RecordViewController.h"


@interface RecordViewController ()

@property (strong) NSMutableArray *runData;
@property (strong) NSMutableArray *triathlonData;
@property (strong) NSMutableArray *swimData;
@property (strong, nonatomic) UILabel *noRecords;
@property (strong, nonatomic) NSIndexPath *indexPathToBeDeleted;
@end

@implementation RecordViewController
{
    NSArray *searchResults;
}
@synthesize _tableView;
@synthesize runData;
@synthesize triathlonData;
@synthesize swimData;
@synthesize noRecords;
@synthesize indexPathToBeDeleted;

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
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"name == %@", [[self.runData objectAtIndex:indexPathToBeDeleted.row]valueForKey:@"name"]];
    [request setPredicate:predicate];
    //now put those in an array
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
    noRecords = [[UILabel alloc] initWithFrame:CGRectMake(0,0,300,25)] ;
    [self._tableView addSubview:noRecords];
    [noRecords setCenter:CGPointMake(_tableView.center.x, _tableView.center.y)];
    noRecords.textAlignment = NSTextAlignmentCenter;
    noRecords.text= @"No records in this category.";
    noRecords.font = [noRecords.font fontWithSize:20];
    [noRecords setAlpha:0.5];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Fetch the devices from persistent data store
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    
    NSFetchRequest *fetchRunRequest = [[NSFetchRequest alloc] initWithEntityName:@"Run"];
    self.runData = [[managedObjectContext executeFetchRequest:fetchRunRequest error:nil] mutableCopy];
    NSFetchRequest *fetchtriathlonRequest = [[NSFetchRequest alloc] initWithEntityName:@"Triathlon"];
    self.triathlonData = [[managedObjectContext executeFetchRequest:fetchtriathlonRequest error:nil] mutableCopy];
    NSFetchRequest *fetchSwimRequest = [[NSFetchRequest alloc] initWithEntityName:@"Swim"];
    self.swimData = [[managedObjectContext executeFetchRequest:fetchSwimRequest error:nil] mutableCopy];
    
    
    [self._tableView reloadData];
    }

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//number of rows
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [searchResults count];
        
    } else {
        NSUInteger count = 0;
        switch (tableView.tag)
        {
            case 1:
                
                count = [runData count];
                break;
                
            case 2:
                count = [triathlonData count];
                break;
            case 3:
                count = [swimData count];
                break;
            default:
                break;
        }
        if (count == 0){
            [_tableView setBackgroundColor:[UIColor whiteColor]];
            [noRecords setHidden:NO];
        } else{
            [noRecords setHidden:YES];
        }
        
        return count;
    }
    
}

//Code implementing delete function
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.indexPathToBeDeleted = indexPath;
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete"
                                                    message:@"Delete all records for this length?"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Delete all records for this length",@"Delete this record", nil];
    [alert show];
    // do not delete it here. So far the alter has not even been shown yet. It will not been shown to the user before this current method is finished.
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // This method is invoked in response to the user's action. The altert view is about to disappear (or has been disappeard already - I am not sure)
    
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"Cancel"])
    {
        //do nothing
    }
    else if([title isEqualToString:@"Delete this record"])
    {
        // Remove the row from data model
        [_tableView beginUpdates];
        NSManagedObjectContext *context = [self managedObjectContext];
        if ([[self historyFetch] count] == 0) {
            switch (_tableView.tag)
            {
                case 1:
                    [context deleteObject:[self.runData objectAtIndex:indexPathToBeDeleted.row]];
                    [runData removeObjectAtIndex:indexPathToBeDeleted.row];
                    break;
                    
                case 2:
                    [context deleteObject:[self.triathlonData objectAtIndex:indexPathToBeDeleted.row]];
                    [triathlonData removeObjectAtIndex:indexPathToBeDeleted.row];
                    break;
                case 3:
                    [context deleteObject:[self.swimData objectAtIndex:indexPathToBeDeleted.row]];
                    [swimData removeObjectAtIndex:indexPathToBeDeleted.row];
                    break;
                default:
                    break;
            }
            [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPathToBeDeleted] withRowAnimation:UITableViewRowAnimationFade];

        } else{
            NSManagedObject *newRecord;
            NSManagedObject *oldRecord = [self historyFetch][0];
            switch (_tableView.tag){
                case 1:
                    newRecord = [self.runData objectAtIndex:indexPathToBeDeleted.row];
                    break;
                case 2:
                    newRecord = [self.triathlonData objectAtIndex:indexPathToBeDeleted.row];
                    break;
                case 3:
                    newRecord = [self.swimData objectAtIndex:indexPathToBeDeleted.row];
                    break;
                default:
                    break;
            }
            [newRecord setValue:[oldRecord valueForKey:@"name"] forKey:@"name"];
            [newRecord setValue:[oldRecord valueForKey:@"time"] forKey:@"time"];
            [newRecord setValue:[oldRecord valueForKey:@"date"] forKey:@"date"];
            [newRecord setValue:[oldRecord valueForKey:@"location"] forKey:@"location"];
            [newRecord setValue:[oldRecord valueForKey:@"image"] forKey:@"image"];
            [context deleteObject:oldRecord];
        }
        [_tableView reloadData];
        [_tableView endUpdates];
        NSError * error = nil;
        [self.managedObjectContext save:&error];
    }
    else if([title isEqualToString:@"Delete all records for this length"])
    {
         NSManagedObjectContext *context = [self managedObjectContext];
        // Remove the row from data model, after deleting all with the same name
        NSArray *result = [self historyFetch];
        for (NSManagedObject *oldRecord in result){
            [context deleteObject:oldRecord];
        }

        [_tableView beginUpdates];
        switch (_tableView.tag)
        {
            case 1:
                [context deleteObject:[self.runData objectAtIndex:indexPathToBeDeleted.row]];
                [runData removeObjectAtIndex:indexPathToBeDeleted.row];
                break;
                
            case 2:
                [context deleteObject:[self.triathlonData objectAtIndex:indexPathToBeDeleted.row]];
                [triathlonData removeObjectAtIndex:indexPathToBeDeleted.row];
                break;
            case 3:
                [context deleteObject:[self.swimData objectAtIndex:indexPathToBeDeleted.row]];
                [swimData removeObjectAtIndex:indexPathToBeDeleted.row];
                break;
            default:
                break;
        }
        [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPathToBeDeleted] withRowAnimation:UITableViewRowAnimationFade];
        [_tableView reloadData];
        [_tableView endUpdates];
        NSError *error = nil;
        [self.managedObjectContext save:&error];

    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIndentifier;
    
    switch (tableView.tag)
    {
        case 1:
            cellIndentifier = @"runCell";
            break;
            
        case 2:
            cellIndentifier = @"triathlonCell";
            break;
        case 3:
            cellIndentifier = @"swimCell";
            break;
        default:
            break;
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier];
    }
    UIImage *background = [self cellBackgroundForRowAtIndexPath:indexPath];
    
    UIImageView *cellBackgroundView = [[UIImageView alloc] initWithImage:background];
    cellBackgroundView.image = background;
    cell.backgroundView = cellBackgroundView;

    // Display recipe in the table cell
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        cell.textLabel.text = [[searchResults objectAtIndex:indexPath.row] name];
    } else {
        switch (tableView.tag)
        {
            case 1:{
                NSManagedObject *record = [runData objectAtIndex:indexPath.row];
                UIImageView *runImageView = (UIImageView *)[cell viewWithTag:100];
                runImageView.image = [UIImage imageWithData:[record valueForKey:@"image"]];
                
                UILabel *runNameLabel = (UILabel *)[cell viewWithTag:101];
                runNameLabel.text = [record valueForKey:@"name"];
                
                UILabel *runDetailLabel = (UILabel *)[cell viewWithTag:102];
                runDetailLabel.text = [record valueForKey:@"time"];
                
                break;
            }
                
            case 2:{
                NSManagedObject *record = [triathlonData objectAtIndex:indexPath.row];
                UIImageView *triathlonImageView = (UIImageView *)[cell viewWithTag:103];
                triathlonImageView.image = [UIImage imageWithData:[record valueForKey:@"image"]];
                
                UILabel *triathlonNameLabel = (UILabel *)[cell viewWithTag:104];
                triathlonNameLabel.text = [record valueForKey:@"name"];
                
                UILabel *triathlonDetailLabel = (UILabel *)[cell viewWithTag:105];
                triathlonDetailLabel.text = [record valueForKey:@"time"];
                
                break;
            }
            case 3:{
                NSManagedObject *record = [swimData objectAtIndex:indexPath.row];
                UIImageView *swimImageView = (UIImageView *)[cell viewWithTag:106];
                swimImageView.image = [UIImage imageWithData:[record valueForKey:@"image"]];
                
                UILabel *swimNameLabel = (UILabel *)[cell viewWithTag:107];
                swimNameLabel.text = [record valueForKey:@"name"];
                
                UILabel *swimDetailLabel = (UILabel *)[cell viewWithTag:108];
                swimDetailLabel.text = [record valueForKey:@"time"];
                
                break;
            }
            default:
                break;
        }
    }
    
    
    return cell;
}


//Predicate filter
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"name contains[cd] %@", searchText];
    NSArray *records = [runData arrayByAddingObjectsFromArray:triathlonData];
    records = [records arrayByAddingObjectsFromArray:swimData];
    
    searchResults = [records filteredArrayUsingPredicate:resultPredicate];
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller
shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
    
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        [self performSegueWithIdentifier: @"showRecordDetail" sender: self];
    }
}

- (UIImage *)cellBackgroundForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger rowCount = [self tableView:[self _tableView] numberOfRowsInSection:0];
    NSInteger rowIndex = indexPath.row;
    UIImage *background = nil;
    
    if (rowIndex == 0) {
        background = [UIImage imageNamed:@"oddtopcell.png"];
    } else if (rowIndex % 2) {
        background = [UIImage imageNamed:@"evencell.png"];
    } else if (!(rowIndex % 2)){
        background = [UIImage imageNamed:@"oddcell.png"];
    }
    if (rowCount % 2) {
        UIColor *bgcolor = [UIColor colorWithRed:71/255.0 green:165/255.0 blue:176/255.0 alpha:1.0];
        [_tableView setBackgroundColor:bgcolor];
    } else if(!(rowCount %2)){
        UIColor *bgcolor = [UIColor colorWithRed:46/255.0 green:219/255.0 blue:82/255.0 alpha:1.0];
        [_tableView setBackgroundColor:bgcolor];
    }
    return background;
}


// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showRecordDetail"]) {
        RecordDetailViewController *destViewController = segue.destinationViewController;
        NSIndexPath *indexPath = nil;
        
        if ([self.searchDisplayController isActive]) {
            indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
            destViewController.record = [searchResults objectAtIndex:indexPath.row];
            
        } else {
            indexPath = [self._tableView indexPathForSelectedRow];
            switch (_tableView.tag){
                case 1:
                    destViewController.record = [runData objectAtIndex:indexPath.row];
                    break;
                case 2:
                    destViewController.record = [triathlonData objectAtIndex:indexPath.row];
                    break;
                case 3:
                    destViewController.record = [runData objectAtIndex:indexPath.row];
                    break;
                default:
                    destViewController.record = [runData objectAtIndex:indexPath.row];
                    break;
            }
            
        }
    }
    if ([segue.identifier isEqualToString:@"runAddView"]) {
        AddRecordViewController *destViewController = segue.destinationViewController;
        destViewController.sentActivity = @"Run";
        destViewController.bgimage = [Util captureTotalView:[self.view superview].superview];
        
    }
    
    if ([segue.identifier isEqualToString:@"triathlonAddView"]) {
        AddRecordViewController *destViewController = segue.destinationViewController;
        destViewController.sentActivity = @"Triathlon";
        destViewController.bgimage = [Util captureTotalView:[self.view superview].superview];
    }
    
    if ([segue.identifier isEqualToString:@"swimAddView"]) {
        AddRecordViewController *destViewController = segue.destinationViewController;
        destViewController.sentActivity = @"Swim";
        destViewController.bgimage = [Util captureTotalView:[self.view superview].superview];
    }
    if ([segue.identifier isEqualToString:@"showAbout"]) {
        AboutViewController *destViewController = segue.destinationViewController;
        destViewController.bgimage = [Util captureTotalView:[self.view superview].superview];
    }
}

@end
