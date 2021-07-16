//
//  utils.h
//  GARAGE
//
//  Created by Sanjana Meduri on 7/16/21.
//

#import <Foundation/Foundation.h>
@import Parse;
#import "Parse/Parse.h"

NS_ASSUME_NONNULL_BEGIN

@interface utils : NSObject

@property (assign, nonatomic) int numListings;

+ (PFQuery*) setUpQuery;

@end

NS_ASSUME_NONNULL_END
