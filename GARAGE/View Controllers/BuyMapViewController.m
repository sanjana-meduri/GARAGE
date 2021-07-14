//
//  BuyMapViewController.m
//  GARAGE
//
//  Created by Sanjana Meduri on 7/14/21.
//

#import "BuyMapViewController.h"
#import <GoogleMaps/GoogleMaps.h>

@interface BuyMapViewController ()

@property (strong, nonatomic) GMSMapView *mapView;
@property (strong, nonatomic) NSDictionary *destinationCoordinates;

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
    CGRect mapFrame = CGRectMake(f.origin.x, 44, f.size.width, f.size.height);
    self.mapView = [GMSMapView mapWithFrame:mapFrame camera:camera];
    [self.view addSubview:self.mapView];
    
    GMSMarker *marker = [GMSMarker markerWithPosition:CLLocationCoordinate2DMake(latitude, longitude)];
    marker.title = @"Item Address";
    marker.map = self.mapView;
}

- (void) geocodeRequest{
    NSString *urlString = [[@"https://maps.googleapis.com/maps/api/geocode/json?address=" stringByAppendingString:self.listing.address] stringByAppendingString:@"&key=AIzaSyB3uTAyKC64dPGL_nnZpz0KPcm0PpFXyNc"];
    
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *requestUrl = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:requestUrl cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
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
                   //Get the array of movies
                   NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                
                   self.destinationCoordinates = dataDictionary[@"results"][0][@"geometry"][@"location"];
                   
                   [self setupMap];
                
                   NSLog(@"%@", dataDictionary[@"results"][0][@"geometry"][@"location"]);
               }
           }];
        [task resume];

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
