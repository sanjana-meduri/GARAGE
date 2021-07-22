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
#import "BuyMapViewController.h"
#import "SearchBuyCell.h"

@interface SearchViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITextField *searchField;
@property (weak, nonatomic) IBOutlet UITextField *tagField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *priceControl;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) UIRefreshControl *refreshControl;

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

@property (weak, nonatomic) IBOutlet UIView *popupDetailsView;
@property (weak, nonatomic) IBOutlet PFImageView *popupImageView;
@property (weak, nonatomic) IBOutlet UILabel *popupNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *popupSellerLabel;
@property (weak, nonatomic) IBOutlet UILabel *popupPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *popupDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *popupDecsriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *popupConditionLabel;
@property (weak, nonatomic) IBOutlet UILabel *popupAddressLabel;
@property (strong, nonatomic) Listing *listing;
@property (strong, nonatomic) UIVisualEffectView *detailsBlurEffectView;
@property (weak, nonatomic) IBOutlet UIView *popupPurchasedView;
@property (weak, nonatomic) IBOutlet UILabel *purchasedMessageLabel;

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
    [self.view insertSubview:self.blurEffectView atIndex:7];
    
    self.popupDetailsView.alpha = 0;
    self.popupPurchasedView.alpha = 0;
    
    UIBlurEffect *detailsBlurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    self.detailsBlurEffectView = [[UIVisualEffectView alloc] initWithEffect:detailsBlurEffect];
    self.detailsBlurEffectView.frame = self.view.bounds;
    self.detailsBlurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.detailsBlurEffectView.alpha = 0;
    [self.view insertSubview:self.detailsBlurEffectView atIndex:6];
    
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
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl setTintColor:[UIColor whiteColor]];
    [self.refreshControl addTarget:self action:@selector(queryListings) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
    
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
    [self.refreshControl endRefreshing];
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
    
    self.drivingDistance = YES;
    self.radiusLimit = self.defaultRadiusLimit;
    
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

- (IBAction)onPopupClose:(id)sender {
    [UIView animateWithDuration:0.4 animations:^(void) {
        self.popupDetailsView.alpha = 0;
        self.popupPurchasedView.alpha = 0;
        self.detailsBlurEffectView.alpha = 0;
    }];
}

- (IBAction)onPopupBuy:(id)sender {
    self.listing.alreadySold = TRUE;
    [self.listing saveInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
                if (succeeded) {
                    NSLog(@"successfully sold item");
                } else {
                    NSLog(@"Problem selling item: %@", error.localizedDescription);
                }}];
    
    NSString *itemName = self.listing.name;
    NSString *itemPrice = [self.listing.price stringValue];
    NSString *itemAddress = self.listing.address;
    NSString *sellerName = self.listing.seller[@"username"];
    NSString *sellerEmail = self.listing.itemEmail;
    
    NSString *purchasedMessage = [NSString stringWithFormat:@"You have requested to purchase %@ for $%@ from %@. Contact %@ at %@ to finalize the payment details and pick up your item from %@.", itemName, itemPrice, sellerName, sellerName, sellerEmail, itemAddress];
    
    self.purchasedMessageLabel.text = purchasedMessage;
    self.popupPurchasedView.layer.cornerRadius = 15;

    [UIView animateWithDuration:0.4 animations:^(void) {
        self.popupPurchasedView.alpha = 1;
        self.detailsBlurEffectView.alpha = 1;
    }];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.listing = self.filteredListings[indexPath.section];
    self.popupNameLabel.text = self.listing.name;
    
    self.popupSellerLabel.text = self.listing.seller[@"username"];
    self.popupPriceLabel.text = [@"$" stringByAppendingString:[self.listing.price stringValue]];
    
    NSDate *creationDate = self.listing.createdAt;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd/yy"];
    NSString *stringFromDate = [formatter stringFromDate:creationDate];
    
    self.popupDateLabel.text = stringFromDate;
        
    self.popupDecsriptionLabel.text = self.listing.details;
    self.popupConditionLabel.text = self.listing.condition;
    self.popupAddressLabel.text = self.listing.address;
    
    self.popupImageView.layer.cornerRadius = 15;
    self.popupImageView.file = self.listing.image;
    [self.popupImageView loadInBackground];
    
    self.popupDetailsView.layer.cornerRadius = 15;
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onDoubleTap)];
    doubleTap.numberOfTapsRequired = 2;
    [self.popupAddressLabel addGestureRecognizer:doubleTap];
    
    [UIView animateWithDuration:0.4 animations:^(void) {
        self.popupDetailsView.alpha = 1;
        self.detailsBlurEffectView.alpha = 1;
    }];
}

- (void) onDoubleTap{
    [self performSegueWithIdentifier:@"mapSegue" sender:nil];
}

- (IBAction)onPurchasedMessageClose:(id)sender {
    [UIView animateWithDuration:0.4 animations:^(void) {
        self.popupPurchasedView.alpha = 0;
        self.popupDetailsView.alpha = 0;
        self.detailsBlurEffectView.alpha = 0;
    }];
    
    [self queryListings];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqual:@"mapSegue"]){
        BuyMapViewController *mapViewController = [segue destinationViewController];
        mapViewController.listing = self.listing;
    }
}


@end
