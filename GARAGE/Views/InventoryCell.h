//
//  InventoryCell.h
//  GARAGE
//
//  Created by Sanjana Meduri on 7/13/21.
//

#import <UIKit/UIKit.h>
#import "InventoryCell.h"
@import Parse;


NS_ASSUME_NONNULL_BEGIN

@interface InventoryCell : UITableViewCell
@property (weak, nonatomic) IBOutlet PFImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

@end

NS_ASSUME_NONNULL_END
