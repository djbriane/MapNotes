//
//  CLLocation+DistanceComparison.m
//  MapNotes
//
//  Created by Brian Erickson on 8/17/09.
//  Copyright 2009 WRKSHP, LLC. All rights reserved.
//

#import "CLLocation+DistanceComparison.h"

@implementation CLLocation (DistanceComparison)

- (NSComparisonResult) compareToLocation:(CLLocation *)other {
	CLLocationDistance thisDistance = [self getDistanceFrom:referenceLocation];
	CLLocationDistance thatDistance = [other getDistanceFrom:referenceLocation];
	if (thisDistance < thatDistance) { return NSOrderedAscending; }
	if (thisDistance > thatDistance) { return NSOrderedDescending; }
	return NSOrderedSame;
}

@end
