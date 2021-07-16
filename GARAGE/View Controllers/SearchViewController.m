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

@property (strong, nonatomic) NSString *tagFilter;
@property (strong, nonatomic) NSString *searchFilter;
@property (assign, nonatomic) BOOL searchByUser;
@property (strong, nonatomic) NSString *priceFilter;

@property (strong, nonatomic) NSArray* listings;
@property (strong, nonatomic) PFUser *user;

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
        
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
    self.searchField.text = self.searchFilter;
    
    [self setPriceRange];
    
    self.tagFilter = self.tagField.text;
    
    [self queryListings];
}


- (void) setPriceRange{
    if ([self.priceControl selectedSegmentIndex] == 0) self.priceFilter = @"NONE";
    if ([self.priceControl selectedSegmentIndex] == 1) self.priceFilter = @"$";
    if ([self.priceControl selectedSegmentIndex] == 2) self.priceFilter = @"$$";
    if ([self.priceControl selectedSegmentIndex] == 3) self.priceFilter = @"$$$";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.listings.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SearchBuyCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchBuyCell"];
    
    Listing *listing = self.listings[indexPath.row];
    
    cell.imageView.file = listing.image;
    [cell.imageView loadInBackground];
    
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

- (IBAction)onClear:(id)sender {
    self.searchField.text = @"";
    self.tagField.text = @"";
    self.priceControl.selectedSegmentIndex = 0;
    
    self.tagFilter = @"";
    self.searchFilter = @"";
    self.priceFilter = @"";
    
    [self queryListings];
}

- (int) lowPrice{
    return 25;
}

- (int) medPrice{
    return 100;
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
