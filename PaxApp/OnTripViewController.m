//
//  OnTripViewController.m
//  PaxApp
//
//  Created by Junyuan Lau on 29/04/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OnTripViewController.h"
#import "DriverPositionPoller.h"
#import "UserLocationAnnotation.h"
#import "CoreLocationManager.h"
#import "GlobalVariables.h"
#import "JobStatusPoller.h"
#import "RatingAlert.h"
#import "Job.h"
#import "CancelJob.h"

#import "JobQuery.h"

#import "MeterReceiver.h"


@implementation OnTripViewController
@synthesize mapView;

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
-(void)viewDidLoad
{
    [super viewDidLoad];
    [self registerNotification];
    [mapView setDelegate:self];
    downloader = [[DriverPositionPoller alloc]initDriverPositionPollWithDriverID:[[GlobalVariables myGlobalVariables]gDriver_id]];

    //myStatusReceiver = [[JobStatusReceiver alloc]initStatusReceiverTimerWithJobID:[[GlobalVariables myGlobalVariables]gJob_id] TargettedStatus:@"driverreached"];
    [self updateUserMarker];
    
    myMeter = [[MeterReceiver alloc]init];
    
    myMeter.fareLabel = fareLabel;
    [super viewDidLoad];
}


-(void)viewDidUnload
{
    [super viewDidUnload];    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


-(void) viewWillDisappear:(BOOL)animated
{
    
    [downloader stopDriverPositionPoll];
    [[NSNotificationCenter defaultCenter] removeObserver:self];    
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)registerNotification
{
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(updateMapMarkers:)
     name:@"driverListUpdated"
     object:nil ];    

    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(endTrip:)
     name:@"driverreached"
     object:nil ];    

    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(gotoMain:)
     name:@"gotoMain"
     object:nil ]; 
}


- (void)updateMapMarkers: (NSNotification *) notification
{    
    NSLog(@"%@ - %@",self.class,NSStringFromSelector(_cmd));
    [mapView addAnnotations:[[[GlobalVariables myGlobalVariables] gDriverList] allValues]];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"driverListUpdated" object:nil];
}

-(void)updateUserMarker
{
    NSLog(@"%@ - %@",self.class,NSStringFromSelector(_cmd));
    
    userLocationAnnotation = [[UserLocationAnnotation alloc]init];
    CLLocationCoordinate2D coordinate=[[GlobalVariables myGlobalVariables] gUserCoordinate];    
    
    MKCoordinateRegion region;
	MKCoordinateSpan span;
	span.latitudeDelta=0.01;
	span.longitudeDelta=0.01;	 
	region.span=span;
    region.center=coordinate;
    
    [mapView setRegion:region animated:TRUE];
	[mapView regionThatFits:region];
    
    [userLocationAnnotation setCoordinateWithGV];
    [mapView addAnnotation:userLocationAnnotation];
}

- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation
{
    
    if (annotation.title == @"User Location")
    {
        NSLog(@"MKAnnotationView Called - User Location");
    	MKAnnotationView *annView = [[MKAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:@"userloc"];
        annView.image = [UIImage imageNamed:@"userdot"];
        annView.draggable = YES;
        annView.canShowCallout = NO;
        
        return annView;
    }else{
        NSLog(@"MKAnnotationView Called - Drivers");
        
        MKAnnotationView *annView = [[MKAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:@"driverloc"];
        annView.image = [UIImage imageNamed:@"taxi"];
        annView.canShowCallout = NO;
        
        return annView;
        
    }
}

-(IBAction)startTrip
{
    [myMeter setJob_ID:[[GlobalVariables myGlobalVariables]gJob_id]];
    [myMeter startMeterReceiverTimer];
}

-(void)endTrip: (NSNotification*) notification
{
    [self performSegueWithIdentifier:@"gotoPayment" sender:self];

}

-(IBAction)testReached:(id)sender
{
    NSLog(@"%@ - %@",self.class,NSStringFromSelector(_cmd));
    JobQuery* newQuery =[[JobQuery alloc]init];
    [newQuery submitJobQuerywithMsgType:@"driverreached" job_id:[[GlobalVariables myGlobalVariables]gJob_id] rating:nil driver_id:nil];
}

-(IBAction)confirmCancel:(id)sender
{
    confirmCancel = [[CancelJob alloc]init];
    [confirmCancel launchConfirmBox];
    
}

-(void)gotoMain:(NSNotification*) notification
{
    [self performSegueWithIdentifier:@"gotoMain" sender:self];
}
@end
