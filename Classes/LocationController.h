//
//  LocationController.h
//  Locations
//
//  Created by Brian Erickson on 8/18/09.
//  Copyright 2009 WRKSHP, LLC. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>

@interface  LocationController : NSObject <CLLocationManagerDelegate> {
    CLLocationManager *locationManager;
    CLLocation *currentLocation;
}

+ (LocationController *)sharedInstance;

-(void) start;
-(void) stop;
-(BOOL) locationKnown;

@property (nonatomic, retain) CLLocation *currentLocation;
@property (nonatomic, retain) CLLocationManager *locationManager;

@end
