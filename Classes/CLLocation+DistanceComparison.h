//
//  CLLocation+DistanceComparison.h
//  MapNotes
//
//  Created by Brian Erickson on 8/17/09.
//  Copyright 2009 Brian Erickson. May be freely distributed under the MIT license.

#import <CoreLocation/CoreLocation.h>

@interface CLLocation (DistanceComparison)

- (NSComparisonResult) compareToLocation:(CLLocation *)other;

@end
