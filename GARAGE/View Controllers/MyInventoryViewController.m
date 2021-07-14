//
//  MyInventoryViewController.m
//  GARAGE
//
//  Created by Sanjana Meduri on 7/13/21.
//

#import "MyInventoryViewController.h"
#import "InventoryCell.h"
#import "Listing.h"
#import "Parse/Parse.h"

@interface MyInventoryViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *itemValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *itemTallyLabel;
@property (strong, nonatomic) IBOutlet UIView *view;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) NSArray *listings;
@property (strong, nonatomic) PFUser *user;
@property (assign, nonatomic) NSTimeInterval lastClick;
@property (strong, nonatomic) NSIndexPath *lastIndexPath;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@end

@implementation MyInventoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.user = PFUser.currentUser;
    
    [self queryListings];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl setTintColor:[UIColor blueColor]];
    [self.refreshControl addTarget:self action:@selector(queryListings) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
}

- (IBAction)onBack:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void) queryListings{
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
    
    [query whereKey:@"seller" equalTo:self.user];
    
    NSNumber *alreadySoldTag = [NSNumber numberWithBool:FALSE];
    NSNumber *inInventoryTag = [NSNumber numberWithBool:TRUE];
    
    [query whereKey:@"alreadySold" equalTo:alreadySoldTag];
    [query whereKey:@"inInventory" equalTo:inInventoryTag];
    
    int numListings = 20;
    query.limit = numListings;

    [query findObjectsInBackgroundWithBlock:^(NSArray *listings, NSError *error) {
        if (listings != nil) {
            self.listings = listings;
            
            self.itemTallyLabel.text = [[NSString stringWithFormat:@"%lu", self.listings.count] stringByAppendingString:@" total items in inventory"];
            
            double totalValue = 0;
            for (Listing* listing in self.listings){
                totalValue += [listing.price doubleValue];
            }
            self.itemValueLabel.text = [@"Total Item Value: $" stringByAppendingString: [NSString stringWithFormat:@"%.2f", totalValue]];
            
            [self.tableView reloadData];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    InventoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InventoryCell"];
    
    Listing *listing = self.listings[indexPath.row];
    
    cell.imageView.file = listing.image;
    [cell.imageView loadInBackground];
    
    cell.nameLabel.text = listing.name;
    cell.priceLabel.text = [@"$" stringByAppendingString:[listing.price stringValue]];
    
    return cell;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.listings.count;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSTimeInterval now = [[[NSDate alloc] init] timeIntervalSince1970];
    if ((now - self.lastClick < 0.3) && [indexPath isEqual:self.lastIndexPath]) {
        [self performSegueWithIdentifier:@"inventoryDetailsSegue" sender:nil];
    }
    self.lastClick = now;
    self.lastIndexPath = indexPath;
}

- (IBAction)onStartSale:(id)sender {
    for (Listing* listing in self.listings) {
        listing.inInventory = FALSE;
        
        [listing saveInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
                    if (succeeded) {
                        NSLog(@"successfully put item up for sale");
                        [self queryListings];
                        [self.tableView reloadData];
                    } else {
                        NSLog(@"Problem starting sale: %@", error.localizedDescription);
                    }}];
    }
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
