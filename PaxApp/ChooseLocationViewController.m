//
//  ChooseLocationViewController.m
//  PaxApp
//
//  Created by Junyuan Lau on 04/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ChooseLocationViewController.h"
#import "AddressAnnotation.h"
#import "AddressNameAlert.h"
#import "GlobalVariables.h"
#import "CustomNavBar.h"
#import "Constants.h"


@implementation ChooseLocationViewController
@synthesize dirty;
@synthesize loading;
@synthesize suggestions, references;
@synthesize mapView;
@synthesize referer;
@synthesize refererTag;



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [mapView setDelegate:self];
    
    //set top navBar
    CustomNavBar *thisNavBar = [[CustomNavBar alloc] initOneRowBar];    
    self.navigationItem.titleView = thisNavBar;
    self.tabBarController.tabBar.userInteractionEnabled = YES;
    
    if (refererTag == 11 || refererTag == 31) {
        self.title = @"Pick up";
        [thisNavBar setCustomNavBarTitle:NSLocalizedString(@"Pick up", @"") subtitle:@""];

    } else if (refererTag == 12 || refererTag == 32) {
        self.title =@"Destination";
        [thisNavBar setCustomNavBarTitle:NSLocalizedString(@"Destination", @"") subtitle:@""];

    }

    CLLocationCoordinate2D coordinate;    
    coordinate.latitude = 3.136441;
    coordinate.longitude = 101.689072;
    
    span.latitudeDelta=0.28;
    span.longitudeDelta=0.28;	 
    region.span=span;
    region.center=coordinate;
    
    [mapView setRegion:region animated:TRUE];
    [mapView regionThatFits:region];
    

    
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
	if ([searchText length] > 2) {
		if (loading) {
			dirty = YES;
		} else {
			[self loadSearchSuggestions];
		}
	}
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
	return NO;
}


- (void) loadSearchSuggestions {
	loading = YES;
	NSString* query = self.searchDisplayController.searchBar.text;
    
    
    //NSString* apiKey = @"AIzaSyCqe57ih20Bt7X26dk1vFgatymmmxyS9VI";
    
    //https://maps.googleapis.com/maps/api/place/autocomplete/json?parameters
    /*
     input — The text string on which to search. The Place service will return candidate matches based on this string and order results based on their perceived relevance.
     sensor — Indicates whether or not the Place request came from a device using a location sensor (e.g. a GPS) to determine the location sent in this request. This value must be either true or false.
     key — Your application's API key. This key identifies your application for purposes of quota management. Visit the APIs Console to create an API Project and obtain your key.
     
     API key = AIzaSyCqe57ih20Bt7X26dk1vFgatymmmxyS9VI 
     */
    
    
    NSString *urlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/autocomplete/json?input=%@&sensor=true&key=%@&components=country:my", query, kGoogleAPIKey];
    
    urlString =  [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    //NSURLResponse *response = nil;
    //NSError *error = nil;   
    //NSData *responseData = 
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *responseData, NSError *error) {
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        
        if([httpResponse statusCode] == 200) {     
        NSMutableArray *sug =[[NSMutableArray alloc]initWithCapacity:5 ];
        NSMutableArray *ref =[[NSMutableArray alloc]initWithCapacity:5];
        
        NSDictionary* tester = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:nil]; 
        NSArray* testArray = [tester objectForKey:@"predictions"];
        
        for (NSDictionary *result in testArray) {
            
            
            NSArray* terms = [result objectForKey:@"terms"];
            NSDictionary *term0 = [terms objectAtIndex:0];
            NSString* resultname = [term0 objectForKey:@"value"]; 
            
            NSLog(@"%@",resultname);
            [sug addObject:resultname];
            [ref addObject:[result objectForKey:@"reference"]];
        }
        
        
        self.suggestions = sug;
        self.references = ref;
        
        //[self.searchDisplayController.searchResultsTableView reloadData];
        [self.searchDisplayController.searchResultsTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES]; 
        
        
        loading = NO;
        if (dirty) {
            dirty = NO;
            [self loadSearchSuggestions];
        }
        }
    }];

}

#pragma mark -
#pragma mark UITableView methods

