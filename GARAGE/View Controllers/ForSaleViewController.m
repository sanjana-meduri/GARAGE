//
//  ForSaleViewController.m
//  GARAGE
//
//  Created by Sanjana Meduri on 7/13/21.
//

#import "ForSaleViewController.h"
#import "ForSaleCell.h"
#import "Listing.h"
#import "Parse/Parse.h"

@interface ForSaleViewController ()  <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *listings;
@property (strong, nonatomic) PFUser *user;
@property (strong, nonatomic) UIRefreshControl *refreshControl;


@end

@implementation ForSaleViewController

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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ForSaleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ForSaleCell"];
    
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
