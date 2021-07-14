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

@interface BuyViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *listings;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@end

@implementation BuyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
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
    
    
    NSNumber *alreadySoldTag = [NSNumber numberWithBool:FALSE];
    NSNumber *inInventoryTag = [NSNumber numberWithBool:FALSE];
    
    [query whereKey:@"alreadySold" equalTo:alreadySoldTag];
    [query whereKey:@"inInventory" equalTo:inInventoryTag];
    
    int numListings = 20;
    query.limit = numListings;

    [query findObjectsInBackgroundWithBlock:^(NSArray *listings, NSError *error) {
        if (listings != nil) {
            self.listings = listings;
            [self.tableView reloadData];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.listings.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    BuyCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BuyCell"];
    
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
