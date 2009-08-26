//
//  CLLocation+DistanceComparison.h
//  MapNotes
//
//  Created by Brian Erickson on 8/17/09.
//  Copyright 2009 WRKSHP, LLC. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@interface CLLocation (DistanceComparison)

- (NSComparisonResult) compareToLocation:(CLLocation *)other;

@end
