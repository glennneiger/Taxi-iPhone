//
//  FavouritesViewController.m
//  PaxApp
//
//  Created by Junyuan Lau on 29/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FavouritesViewController.h"
#import "GlobalVariables.h"

@implementation FavouritesViewController
@synthesize refererTag;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    NSUserDefaults* preferences = [NSUserDefaults standardUserDefaults];
    addressList = [[NSMutableArray alloc]initWithArray:[preferences arrayForKey:@"ClientSavedAddress"]];

}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (addressList.count == 0){
        return 1;
    } else {
        return addressList.count;}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    if (addressList.count ==0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            
        }
        cell.textLabel.text = @"No saved addresses";
        cell.detailTextLabel.text = @"";
        return cell;
        
    } else {
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            
        }
        
        
        cell.textLabel.text = [[addressList objectAtIndex:[indexPath row]] objectForKey:@"title"];
        cell.detailTextLabel.text = [[addressList objectAtIndex:[indexPath row]] objectForKey:@"subtitle"];
        return cell;
    }
    
    // Configure the cell...
    
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (addressList.count != 0) {
    
    NSDictionary* selectedAddress = [addressList objectAtIndex:[indexPath row]];
    CLLocationCoordinate2D myLoc;
    myLoc.latitude = [[selectedAddress objectForKey:@"latitude"] floatValue];
    myLoc.longitude = [[selectedAddress objectForKey:@"longitude"] floatValue];
    NSString* addressString = [selectedAddress objectForKey:@"subtitle"];
    
    
    if (refererTag == 21) {
        [[GlobalVariables myGlobalVariables] setGUserCoordinate:myLoc];
        [[GlobalVariables myGlobalVariables] setGUserAddress:addressString];
        [self gotoSubmitJob];
    } else if (refererTag == 22) {
        [[GlobalVariables myGlobalVariables] setGDestiCoordinate:myLoc];
        [[GlobalVariables myGlobalVariables] setGDestinationString:addressString];
        [self gotoSubmitJob];

        
    }
                                     
    }                             
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

-(void)gotoSubmitJob
{
    [self performSegueWithIdentifier:@"gotoSubmitJob" sender:nil];
}
@end