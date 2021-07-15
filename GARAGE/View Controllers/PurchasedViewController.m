//
//  PurchasedViewController.m
//  GARAGE
//
//  Created by Sanjana Meduri on 7/15/21.
//

#import "PurchasedViewController.h"
@import Parse;

@interface PurchasedViewController ()
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@end

@implementation PurchasedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    
    NSString *purchasedMessage = [NSString stringWithFormat:@"You have requested to purchase %@ for $%@ from %@. Contact %@ at %@ to finalize the payment details and pick up your item.", itemName, itemPrice, sellerName, sellerName, sellerEmail];
    
    self.messageLabel.text = purchasedMessage;
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
