//
//  SearchViewController.m
//  GARAGE
//
//  Created by Sanjana Meduri on 7/16/21.
//

#import "SearchViewController.h"
#import "Listing.h"
#import "Parse/Parse.h"
#import "utils.h"
#import "SearchBuyCell.h"

@interface SearchViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITextField *searchField;
@property (weak, nonatomic) IBOutlet UITextField *tagField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *priceControl;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UISegmentedControl *distanceOrTimeControl;
@property (weak, nonatomic) IBOutlet UIView *filterPopupView;
@property (weak, nonatomic) IBOutlet UITextField *radiusField;
@property (strong, nonatomic) UIVisualEffectView *blurEffectView;

@property (strong, nonatomic) NSString *tagFilter;
@property (strong, nonatomic) NSString *searchFilter;
@property (assign, nonatomic) BOOL searchByUser;
@property (strong, nonatomic) NSString *priceFilter;

@property (strong, nonatomic) NSArray* listings;
@property (strong, nonatomic) PFUser *user;

@property (strong, nonatomic) NSMutableArray* filteredListings;
@property (assign, nonatomic) NSInteger radiusLimit;
@property (assign, nonatomic) BOOL drivingDistance;
@property (assign, nonatomic) CLLocationCoordinate2D currentLocation;
@property (strong, nonatomic) NSMutableDictionary *distanceDictionary;

@property (assign, nonatomic) NSInteger defaultRadiusLimit;

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.defaultRadiusLimit = 30;
    
    self.radiusLimit = self.defaultRadiusLimit;
    self.drivingDistance = YES;
    
    self.distanceDictionary = [[NSMutableDictionary alloc] init];
    
    self.filterPopupView.alpha = 0;
    self.filterPopupView.layer.cornerRadius = 15;
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    self.blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    self.blurEffectView.frame = self.view.bounds;
    self.blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.blurEffectView.alpha = 0;
    [self.view insertSubview:self.blurEffectView atIndex:5];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.tableView.backgroundColor = [UIColor systemOrangeColor];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        
    self.searchField.text = @"";
    self.tagField.text = @"";
    self.priceControl.selectedSegmentIndex = 0;
    
    self.tagFilter = @"";
    self.searchFilter = @"";
    self.priceFilter = @"";
    
    self.user = PFUser.currentUser;
    
}

- (void) queryListings{
    PFQuery *query = [utils setUpQuery];
    
    if (![self.searchFilter isEqual:@""]){
        if (self.searchByUser)
            [query whereKey:@"sellerName" equalTo:self.searchFilter];
        else
            [query whereKey:@"name" containsString:self.searchFilter];
    }
    
    if(![self.tagFilter isEqual:@""])
        [query whereKey:@"tag" containsString:self.tagFilter];
    
    if([self.priceFilter isEqual:@"$"])
        [query whereKey:@"price" lessThan:[NSNumber numberWithInt:[self lowPrice]]];
    if([self.priceFilter isEqual:@"$$"]){
        [query whereKey:@"price" lessThan:[NSNumber numberWithInt:[self medPrice]]];
        [query whereKey:@"price" greaterThan:[NSNumber numberWithInt:[self lowPrice]]];
    }
    if([self.priceFilter isEqual:@"$$$"])
        [query whereKey:@"price" greaterThan:[NSNumber numberWithInt:[self medPrice]]];
    
    NSNumber *alreadySoldTag = [NSNumber numberWithBool:FALSE];
    NSNumber *inInventoryTag = [NSNumber numberWithBool:FALSE];
    [query whereKey:@"alreadySold" equalTo:alreadySoldTag];
    [query whereKey:@"inInventory" equalTo:inInventoryTag];
    [query whereKey:@"seller" notEqualTo:self.user];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *listings, NSError *error) {
        if (listings != nil) {
            self.listings = listings;
            [self assignDistance:self.drivingDistance];
            [self.tableView reloadData];
            return;
        }
        NSLog(@"%@", error.localizedDescription);
    }];
    [self.tableView reloadData];
}

- (IBAction)onBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onSearchItem:(id)sender {
    self.searchByUser = NO;
    self.searchFilter = self.searchField.text;
    
    [self setPriceRange];
    
    self.tagField.text = self.tagFilter;
    
    [self queryListings];
}

- (IBAction)onSearchUser:(id)sender {
    self.searchByUser = YES;
    self.searchFilter = self.searchField.text;
    
    [self setPriceRange];
    
    self.tagField.text = self.tagFilter;
    
    [self queryListings];
}

- (IBAction)onFilter:(id)sender {
    [self.view endEditing:YES];
    
    self.searchField.text = self.searchFilter;
    
    [self setPriceRange];
    
    self.tagFilter = self.tagField.text;
    
    [self setDistanceOrTime];
    
    if([self.radiusField.text isEqual:@""]) self.radiusLimit = self.defaultRadiusLimit;
    else self.radiusLimit = [self.radiusField.text intValue];
    
    [self queryListings];
    
    [UIView animateWithDuration:0.4 animations:^(void) {
        self.filterPopupView.alpha = 0;
        self.blurEffectView.alpha = 0;
    }];
}


