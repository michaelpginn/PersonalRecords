//
//  AddRecordViewController.m
//  PR: Personal Record Keeper
//
//  Created by Michael Ginn on 4/20/14.
//  Copyright (c) 2014 Michael Ginn. All rights reserved.
//

#import "AddRecordViewController.h"


@interface AddRecordViewController ()
@property (strong, nonatomic) UIPickerView *pickerView;
@end

@implementation AddRecordViewController
@synthesize nameTextField;
@synthesize timeTextField;
@synthesize datePicker;
@synthesize locationTextField;
@synthesize imageView;
@synthesize activitySegment;
@synthesize scrollView;
@synthesize customNameTextField;

@synthesize sentActivity;
@synthesize runLengths;
@synthesize swimLengths;
@synthesize triathlonLengths;
@synthesize bgimage;
@synthesize sentLength;

@synthesize pickerView;


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
    //blurred background
    bgimage = [bgimage applyDarkEffect];
    UIImageView *blurImageView = [[UIImageView alloc] initWithImage:bgimage];
    [self.view insertSubview:blurImageView belowSubview:self.scrollView];
    [scrollView setBackgroundColor:[UIColor clearColor]];
    //navigation bar style
    [self.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationBar setShadowImage:[UIImage new]];
    [self.navigationBar setTranslucent:YES];
    [self.navigationBar setTintColor:[UIColor whiteColor]];
    //datePicker style
    datePicker.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.3];
    //set activtySegment selected
    int indexNum = 0;
    if ([sentActivity  isEqualToString:@"Run"]){
        indexNum = 0;
    } else if ([sentActivity isEqualToString:@"Triathlon"]) {
        indexNum = 1;
    } else if ([sentActivity isEqualToString:@"Swim"]){
        indexNum = 2;
    }
    [activitySegment setSelectedSegmentIndex:indexNum];
    
    if (self.record) { //record exists, fill fields with it
        [self.nameTextField setText:[self.record valueForKey:@"name"]];
        [self.timeTextField setText:[self.record valueForKey:@"time"]];
        [self.datePicker setDate:[self.record valueForKey:@"date"]];
        [self.locationTextField setText:[self.record valueForKey:@"location"]];
        UIImage *image = [UIImage imageWithData:[self.record valueForKey:@"image"]];
        [[self imageView] setImage:image];
    }
    if (self.sentLength) { //creating new record with same name
        [self.nameTextField setText:self.sentLength];
    }
    
    //initialize pickerView keyboard
    pickerView = [[UIPickerView alloc] init];
    pickerView.dataSource = self;
    pickerView.delegate = self;
    self.nameTextField.inputView = pickerView;
    
    //get types from plist
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Types" ofType:@"plist"];
    //dict holds all of plist
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:path];
    NSDictionary *runDict = [dict objectForKey:@"Runs"]; //holds runs
    NSDictionary *swimDict = [dict objectForKey:@"Swims"]; //holds swims
    NSDictionary *triathlonDict = [dict objectForKey:@"Triathlons"]; //holds triathlons
    //sort by number
    runLengths = [[runDict allKeys] sortedArrayUsingSelector:@selector(localizedStandardCompare:)];
    swimLengths = [[swimDict allKeys] sortedArrayUsingSelector:@selector(localizedStandardCompare:)];
    triathlonLengths = [[triathlonDict allKeys] sortedArrayUsingSelector:@selector(localizedStandardCompare:)];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)segmentChanged:(id)sender {
    [self.nameTextField reloadInputViews];
    [self.pickerView reloadAllComponents];
}

-(BOOL)textFieldShouldReturn:(id)sender
{
    [sender resignFirstResponder];
    return YES;
}

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