- (UITableViewCell *)tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *cellIdentifier = @"suggest";
	
	UITableViewCell *cell = [table dequeueReusableCellWithIdentifier:cellIdentifier];
    
	if (cell == nil) 
	{
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] ;
        
		cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
		cell.textLabel.numberOfLines = 0;
		cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:12.0];
	}
	
	//MKPointAnnotation* suggestion = [suggestions objectAtIndex:indexPath.row];
	cell.textLabel.text = [suggestions objectAtIndex:indexPath.row];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self.searchDisplayController setActive:NO animated:YES];
    [mapView removeAnnotations:mapView.annotations];
    NSString* refID = [references objectAtIndex:indexPath.row];
    
    NSString *urlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/details/json?reference=%@&sensor=true&key=%@", refID, kGoogleAPIKey];
    
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"%@",urlString);
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *responseData, NSError *error) {
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;

        if ([httpResponse statusCode] ==200) {
        
        NSDictionary* tester = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:nil]; 
        NSDictionary* result = [tester objectForKey:@"result"];
        NSDictionary* geo = [result objectForKey:@"geometry"];
        NSDictionary* location = [geo objectForKey:@"location"];
        
        NSLog(@"%@", [location objectForKey:@"lat"]);
        NSLog(@"%@", [location objectForKey:@"lng"]);
        
        //float lat = [[location objectForKey:@"lat"]floatValue];        
        //float longi = [[location objectForKey:@"longi"]floatValue];        
        double lat = [[location objectForKey:@"lat"]doubleValue];
        double longi = [[location objectForKey:@"lng"]doubleValue];        
        
        CLLocationCoordinate2D coordinate=CLLocationCoordinate2DMake(lat, longi);    
        coordinate.latitude = lat;
        coordinate.longitude = longi;
        

        span.latitudeDelta=0.007;
        span.longitudeDelta=0.007;	 
        region.span=span;
        region.center=coordinate;
        

        
        myAA = [[AddressAnnotation alloc]initWithCoordinate:CLLocationCoordinate2DMake(lat,longi)];
        myAA.subtitle = [suggestions objectAtIndex:[indexPath row]];
        
        lastPlace = [suggestions objectAtIndex:[indexPath row]];
        
        [self performSelectorOnMainThread:@selector(addAnnotations) withObject:nil waitUntilDone:YES];
        }
    }];
    
    
	//MKPointAnnotation* suggestion = [suggestions objectAtIndex:indexPath.row];
    // You could add "suggestion" to a map since it implements MKAnnotation
    // example: [map addAnnotation:suggestion]
    
    //label.text = suggestion.title;
}

- (void) addAnnotations
{
    self.searchDisplayController.searchBar.placeholder = lastPlace;
    [mapView setRegion:region animated:TRUE];
    [mapView regionThatFits:region];
    [mapView addAnnotation:myAA];
  
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [suggestions count];
}

- (IBAction)cancelButton:(id)sender
{
    
    if (refererTag == 11 || refererTag == 12) {
        [self gotoSubmitJob];
        
    } else if (refererTag == 31 || refererTag == 32) {
        [self gotoAdvanced];        
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"%@ - %@ - textfield %@",self.class,NSStringFromSelector(_cmd), nameBox.inputField.text);
    if(buttonIndex == 1)
    {
        if (!nameBox.inputField.text)
            nameBox.inputField.text = @"";
        
        NSLog(@"%@ - %@ - clicked",self.class,NSStringFromSelector(_cmd));

        
        NSUserDefaults* preferences = [NSUserDefaults standardUserDefaults];
        
        if ([preferences arrayForKey:@"ClientSavedAddress"] == nil) {        
            
            
            NSMutableDictionary *newAddress = [[NSMutableDictionary alloc]init ];
            [newAddress setValue:[NSString stringWithFormat:@"%f",myAA.coordinate.latitude] forKey:@"latitude"];
            [newAddress setValue:[NSString stringWithFormat:@"%f",myAA.coordinate.longitude] forKey:@"longitude"];
            [newAddress setValue:[NSString stringWithFormat:@"%@",myAA.subtitle] forKey:@"subtitle"];
            [newAddress setValue:[NSString stringWithFormat:@"%@",nameBox.inputField.text] forKey:@"title"];
            
            NSMutableArray* savedAddressList = [[NSMutableArray alloc] init];
            [savedAddressList addObject:newAddress];
            
            [preferences setValue:savedAddressList forKey:@"ClientSavedAddress"];
        } else {
            NSMutableArray* savedAddressList = [[NSMutableArray alloc]initWithArray:[preferences arrayForKey:@"ClientSavedAddress"]];
            
            NSMutableDictionary *newAddress = [[NSMutableDictionary alloc]init ];
            [newAddress setValue:[NSString stringWithFormat:@"%f",myAA.coordinate.latitude] forKey:@"latitude"];
            [newAddress setValue:[NSString stringWithFormat:@"%f",myAA.coordinate.longitude] forKey:@"longitude"];
            [newAddress setValue:[NSString stringWithFormat:@"%@",myAA.subtitle] forKey:@"subtitle"];
            [newAddress setValue:[NSString stringWithFormat:@"%@",nameBox.inputField.text] forKey:@"title"];
            
            [savedAddressList addObject:newAddress];
            [preferences setValue:savedAddressList forKey:@"ClientSavedAddress"];
            
        }
        
    }
    
}



