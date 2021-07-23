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
#import "utils.h"
@import Parse;

@interface MyInventoryViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *itemValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *itemTallyLabel;
@property (strong, nonatomic) IBOutlet UIView *view;
@property (strong, nonatomic) NSArray *listings;
@property (strong, nonatomic) PFUser *user;
@property (assign, nonatomic) NSTimeInterval lastClick;
@property (strong, nonatomic) NSIndexPath *lastIndexPath;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property (weak, nonatomic) IBOutlet UIView *popupEditView;
@property (weak, nonatomic) IBOutlet PFImageView *popupImageView;
@property (weak, nonatomic) IBOutlet UITextField *popupNameField;
@property (weak, nonatomic) IBOutlet UITextField *popupPriceField;
@property (weak, nonatomic) IBOutlet UITextView *popupDescriptionView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *popupConditionControl;
@property (weak, nonatomic) IBOutlet UITextField *popupTagField;
@property (weak, nonatomic) IBOutlet UITextField *popupAddressField;
@property (strong, nonatomic) UIVisualEffectView *blurEffectView;

@property (strong, nonatomic) Listing* listing;


@end

@implementation MyInventoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.tableView.backgroundColor = [UIColor systemYellowColor];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    self.user = PFUser.currentUser;
    
    self.popupEditView.alpha = 0;
    self.popupEditView.layer.cornerRadius = 15;
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    self.blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    self.blurEffectView.frame = self.view.bounds;
    self.blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.blurEffectView.alpha = 0;
    [self.view insertSubview:self.blurEffectView atIndex:2];

    
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
    PFQuery *query = [utils setUpQuery];
    
    [query whereKey:@"seller" equalTo:self.user];
    
    NSNumber *alreadySoldTag = [NSNumber numberWithBool:FALSE];
    NSNumber *inInventoryTag = [NSNumber numberWithBool:TRUE];
    
    [query whereKey:@"alreadySold" equalTo:alreadySoldTag];
    [query whereKey:@"inInventory" equalTo:inInventoryTag];

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
    
    Listing *listing = self.listings[indexPath.section];
    
    cell.imageView.file = listing.image;
    [cell.imageView loadInBackground];
    cell.imageView.layer.cornerRadius = 15;
    
    cell.nameLabel.text = listing.name;
    cell.priceLabel.text = [@"$" stringByAppendingString:[listing.price stringValue]];
    
    cell.editButton.tag = indexPath.section;
    [cell.editButton addTarget:self action:@selector(editCell:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.deleteButton.tag = indexPath.section;
    [cell.deleteButton addTarget:self action:@selector(deleteCell:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.startSaleButton.tag = indexPath.section;
    [cell.startSaleButton addTarget:self action:@selector(startSaleCell:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
    
}

- (void) editCell: (UIButton *) sender{
    self.listing = self.listings[sender.tag];
    
    self.popupNameField.text = self.listing.name;
    self.popupPriceField.text = [NSString stringWithFormat:@"%.2f", [self.listing.price doubleValue]];
    self.popupAddressField.text = self.listing.address;
    self.popupDescriptionView.text = self.listing.details;
    self.popupTagField.text = self.listing.tag;
    self.popupImageView.layer.cornerRadius = 15;
    self.popupImageView.file = self.listing.image;
    [self.popupImageView loadInBackground];
    
    if([self.listing.condition isEqual:@"Okay"])
        self.popupConditionControl.selectedSegmentIndex = 0;
    else if([self.listing.condition isEqual:@"Good"])
        self.popupConditionControl.selectedSegmentIndex = 1;
    if([self.listing.condition isEqual:@"Great"])
        self.popupConditionControl.selectedSegmentIndex = 2;
    
    [UIView animateWithDuration:0.4 animations:^(void) {
        self.popupEditView.alpha = 1;
        self.blurEffectView.alpha = 1;
    }];
}

- (void) deleteCell: (UIButton *) sender{
    Listing *listing = self.listings[sender.tag];
    [listing deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            NSLog(@"successfully deleted item");
            [self queryListings];
            [self.tableView reloadData];
        } else {
            NSLog(@"Problem deleting item: %@", error.localizedDescription);
        }
    }];
}

- (void) startSaleCell: (UIButton *) sender{
    Listing *listing = self.listings[sender.tag];
    listing.inInventory = FALSE;
    [listing saveInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
                if (succeeded) {
                    NSLog(@"successfully put the item up for sale");
                    [self queryListings];
                    [self.tableView reloadData];
                } else {
                    NSLog(@"Problem starting sale on item: %@", error.localizedDescription);
                }}];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
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

- (IBAction)popupTakePicture:(id)sender {
    [self getPicture:YES];
}

- (IBAction)popupUploadPicture:(id)sender {
    [self getPicture:NO];
}

- (IBAction)popupCancel:(id)sender {
    [UIView animateWithDuration:0.4 animations:^(void) {
        self.popupEditView.alpha = 0;
        self.blurEffectView.alpha = 0;
    }];
    [self.view endEditing:YES];
}

- (IBAction)popupSave:(id)sender {
    self.listing.name = self.popupNameField.text;
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    NSNumber *itemPrice = [formatter numberFromString:self.popupPriceField.text];
    self.listing.price = itemPrice;
    
    self.listing.details = self.popupDescriptionView.text;
    self.listing.tag = self.popupTagField.text;
    self.listing.address = self.popupAddressField.text;
    
    self.listing.image = [Listing getPFFileFromImage:self.popupImageView.image];
    
    if (self.popupConditionControl.selectedSegmentIndex == 0)
        self.listing.condition = @"Okay";
    else if (self.popupConditionControl.selectedSegmentIndex == 1)
        self.listing.condition = @"Good";
    else if (self.popupConditionControl.selectedSegmentIndex == 2)
        self.listing.condition = @"Great";
    
    [self.listing saveInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
                if (succeeded) {
                    NSLog(@"successfully updated item");
                    [self queryListings];
                    [self.tableView reloadData];
                } else {
                    NSLog(@"Problem updating item: %@", error.localizedDescription);
                }}];
    
    [UIView animateWithDuration:0.4 animations:^(void) {
        self.popupEditView.alpha = 0;
        self.blurEffectView.alpha = 0;
    }];
    [self.view endEditing:YES];
}

- (void) getPicture:(BOOL)willTakePicture{
    UIImagePickerController *imagePickerVC = [UIImagePickerController new];
    imagePickerVC.delegate = self;
    imagePickerVC.allowsEditing = YES;
    imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    if (willTakePicture){
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
            imagePickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
        else
            NSLog(@"Camera 🚫 available so we will use photo library instead");
    }
    
    [self presentViewController:imagePickerVC animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *originalImage = info[UIImagePickerControllerOriginalImage];
    UIImage *editedImage = info[UIImagePickerControllerEditedImage];

    CGSize newSize = CGSizeMake(300, 300);
    UIImage *resizedImage = [self resizeImage:editedImage withSize:newSize];
    
    [self.popupImageView setImage:resizedImage];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UIImage *)resizeImage:(UIImage *)image withSize:(CGSize)size {
    UIImageView *resizeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    
    resizeImageView.contentMode = UIViewContentModeScaleAspectFill;
    resizeImageView.image = image;
    
    UIGraphicsBeginImageContext(size);
    [resizeImageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
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
