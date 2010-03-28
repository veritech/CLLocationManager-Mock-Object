//
//  Created by Jonathan Dalrymple on 28/03/2010.
//  Copyright 2010 Float:Right. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#define LOCATIONS_FILE_PATH @"ABSOLUTE/PATH/TO/LOCATIONS.PLIST"
#define UPDATE_INTERVAL 5.0f

@interface CLLocationManager (Mock)

//- (id) init;
- (void)startUpdatingLocation;
- (void)stopUpdatingLocation;

@end
