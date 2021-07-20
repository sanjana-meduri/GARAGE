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

NS_ASSUME_NONNULL_BEGIN

@interface utils : NSObject

@property (assign, nonatomic) int numListings;

+ (PFQuery*) setUpQuery;
+ (void) geocodeRequest: (NSString*)address WithCompletion:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completion;


@end

NS_ASSUME_NONNULL_END
