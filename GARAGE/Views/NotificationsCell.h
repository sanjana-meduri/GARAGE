//
//  NotificationsCell.h
//  GARAGE
//
//  Created by Sanjana Meduri on 7/30/21.
//

#import <UIKit/UIKit.h>
@import Parse;
#import "Parse/Parse.h"

NS_ASSUME_NONNULL_BEGIN

@interface NotificationsCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet PFImageView *imageView;

@end

NS_ASSUME_NONNULL_END