- (void) setPriceRange{
    if ([self.priceControl selectedSegmentIndex] == 0) self.priceFilter = @"NONE";
    if ([self.priceControl selectedSegmentIndex] == 1) self.priceFilter = @"$";
    if ([self.priceControl selectedSegmentIndex] == 2) self.priceFilter = @"$$";
    if ([self.priceControl selectedSegmentIndex] == 3) self.priceFilter = @"$$$";
}

- (void) setDistanceOrTime{
    if ([self.distanceOrTimeControl selectedSegmentIndex] == 0) self.drivingDistance = YES;
    if ([self.distanceOrTimeControl selectedSegmentIndex] == 1) self.drivingDistance = NO;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SearchBuyCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchBuyCell"];
    
    Listing *listing = self.filteredListings[indexPath.section];
    
    cell.imageView.file = listing.image;
    [cell.imageView loadInBackground];
    cell.imageView.layer.cornerRadius = 15;
    
    cell.nameLabel.text = listing.name;
    cell.priceLabel.text = [@"$" stringByAppendingString:[listing.price stringValue]];
    
    cell.sellerLabel.text = listing.seller[@"username"];
    
    NSDate *creationDate = listing.createdAt;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd/yy"];
    
    NSString *stringFromDate = [formatter stringFromDate:creationDate];
    
    cell.dateLabel.text = stringFromDate;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.layer.cornerRadius = 15;
    cell.layer.masksToBounds = YES;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.filteredListings.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 12.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [UIView new];
    [headerView setBackgroundColor:[UIColor clearColor]];
    return headerView;
}

- (IBAction)onClear:(id)sender {
    self.searchField.text = @"";
    self.tagField.text = @"";
    self.priceControl.selectedSegmentIndex = 0;
    
    self.tagFilter = @"";
    self.searchFilter = @"";
    self.priceFilter = @"";
    
    self.distanceOrTimeControl.selectedSegmentIndex = 0;
    self.radiusField.text = @"";
    
    [self queryListings];
}

- (int) lowPrice{
    return 25;
}

- (int) medPrice{
    return 100;
}


- (void) assignDistance:(BOOL) drivingDistance{
    [utils getCurrentLocationWithCompletion:^(CLLocation * _Nonnull currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
        if (status == INTULocationStatusSuccess) {
            self.currentLocation = currentLocation.coordinate;
            
            for(Listing *listing in self.listings){
                CLLocationCoordinate2D destinationCoords = CLLocationCoordinate2DMake(listing.addressLat, listing.addressLong);
                
                [utils getDistanceFrom:self.currentLocation To:destinationCoords WithCompletion:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                    if(error != nil) NSLog(@"Error getting distance: %@", error.localizedDescription);
                    else{
                        NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                        double distance = 0;
                        if (drivingDistance)
                            distance = [utils kmToMiles:[NSString stringWithFormat:@"%@", dataDictionary[@"rows"][0][@"elements"][0][@"distance"][@"text"]]];
                        else{
                            NSString *timeString = [NSString stringWithFormat:@"%@", dataDictionary[@"rows"][0][@"elements"][0][@"duration"][@"text"]];
                            if([timeString rangeOfString:@"hr"].location == NSNotFound)
                                distance = [[NSString stringWithFormat:@"%@", dataDictionary[@"rows"][0][@"elements"][0][@"duration"][@"text"]] doubleValue];
                            else
                                distance = 60 * [[NSString stringWithFormat:@"%@", dataDictionary[@"rows"][0][@"elements"][0][@"duration"][@"text"]] doubleValue];
                        }
                                                
                        [self.distanceDictionary setObject:[NSNumber numberWithDouble:distance] forKey:listing.address];
                        NSLog(@"%@", self.distanceDictionary);
                        [self filterListings];
                    }
                }];
            }
        }
        else if (status == INTULocationStatusTimedOut) {

        }
        else {
            NSLog(@"Error getting current location: %ld", status);
        }
    }];
}

- (void) filterListings{
    self.filteredListings = [self.listings mutableCopy];
    for(NSString *address in self.distanceDictionary){
        if([[self.distanceDictionary objectForKey:address] doubleValue] > self.radiusLimit){
            for(Listing *listing in self.listings){
                if([listing.address isEqual:address]) [self.filteredListings removeObject:listing];
            }
        }
    }
    [self.tableView reloadData];
}

- (IBAction)onAdvancedFilters:(id)sender {
    [UIView animateWithDuration:0.4 animations:^(void) {
        self.filterPopupView.alpha = 1;
        self.blurEffectView.alpha = 1;
    }];
}

- (IBAction)onCancelFilter:(id)sender {
    [self.view endEditing:YES];
    [UIView animateWithDuration:0.4 animations:^(void) {
        self.filterPopupView.alpha = 0;
        self.blurEffectView.alpha = 0;
    }];
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
