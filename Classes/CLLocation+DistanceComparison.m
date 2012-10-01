//
//  CLLocation+DistanceComparison.m
//  MapNotes
//
//  Created by Brian Erickson on 8/17/09.
//  Copyright 2009 Brian Erickson. May be freely distributed under the MIT license.
//

#import "CLLocation+DistanceComparison.h"
#import "LocationController.h"

@implementation CLLocation (DistanceComparison)

- (NSComparisonResult) compareToLocation:(CLLocation *)other {
	CLLocation *myLocation = [[LocationController sharedInstance] currentLocation]; 
	CLLocationDistance thisDistance = [self getDistanceFrom:myLocation];
	CLLocationDistance thatDistance = [other getDistanceFrom:myLocation];
	
	if (thisDistance < thatDistance) { return NSOrderedAscending; }
	if (thisDistance > thatDistance) { return NSOrderedDescending; }
	return NSOrderedSame;
}

@end