-(IBAction)useThisLocationButton:(id)sender
{
    if (!myAA) {
        UIAlertView *errorbox = [[UIAlertView alloc]initWithTitle:@"No location selected!" message:@"" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [errorbox show];
        
    } else {
        if (refererTag == 12){
            NSLog(@"%@ - %@ - clicked %i",self.class,NSStringFromSelector(_cmd), refererTag);
            
            // bookingform
            [[[GlobalVariables myGlobalVariables] gCurrentForm] setObject:[NSString stringWithFormat:@"%f", myAA.coordinate.latitude] forKey:@"dropoff_latitude"];
            [[[GlobalVariables myGlobalVariables] gCurrentForm] setObject:[NSString stringWithFormat:@"%f", myAA.coordinate.longitude] forKey:@"dropoff_longitude"];
            [[[GlobalVariables myGlobalVariables] gCurrentForm] setObject:[NSString stringWithFormat:@"%@", myAA.subtitle] forKey:@"dropoff_address"];
            
            [self gotoSubmitJob];
        } else if (refererTag == 11){
            NSLog(@"%@ - %@ - clicked %i",self.class,NSStringFromSelector(_cmd), refererTag);
            
            [[[GlobalVariables myGlobalVariables] gCurrentForm] setObject:[NSString stringWithFormat:@"%f", myAA.coordinate.latitude] forKey:@"pickup_latitude"];
            [[[GlobalVariables myGlobalVariables] gCurrentForm] setObject:[NSString stringWithFormat:@"%f", myAA.coordinate.longitude] forKey:@"pickup_longitude"];
            [[[GlobalVariables myGlobalVariables] gCurrentForm] setObject:[NSString stringWithFormat:@"%@", myAA.subtitle] forKey:@"pickup_address"];
            
            [self gotoSubmitJob];
        } else if (refererTag == 32){
            NSLog(@"%@ - %@ - clicked %i",self.class,NSStringFromSelector(_cmd), refererTag);
            [[[GlobalVariables myGlobalVariables]gAdvancedForm] setObject:[NSString stringWithFormat:@"%f", myAA.coordinate.latitude] forKey:@"dropoff_latitude"];
            [[[GlobalVariables myGlobalVariables]gAdvancedForm] setObject:[NSString stringWithFormat:@"%f", myAA.coordinate.longitude] forKey:@"dropoff_longitude"];            
            [[[GlobalVariables myGlobalVariables]gAdvancedForm] setObject:myAA.subtitle forKey:@"dropoff_address"];
            [self gotoAdvanced];
        } else if (refererTag == 31){
            NSLog(@"%@ - %@ - clicked %i",self.class,NSStringFromSelector(_cmd), refererTag);

            [[[GlobalVariables myGlobalVariables]gAdvancedForm] setObject:[NSString stringWithFormat:@"%f", myAA.coordinate.latitude] forKey:@"pickup_latitude"];
            [[[GlobalVariables myGlobalVariables]gAdvancedForm] setObject:[NSString stringWithFormat:@"%f", myAA.coordinate.longitude] forKey:@"pickup_longitude"];            
            [[[GlobalVariables myGlobalVariables]gAdvancedForm] setObject:myAA.subtitle forKey:@"pickup_address"];
            [self gotoAdvanced];
        }
        
        
    }
}
- (void) gotoAdvanced
{
    [self performSegueWithIdentifier:@"gotoAdvanced" sender:nil];

}

-(void)gotoSubmitJob
{
    
    [self performSegueWithIdentifier:@"gotoSubmitJob" sender:nil];
}


//save locations thingy
-(void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar
{
    if (!myAA) {
        UIAlertView *errorbox = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"No location selected!", @"") message:@"" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [errorbox show];
        
    } else {
        
        nameBox = [[AddressNameAlert alloc]init ];
        [nameBox initWithDelegate:self];
        
    }
}

@end
