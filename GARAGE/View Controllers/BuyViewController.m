//
//  BuyViewController.m
//  GARAGE
//
//  Created by Sanjana Meduri on 7/14/21.
//

#import "BuyViewController.h"
#import "BuyCell.h"
#import "Listing.h"
#import "Parse/Parse.h"
#import "BuyDetailsViewController.h"
#import "utils.h"
#import "BuyMapViewController.h"
#import "INTULocationManager/INTULocationManager.h"

@interface BuyViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *listings;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) PFUser *user;
@property (weak, nonatomic) IBOutlet UIView *popUpView;
@property (weak, nonatomic) IBOutlet UILabel *popupNameLabel;
@property (weak, nonatomic) IBOutlet PFImageView *popupImageView;
@property (weak, nonatomic) IBOutlet UILabel *popupSellerLabel;
@property (weak, nonatomic) IBOutlet UILabel *popupPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *popupDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *popupDecsriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *popupConditionLabel;
@property (weak, nonatomic) IBOutlet UILabel *popupAddressLabel;
@property (strong, nonatomic) UIVisualEffectView *blurEffectView;
@property (weak, nonatomic) IBOutlet UIView *buyPopupView;
@property (weak, nonatomic) IBOutlet UILabel *purchasedMessageLabel;
@property (strong, nonatomic) Listing *listing;
@property (assign, nonatomic) double defaultDistance;
@property (assign, nonatomic) CLLocationCoordinate2D currentLocation;

@end

@implementation BuyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.defaultDistance = 20;
    
    self.popUpView.alpha = 0;
    self.buyPopupView.alpha = 0;
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    self.blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    self.blurEffectView.frame = self.view.bounds;
    self.blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.blurEffectView.alpha = 0;
    [self.view insertSubview:self.blurEffectView atIndex:1];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.tableView.backgroundColor = [UIColor systemBlueColor];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    self.user = PFUser.currentUser;
        
    [self getCurrentLocation];

    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl setTintColor:[UIColor whiteColor]];
    [self.refreshControl addTarget:self action:@selector(queryListings) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
}

- (IBAction)onBack:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void) queryListings{
    PFQuery *query = [utils setUpQuery];
    
    NSNumber *alreadySoldTag = [NSNumber numberWithBool:FALSE];
    NSNumber *inInventoryTag = [NSNumber numberWithBool:FALSE];
    
    [query whereKey:@"alreadySold" equalTo:alreadySoldTag];
    [query whereKey:@"inInventory" equalTo:inInventoryTag];
    [query whereKey:@"seller" notEqualTo:self.user];

    [query findObjectsInBackgroundWithBlock:^(NSArray *listings, NSError *error) {
        if (listings != nil) {
            NSMutableArray *betaFilteredListings = [[NSMutableArray alloc] init];
            NSMutableArray *__strong*filteredListings;
            [utils filterListings:listings byDistance:self.defaultDistance fromCurrentLocation:self.currentLocation into:&filteredListings];
            self.listings = *filteredListings;
            [self.tableView reloadData];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    BuyCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BuyCell"];
    
    Listing *listing = self.listings[indexPath.section];
    
    cell.imageView.file = listing.image;
    [cell.imageView loadInBackground];
    cell.imageView.layer.cornerRadius = 15;
    cell.imageView.layer.masksToBounds = YES;
    
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
    return self.listings.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 12.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [UIView new];
    [headerView setBackgroundColor:[UIColor clearColor]];
    return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.listing = self.listings[indexPath.section];
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
    
    self.popUpView.layer.cornerRadius = 15;
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onDoubleTap)];
    doubleTap.numberOfTapsRequired = 2;
    [self.popupAddressLabel addGestureRecognizer:doubleTap];
    
    [UIView animateWithDuration:0.4 animations:^(void) {
        self.popUpView.alpha = 1;
        self.blurEffectView.alpha = 1;
    }];
}

- (IBAction)popupOnClose:(id)sender {
    [UIView animateWithDuration:0.4 animations:^(void) {
        self.popUpView.alpha = 0;
        self.buyPopupView.alpha = 0;
        self.blurEffectView.alpha = 0;
    }];
}

- (IBAction)popupOnBuy:(id)sender {
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
    self.buyPopupView.layer.cornerRadius = 15;
    
    [UIView animateWithDuration:0.4 animations:^(void) {
        self.buyPopupView.alpha = 1;
        self.blurEffectView.alpha = 1;
    }];
}

- (IBAction)buyPopupOnClose:(id)sender {
    [UIView animateWithDuration:0.4 animations:^(void) {
        self.popUpView.alpha = 0;
        self.buyPopupView.alpha = 0;
        self.blurEffectView.alpha = 0;
    }];
}

- (void) onDoubleTap{
    [self performSegueWithIdentifier:@"mapSegue" sender:nil];
}

#pragma mark - filtering by distance
- (void) getCurrentLocation{
    [utils getCurrentLocationWithCompletion:^(CLLocation * _Nonnull currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
        if (status == INTULocationStatusSuccess) {
            self.currentLocation = currentLocation.coordinate;
            [self queryListings];
        }
        else if (status == INTULocationStatusTimedOut) {

        }
        else {
            NSLog(@"Error getting current location: %ld", status);
        }
    }];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqual:@"buyDetailsSegue"]){
        BuyDetailsViewController *detailsViewController = [segue destinationViewController];
        
        UITableViewCell *tappedCell = sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell];
        
        Listing *tappedListing = self.listings[indexPath.section];
        detailsViewController.listing = tappedListing;
    }
    
    if ([segue.identifier isEqual:@"mapSegue"]){
        BuyMapViewController *mapViewController = [segue destinationViewController];
        mapViewController.listing = self.listing;
    }
}


@end
