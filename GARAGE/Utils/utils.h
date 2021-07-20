//
//  utils.h
//  GARAGE
//
//  Created by Sanjana Meduri on 7/16/21.
//

#import <Foundation/Foundation.h>
@import Parse;
#import "Parse/Parse.h"
#import <GoogleMaps/GoogleMaps.h>
#import "INTULocationManager/INTULocationManager.h"
#import "Listing.h"

NS_ASSUME_NONNULL_BEGIN

@interface utils : NSObject

@property (assign, nonatomic) int numListings;

+ (PFQuery*) setUpQuery;
+ (void) geocodeRequest: (NSString*)address WithCompletion:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completion;
+ (void) getCurrentLocationWithCompletion:(void (^)(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status)) completion;
+ (void) filterListings:(NSArray*)listings byDistance:(double)distanceRadius fromCurrentLocation:(CLLocationCoordinate2D)currentCoords into:(NSMutableArray**) filteredListings;

@end

NS_ASSUME_NONNULL_END
