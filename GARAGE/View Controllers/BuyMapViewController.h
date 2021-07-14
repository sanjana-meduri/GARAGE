//
//  BuyMapViewController.h
//  GARAGE
//
//  Created by Sanjana Meduri on 7/14/21.
//

#import <UIKit/UIKit.h>
#import "Listing.h"
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BuyMapViewController : UIViewController

@property (strong, nonatomic) Listing* listing;
@property(nonatomic,retain) CLLocationManager *locationManager;

@end

NS_ASSUME_NONNULL_END
