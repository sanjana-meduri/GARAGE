//
//  MyGarageViewController.m
//  GARAGE
//
//  Created by Sanjana Meduri on 7/12/21.
//

#import "MyGarageViewController.h"
#import "Parse/Parse.h"
#import "LoginViewController.h"
#import "SceneDelegate.h"


@interface MyGarageViewController ()
@property (weak, nonatomic) IBOutlet UILabel *userLabel;

@end

@implementation MyGarageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    PFUser *user = PFUser.currentUser;
    self.userLabel.text = user.username;
}

- (IBAction)onLogout:(id)sender {
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {}];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SceneDelegate *myDelegate = (SceneDelegate *)self.view.window.windowScene.delegate;
    LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"RootViewController"];
    myDelegate.window.rootViewController = loginViewController;
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
