//
//  utils.m
//  GARAGE
//
//  Created by Sanjana Meduri on 7/16/21.
//

#import "utils.h"

@implementation utils
int numListings = 20;

+ (PFQuery*) setUpQuery{
    PFQuery *query = [PFQuery queryWithClassName:@"Listing"];
    [query orderByDescending:@"createdAt"];
    [query includeKey:@"seller"];
    [query includeKey:@"description"];
    [query includeKey:@"alreadySold"];
    [query includeKey:@"inInventory"];
    [query includeKey:@"createdAt"];
    [query includeKey:@"tag"];
    [query includeKey:@"name"];
    [query includeKey:@"condition"];
    [query includeKey:@"image"];
    [query includeKey:@"address"];
    [query includeKey:@"price"];
    [query includeKey:@"itemEmail"];
    [query includeKey:@"addressLat"];
    [query includeKey:@"addressLong"];
    
    query.limit = numListings;
    
    return query;
}

+ (void) geocodeRequest: (NSString*)address WithCompletion:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completion{
    NSString *urlString = [[@"https://maps.googleapis.com/maps/api/geocode/json?address=" stringByAppendingString:address] stringByAppendingString:@"&key=AIzaSyB3uTAyKC64dPGL_nnZpz0KPcm0PpFXyNc"];
    
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *requestUrl = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:requestUrl cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:completion];
    [task resume];
}

+ (void) getCurrentLocationWithCompletion:(void (^)(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status)) completion{
    INTULocationManager *locationManager = [INTULocationManager sharedInstance];
    [locationManager requestLocationWithDesiredAccuracy:INTULocationAccuracyHouse
                                       timeout:10.0
                          delayUntilAuthorized:YES
                                         block:completion];
}

#pragma mark - Filter by distance

+ (void) getDistanceFrom:(CLLocationCoordinate2D) origin To:(CLLocationCoordinate2D) destination WithCompletion:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completion{
    NSString *urlString = [NSString stringWithFormat:@"https://api.distancematrix.ai/maps/api/distancematrix/json?origins=%f,%f&destinations=%f,%f&key=yNozOw8fn600QEFiBKtoOcP9KaBII", origin.latitude, origin.longitude, destination.latitude, destination.longitude];
    
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *requestUrl = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:requestUrl cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:completion];
                              
//                              (NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        if (error != nil) {
//            NSLog(@"Error getting distnace between points:%@", error.localizedDescription);
//        }
//        else{
//            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
//            distance = [self kmToMiles:[NSString stringWithFormat:@"%@", dataDictionary[@"rows"][0][@"elements"][0][@"distance"][@"text"]]];
//            checkRadius = (distance <= distanceRadius);
//        }
//    }];
    [task resume];
}


+ (void) filterListings:(NSArray*)listings byDistance:(double)distanceRadius fromCurrentLocation:(CLLocationCoordinate2D)currentCoords into:(NSMutableArray**) filteredListings{
    
    NSMutableArray *localFilteredListings = [[NSMutableArray alloc] init];
    for (Listing *listing in listings){
        CLLocationCoordinate2D destinationCoords = CLLocationCoordinate2DMake(listing.addressLat, listing.addressLong);
        
        NSLog(listing.address);
        NSLog(@"Current location: %f, %f", currentCoords.latitude, currentCoords.longitude);
        NSLog(@"Destination location: %f, %f", listing.addressLat, listing.addressLong);
        
        [self getDistanceFrom:currentCoords To:destinationCoords WithCompletion:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error != nil) NSLog(@"Error getting distance: %@", error.localizedDescription);
            else{
                NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                double distanceInMiles = [self kmToMiles:[NSString stringWithFormat:@"%@", dataDictionary[@"rows"][0][@"elements"][0][@"distance"][@"text"]]];
                
                NSLog(@"🚨🚨🚨🚨🚨🚨🚨🚨%f🚨🚨🚨🚨🚨🚨🚨", distanceInMiles);
                
                if(distanceInMiles <= distanceRadius){
                    NSLog(@"🚨🚨🚨🚨🚨🚨added🚨🚨🚨🚨🚨🚨");
                    [*filteredListings addObject:listing];
                }
                
            }
        }];
    }
}


#pragma mark - Filter by time

+ (NSString*) getTimeFrom:(CLLocationCoordinate2D) origin to:(CLLocationCoordinate2D) destination{
    return @"";
}

+ (NSMutableArray*) filterListings:(NSArray*)listings byTime:(int)timeRadius fromCurrentLocation:(CLLocationCoordinate2D)currentCoords{
    NSMutableArray *filteredListings = [[NSMutableArray alloc] init];
    for(Listing *listing in listings){
        
    }
    return filteredListings;
}


+ (double) kmToMiles: (NSString*) kms{
    return 0.621371 * [kms doubleValue];
}

@end
