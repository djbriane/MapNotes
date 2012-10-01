//
//  LocationController.m
//  Locations
//
//  Created by Brian Erickson on 8/18/09.
//  Copyright 2009 Brian Erickson. May be freely distributed under the MIT license.
//

#import "LocationController.h"

@implementation LocationController

@synthesize currentLocation, locationManager;

static LocationController *sharedInstance;

+ (LocationController *)sharedInstance {
    @synchronized(self) {
        if (!sharedInstance)
			[[LocationController alloc] init];              
    }
    return sharedInstance;
}

+(id)alloc {
    @synchronized(self) {
        NSAssert(sharedInstance == nil, @"Attempted to allocate a second instance of a singleton LocationController.");
        sharedInstance = [super alloc];
    }
    return sharedInstance;
}

-(id) init {
    if (self = [super init]) {
        //self.currentLocation = [[CLLocation alloc] init];
        locationManager = [[CLLocationManager alloc] init];
		
		// location manager config
		locationManager.distanceFilter = 10.0f;
		locationManager.desiredAccuracy = kCLLocationAccuracyBest;
		locationManager.delegate = self;
        [self start];
    }
    return self;
}

-(void) start {
    [locationManager startUpdatingLocation];
}

-(void) stop {
    [locationManager stopUpdatingLocation];
}

-(BOOL) locationKnown {
    if (currentLocation) 
        return YES;
    else
        return NO;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	//if the time interval returned from core location is more than two minutes we ignore it because it might be from an old session
    if ( abs([newLocation.timestamp timeIntervalSinceDate: [NSDate date]]) < 120) {
			self.currentLocation = newLocation;
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    UIAlertView *alert;
    alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error description] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release];
}
@end
