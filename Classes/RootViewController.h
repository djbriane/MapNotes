//
//  LaunchViewController.h
//  MapNotes
//
//  Created by Brian Erickson on 7/24/09.
//  Copyright 2009 Local Matters, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>


@interface RootViewController : UIViewController <CLLocationManagerDelegate> {
	NSManagedObjectContext *managedObjectContext;

	CLLocationManager *locationManager;

}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, retain) CLLocationManager *locationManager;



- (void)updateCurrentLocation;
- (void)setCurrentLocation:(CLLocation *)location;
- (IBAction)updateLocation:(id)sender;



@end
