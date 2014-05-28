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

@end

@implementation RecordViewController
{
    NSArray *searchResults;
}
@synthesize _tableView;
@synthesize runData;
@synthesize triathlonData;
@synthesize swimData;

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
            [tableView setBackgroundColor:[UIColor whiteColor]];
        }
        
        return count;
    }
    
}

//Code implementing delete function
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Remove the row from data model
    [tableView beginUpdates];
    NSManagedObjectContext *context = [self managedObjectContext];
    switch (tableView.tag)
    {
        case 1:
            [context deleteObject:[self.runData objectAtIndex:indexPath.row]];
            [runData removeObjectAtIndex:indexPath.row];
            break;
            
        case 2:
            [context deleteObject:[self.triathlonData objectAtIndex:indexPath.row]];
            [triathlonData removeObjectAtIndex:indexPath.row];
            break;
        case 3:
            [context deleteObject:[self.swimData objectAtIndex:indexPath.row]];
            [swimData removeObjectAtIndex:indexPath.row];
            break;
        default:
            break;
    }
    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [tableView reloadData];
    [tableView endUpdates];
    
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
@end
