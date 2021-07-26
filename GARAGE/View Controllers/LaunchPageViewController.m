//
//  LaunchPageViewController.m
//  GARAGE
//
//  Created by Sanjana Meduri on 7/26/21.
//

#import "LaunchPageViewController.h"

@interface LaunchPageViewController ()
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *signupButton;
@property (weak, nonatomic) IBOutlet UIImageView *logoImageVIew;

@end

@implementation LaunchPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];

    gradient.frame = self.view.bounds;
    UIColor *lightColor = [UIColor colorWithRed: 0.75 green: 0.91 blue: 0.91 alpha: 1.00];
    UIColor *darkColor = [UIColor colorWithRed: 0.38 green: 0.71 blue: 0.80 alpha: 1.00];
    gradient.colors = @[(id)lightColor.CGColor, (id)darkColor.CGColor];

    [self.view.layer insertSublayer:gradient atIndex:0];
    
    self.loginButton.layer.cornerRadius = 15;
    self.signupButton.layer.cornerRadius = 15;
    self.logoImageVIew.layer.cornerRadius = 15;
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