- (IBAction)cancel:(id)sender {
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)save:(id)sender {
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity;
    switch (activitySegment.selectedSegmentIndex)
    {
        case 0:
             entity = [NSEntityDescription entityForName:@"Run" inManagedObjectContext:context];
            break;
        case 1:
            entity = [NSEntityDescription entityForName:@"Triathlon" inManagedObjectContext:context];
            break;
        case 2:
            entity = [NSEntityDescription entityForName:@"Swim" inManagedObjectContext:context];
            break;
    }
    [request setEntity:entity];
    // retrive the objects with a given value for a certain property
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"name == %@", self.nameTextField.text];
    [request setPredicate:predicate];
    NSError *error = nil;
    NSArray *result = [context executeFetchRequest:request error:&error];

    if (self.record)  //record already exists
    {
        [self.record setValue:self.nameTextField.text forKey:@"name"];
        [self.record setValue:self.timeTextField.text forKey:@"time"];
        [self.record setValue:self.datePicker.date forKey:@"date"];
        [self.record setValue:self.locationTextField.text forKey:@"location"];
        NSData *imageData;
        if (self.imageView.image == nil){
            switch (activitySegment.selectedSegmentIndex)
            {
                case 0:
                    imageData = UIImagePNGRepresentation([UIImage imageNamed:@"running-large.png"]);
                    break;
                case 1:
                    imageData = UIImagePNGRepresentation([UIImage imageNamed:@"triangle-large.png"]);
                    break;
                case 2:
                    imageData = UIImagePNGRepresentation([UIImage imageNamed:@"swimming-large.png"]);
                    break;
                default:
                    imageData = UIImagePNGRepresentation([UIImage imageNamed:@"running-large.png"]);
                    break;
            }
            
            
        }else {
            imageData = UIImagePNGRepresentation(self.imageView.image);
        }
        [self.record setValue:imageData forKey:@"image"];
    }else if([result count]!=0)
    {
        //record with name already exists, so overwrite it.
        //first save old record to Previous Records
        NSManagedObject *oldRecord;
        oldRecord = [NSEntityDescription insertNewObjectForEntityForName:@"Previous" inManagedObjectContext:context];
        self.record = result[0];
        [oldRecord setValue:[[self.record entity] name] forKey:@"activity"];
        [oldRecord setValue:[self.record valueForKey:@"name"] forKey:@"name"];
        [oldRecord setValue:[self.record valueForKey:@"time"] forKey:@"time"];
        [oldRecord setValue:[self.record valueForKey:@"date"] forKey:@"date"];
        [oldRecord setValue:[self.record valueForKey:@"location"] forKey:@"location"];
        [oldRecord setValue:[self.record valueForKey:@"image"] forKey:@"image"];
        if (![context save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
        //now overwrite
        self.record = [result objectAtIndex:0];
        [self.record setValue:self.timeTextField.text forKey:@"time"];
        [self.record setValue:self.datePicker.date forKey:@"date"];
        [self.record setValue:self.locationTextField.text forKey:@"location"];
        NSData *imageData;
        if (self.imageView.image == nil){
            switch (activitySegment.selectedSegmentIndex)
            {
                case 0:
                    imageData = UIImagePNGRepresentation([UIImage imageNamed:@"running-large.png"]);
                    break;
                case 1:
                    imageData = UIImagePNGRepresentation([UIImage imageNamed:@"triangle-large.png"]);
                    break;
                case 2:
                    imageData = UIImagePNGRepresentation([UIImage imageNamed:@"swimming-large.png"]);
                    break;
                default:
                    imageData = UIImagePNGRepresentation([UIImage imageNamed:@"running-large.png"]);
                    break;
            }
            
            
        }else {
            imageData = UIImagePNGRepresentation(self.imageView.image);
        }
        [self.record setValue:imageData forKey:@"image"];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Congratulations!"
                                                        message:@"You've beat your previous record!"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    else{
    NSManagedObject *newRecord;
    switch (activitySegment.selectedSegmentIndex)
    {
        case 0:
            newRecord = [NSEntityDescription insertNewObjectForEntityForName:@"Run" inManagedObjectContext:context];
            break;
        case 1:
            newRecord = [NSEntityDescription insertNewObjectForEntityForName:@"Triathlon" inManagedObjectContext:context];
            break;
        case 2:
            newRecord = [NSEntityDescription insertNewObjectForEntityForName:@"Swim" inManagedObjectContext:context];
            break;
        default:
            newRecord = [NSEntityDescription insertNewObjectForEntityForName:@"Run" inManagedObjectContext:context];
            break;
    }
    
    
    [newRecord setValue:self.nameTextField.text forKey:@"name"];
    [newRecord setValue:self.timeTextField.text forKey:@"time"];
    [newRecord setValue:self.datePicker.date forKey:@"date"];
    [newRecord setValue:self.locationTextField.text forKey:@"location"];
        NSData *imageData;
        if (self.imageView.image == nil){
            switch (activitySegment.selectedSegmentIndex)
            {
                case 0:
                    imageData = UIImagePNGRepresentation([UIImage imageNamed:@"running-large.png"]);
                    break;
                case 1:
                    imageData = UIImagePNGRepresentation([UIImage imageNamed:@"triangle-large.png"]);
                    break;
                case 2:
                    imageData = UIImagePNGRepresentation([UIImage imageNamed:@"swimming-large.png"]);
                    break;
                default:
                    imageData = UIImagePNGRepresentation([UIImage imageNamed:@"running-large.png"]);
                    break;
            }
            

        }else {
    imageData = UIImagePNGRepresentation(self.imageView.image);
        }
           [newRecord setValue:imageData forKey:@"image"];
    }

    
    
    error = nil;
    // Save the object to persistent store
    if (![context save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}*/

- (IBAction)showActionSheet:(id)sender {
    UIActionSheet *sheet = [[UIActionSheet alloc]
                            initWithTitle:@"Pick Image"
                            delegate:self
                            cancelButtonTitle:@"Cancel"
                            destructiveButtonTitle:nil
                            otherButtonTitles:@"Camera",@"From Library", nil];
    [sheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
 NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if([buttonTitle isEqualToString:@"Camera"]){
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            
            UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                  message:@"Device has no camera-Please choose from Photo Library"
                                                                 delegate:nil
                                                        cancelButtonTitle:@"OK"
                                                        otherButtonTitles: nil];
            
            [myAlertView show];
            
            
        } else{
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        [self presentViewController:picker animated:YES completion:NULL];
        } }
    if ([buttonTitle isEqualToString:@"From Library"]){
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        [self presentViewController:picker animated:YES completion:NULL];
    }
    
    
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.imageView.image = chosenImage;
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent: (NSInteger)component
{
    switch (activitySegment.selectedSegmentIndex){
        case 0:
            return 15;
            break;
        case 1:
            return 4;
            break;
        case 2:
            return 15;
            break;
        default:
            return 0;
            break;
    }
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row   forComponent:(NSInteger)component
{
    NSString *str;
    switch (activitySegment.selectedSegmentIndex){
            
        case 0:
            str = [self.runLengths objectAtIndex:row];
            break;
        case 1:
            str = [self.triathlonLengths objectAtIndex:row];
            break;
        case 2:
            str = [self.swimLengths objectAtIndex:row];
            break;
        default:
            str = nil;
            break;
    }
    NSString *newStr = [str substringWithRange:NSMakeRange(3, [str length]-3)];
    return newStr;
    
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row   inComponent:(NSInteger)component{
        NSString *str;
    if (row==0)
    {
       nameTextField.text = @"Custom";
        [customNameTextField setHidden:NO];
        [customNameTextField becomeFirstResponder];
        
    }else{

    switch (activitySegment.selectedSegmentIndex){
            
        case 0:
            str = [self.runLengths objectAtIndex:row];
            break;
        case 1:
            str = [self.triathlonLengths objectAtIndex:row];
            break;
        case 2:
            str = [self.swimLengths objectAtIndex:row];
            break;
        default:
            str = nil;
            break;
    }
    NSString *newStr = [str substringWithRange:NSMakeRange(3, [str length]-3)];
    nameTextField.text = newStr;
    [timeTextField becomeFirstResponder];
    }
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    if (textField.tag == 20){
        nameTextField.text = textField.text;

    }
    textField.hidden = YES;
}
@end
