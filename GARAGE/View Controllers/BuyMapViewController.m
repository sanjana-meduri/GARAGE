//
//  BuyMapViewController.m
//  GARAGE
//
//  Created by Sanjana Meduri on 7/14/21.
//

#import "BuyMapViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import "utils.h"

@interface BuyMapViewController () <CLLocationManagerDelegate>

@property (strong, nonatomic) GMSMapView *mapView;
@property (strong, nonatomic) NSDictionary *destinationCoordinates;
@property (assign, nonatomic) BOOL firstLocationUpdate;

@end

@implementation BuyMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    
    self.mapView.settings.myLocationButton = YES;
    self.mapView.myLocationEnabled = YES;

    [self geocodeRequest];
}

- (void) setupMap{
    double latitude = [self.destinationCoordinates[@"lat"] doubleValue];
    double longitude = [self.destinationCoordinates[@"lng"] doubleValue];
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:latitude longitude:longitude zoom:6];
    self.mapView = [GMSMapView mapWithFrame:self.view.frame camera:camera];
    self.mapView.myLocationEnabled = YES;

    
    CGRect f = self.view.frame;
    CGRect mapFrame = CGRectMake(f.origin.x, 50, f.size.width, f.size.height);
    self.mapView = [GMSMapView mapWithFrame:mapFrame camera:camera];
    [self.view addSubview:self.mapView];
    
    GMSMarker *itemMarker = [GMSMarker markerWithPosition:CLLocationCoordinate2DMake(latitude, longitude)];
    itemMarker.title = @"Item Address";
    itemMarker.map = self.mapView;
    
    [self.mapView addObserver:self
                 forKeyPath:@"myLocation"
                    options:NSKeyValueObservingOptionNew
                    context:NULL];
    
    dispatch_async(dispatch_get_main_queue(), ^{
      self.mapView.myLocationEnabled = YES;
    });
}

- (void) geocodeRequest{
    [utils geocodeRequest:self.listing.address WithCompletion:^(NSData * _Nonnull data, NSURLResponse * _Nonnull response, NSError * _Nonnull error) {
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);

            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Network Connection Failed" message:@"It looks like you are not connected to the Internet! Please check your connection and try again." preferredStyle:UIAlertControllerStyleAlert];

            UIAlertAction *retryAction = [UIAlertAction actionWithTitle:@"Retry" style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action){
                [self geocodeRequest];
            }];

            [alert addAction:retryAction];

            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *_Nonnull action){}];

            [alert addAction:cancelAction];

            [self presentViewController:alert animated:YES completion:^{}];
        }
        else {
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
         
            self.destinationCoordinates = dataDictionary[@"results"][0][@"geometry"][@"location"];
            
            [self setupMap];
         
            NSLog(@"%@", dataDictionary[@"results"][0][@"geometry"][@"location"]);
        }
    }];
}

- (IBAction)onDirectionssRequest:(id)sender {
    NSLog(@"im here");
    NSString *requestParameters = [NSString stringWithFormat:@"?&daddr=%@&directionsmode=driving", self.listing.address];
    requestParameters = [requestParameters stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *requestURL = [@"comgooglemaps://" stringByAppendingString:requestParameters];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:requestURL] options:@{} completionHandler:^(BOOL success) {
        if(!success){
            NSString *requestURL = [@"https://maps.google.com/" stringByAppendingString:requestParameters];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:requestURL] options:@{} completionHandler:^(BOOL success) {}];
        }
    }];
}


//from maps api docs
- (void)dealloc {
  [self.mapView removeObserver:self
                forKeyPath:@"myLocation"
                   context:NULL];
}

//from maps api docs
#pragma mark - KVO updates

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
  if (!self.firstLocationUpdate) {
    self.firstLocationUpdate = YES;
  }
}

- (IBAction)onBack:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
