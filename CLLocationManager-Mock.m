//
//  FRLocationManagerMock.m
//  kroonjuwelen
//
//  Created by Jonathan Dalrymple on 28/03/2010.
//  Copyright 2010 Float:Right. All rights reserved.
//

#import "CLLocationManager-Mock.h"

static NSMutableDictionary* _mockIVarDict;

@implementation CLLocationManager (Mock)


/*
 *	Share state within the application
 */
-(NSMutableDictionary*) sharedDictionary{
	
	if( _mockIVarDict == nil ){
		_mockIVarDict = [[NSMutableDictionary alloc] init];
	}
	
	return _mockIVarDict;
}

/*
 *	Store the locations array
 */
-(NSArray*) locations{
	
	//Load the locations file
	if( [[self sharedDictionary] objectForKey:@"locations"] == nil ){
		
		[[self sharedDictionary] setObject:[NSArray arrayWithContentsOfFile:LOCATIONS_FILE_PATH] 
									forKey:@"locations"
		 ];
		
	}
	
	return [[self sharedDictionary] objectForKey:@"locations"];
	
}

/*
 *	Get the counter value
 */
-(int) counter{
	
	@synchronized(self){
		if( [[self sharedDictionary] objectForKey:@"counter"]  == nil ){
			[[self sharedDictionary] setObject:[NSNumber numberWithInt:0] forKey:@"counter"];
		}
	}

	
	return [[[self sharedDictionary] objectForKey:@"counter"] intValue];
}

/*
 *	Increment the counter
 */
-(void) counterIncrement{
	
	@synchronized(self){
		int i = [self counter];
	
		//increment
		i++;
		
		//Re store the iVar
		[[self sharedDictionary] setObject:[NSNumber numberWithInt:i] forKey:@"counter"];
	}
	
}

/*
 *	Parse a location into a CLloction
 */
-(CLLocation*) parseObjectInArray:(NSArray*) array AtIndex:(NSUInteger) index{
	
	id obj;
	NSArray *components;
	float latitude, longitude;
	
	//If we are at the end of the array send the last item
	if( index < [array count] ){
		obj = [array objectAtIndex:index];
	}
	else{
		obj = [array lastObject];
	}
	
	
	if( [obj isKindOfClass:[NSString class]] ){
		
		components = [obj componentsSeparatedByString:@","];
		
		latitude = [[components objectAtIndex:0] floatValue];
		longitude = [[components objectAtIndex:1] floatValue];
		
		return [[[CLLocation alloc] initWithLatitude: latitude longitude: longitude] autorelease];
	}
	else{
		return nil;
	}
	
}

/*
 */
-(BOOL) isUpdatingLocation{
	
	if( [[self sharedDictionary] objectForKey:@"timer"] == nil ){
		return NO;
	}
	else{
		return [[[self sharedDictionary] objectForKey:@"timer"] isValid];
	}
}


//=====================================================================
//					CLLocationManager Methods
//=====================================================================
/*
 *	Start updating location
 */
- (void) startUpdatingLocation{
	NSLog(@"[LocationMock startUpdating] \r\n%@", self );

	@synchronized(self){
		if( ![self isUpdatingLocation] ){
			NSLog(@"Created a timer");
			
			//Create a a timmer
			NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval: UPDATE_INTERVAL
															  target: self
															selector: @selector(sendLocation)
															userInfo: nil
															 repeats: YES
							  ];		
			
			//Keep a copy of the timer
			[[self sharedDictionary] setObject:timer forKey:@"timer"];
		}			
	}


}

/*
 *	Stop updating location
 */
- (void) stopUpdatingLocation{
	NSLog(@"[LocationMock stopUpdating]");
	
	//Invalidate
	[[[self sharedDictionary] objectForKey:@"timer"] invalidate];


}

/*
 *	Return the location
 */
-(CLLocation*) location{
	//NSLog(@"Getting location");
	
	//Don't return a location until after the first update
	if( [self counter] > 0){
		id obj = [self parseObjectInArray:[self locations] AtIndex: [self counter]-1];
		
		//NSLog(@"obj %@", obj);
		
		return obj;
		
	}
	else{
		return nil;
	}
}

-(void) setDelegate:(id<CLLocationManagerDelegate>) delegate{
	NSLog(@"setDelegate");
	
	NSMutableArray* array;
	
	//Create the array if required
	if(  !(array = [[self sharedDictionary] objectForKey:@"delegates"]) ){
		
		array = [[NSMutableArray alloc] init];
		
		[[self sharedDictionary] setObject: array forKey: @"delegates"];
		
	}
	
	[array addObject:delegate];
	
}

-(id<CLLocationManagerDelegate>) delegate{
	NSLog(@"get Delegate");
	return nil;
}
//=====================================================================
//					CLLocationManager Call Delegate method
//=====================================================================
-(void) sendLocation{
	
	//NSLog(@"Updating location %@", [self locations]);
	CLLocation *newLocation, *oldLocation;	
	
	oldLocation = [self location];
	
	newLocation = [self parseObjectInArray: [self locations] 
					 AtIndex: [self counter]
	 ];
	
	//Test for a delegate
	//Get the array of delegates
	NSArray* delegates = [[self sharedDictionary] objectForKey:@"delegates"];
	
	for( id delegateObj in delegates){
		
		//NSLog(@"Location %@", delegateObj);
		if( [delegateObj respondsToSelector:@selector(locationManager:didUpdateToLocation:fromLocation:)] ){
			
			//Call the delegate method
			[delegateObj locationManager: self 
						 didUpdateToLocation: newLocation 
								fromLocation: oldLocation
			 ];
			
			
		}
		else if( [delegateObj respondsToSelector: @selector(locationManager:didUpdateToLocation:fromLocation:usingSupportInfo:)]){
			//Deal with MapKit

			[delegateObj locationManager: self didUpdateToLocation: newLocation fromLocation: oldLocation usingSupportInfo: nil];

		}
		else{
			NSLog(@"%@ Doesn't respond to the selector", delegateObj);
		}		
		
	}


	[self counterIncrement];
	
	//Cleanup
	/*
	NSLog(@"New Retain Count %d",[newLocation retainCount]);
	NSLog(@"Old Retain Count %d",[oldLocation retainCount]);
	 */

}
@end
