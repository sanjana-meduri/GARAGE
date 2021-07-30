//
//  NotificationsViewController.m
//  GARAGE
//
//  Created by Sanjana Meduri on 7/30/21.
//

#import "NotificationsViewController.h"
#import "Parse/Parse.h"
@import Parse;
#import "utils.h"
#import "NotificationsCell.h"

@interface NotificationsViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *listings;
@property (strong, nonatomic) PFUser *user;
@property (strong, nonatomic) UIRefreshControl *refreshControl;


@end

@implementation NotificationsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.user = PFUser.currentUser;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl setTintColor:[UIColor blueColor]];
    [self.refreshControl addTarget:self action:@selector(queryListings) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
    
    [self queryListings];
}

- (void) queryListings{
    PFQuery *query = [utils setUpQuery];
    
    [query orderByDescending:@"updatedAt"];
    
    [query whereKey:@"seller" equalTo:self.user];
    
    NSNumber *alreadySoldTag = [NSNumber numberWithBool:TRUE];
    
    [query whereKey:@"alreadySold" equalTo:alreadySoldTag];

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
    NotificationsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NotificationsCell"];
    Listing *listing = self.listings[indexPath.row];
    
    NSString *messageString = [NSString stringWithFormat:@"%@ (%@) \nPurchased %@", listing.buyerName, listing.buyerEmail, listing.name];
    cell.messageLabel.text = messageString;
    
    if(listing.newNotif) cell.backgroundColor = [UIColor colorWithRed: 0.75 green: 0.91 blue: 0.91 alpha: 1.00];
    else cell.backgroundColor = [UIColor whiteColor];
    
    listing.newNotif = FALSE;
    [listing saveInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
                if (succeeded) {
                    NSLog(@"successfully sold item");
                } else {
                    NSLog(@"Problem selling item: %@", error.localizedDescription);
                }}];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.listings.count;
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
