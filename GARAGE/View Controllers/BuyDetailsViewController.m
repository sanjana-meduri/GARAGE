//
//  BuyDetailsViewController.m
//  GARAGE
//
//  Created by Sanjana Meduri on 7/14/21.
//

#import "BuyDetailsViewController.h"
@import Parse;
#import <UIKit/UIKit.h>
#import "Listing.h"
#import "NSDate+DateTools.h"
#import "BuyMapViewController.h"

@interface BuyDetailsViewController ()
@property (weak, nonatomic) IBOutlet PFImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *sellerLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *conditionLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;

@end

@implementation BuyDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self populateDetails];
}

- (void) populateDetails{
    self.nameLabel.text = self.listing.name;
    self.sellerLabel.text = self.listing.seller[@"username"];
    self.priceLabel.text = [@"$" stringByAppendingString:[self.listing.price stringValue]];
    
    NSDate *creationDate = self.listing.createdAt;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd/yy"];
    NSString *stringFromDate = [formatter stringFromDate:creationDate];
    
    self.dateLabel.text = stringFromDate;
        
    self.descriptionLabel.text = self.listing.details;
    self.conditionLabel.text = self.listing.condition;
    self.addressLabel.text = self.listing.address;
    
    self.imageView.file = self.listing.image;
    [self.imageView loadInBackground];

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
