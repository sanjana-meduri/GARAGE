//
//  LoginViewController.m
//  GARAGE
//
//  Created by Sanjana Meduri on 7/12/21.
//

#import "LoginViewController.h"
#import "Parse/Parse.h"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *backButton;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];

    gradient.frame = self.view.bounds;
    UIColor *lightColor = [UIColor colorWithRed: 0.75 green: 0.91 blue: 0.91 alpha: 1.00];
    UIColor *darkColor = [UIColor colorWithRed: 0.38 green: 0.71 blue: 0.80 alpha: 1.00];
    gradient.colors = @[(id)lightColor.CGColor, (id)darkColor.CGColor];

    [self.view.layer insertSublayer:gradient atIndex:0];
    
    self.logoImageView.layer.cornerRadius = 15;
    self.loginButton.layer.cornerRadius = 15;
    self.backButton.layer.cornerRadius = 15;
}

- (IBAction)onLogin:(id)sender {
    [self checkEmptyFields:NO];
    
    NSString *username = self.usernameField.text;
    NSString *password = self.passwordField.text;
    
    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser * user, NSError *  error) {
        if (error != nil) {
            NSLog(@"User log in failed: %@", error.localizedDescription);
            [self failedAttempt:[NSString stringWithFormat:(@"Login Failed: %@", error.localizedDescription)]];
        } else {
            NSLog(@"User logged in successfully");
            [self performSegueWithIdentifier:@"loginSegue" sender:nil];
        }
    }];
}

-(void) checkEmptyFields:(BOOL)newUser{
    if (!newUser && ([self.usernameField.text isEqual:@""] || [self.passwordField.text isEqual:@""]))
        [self failedAttempt:@"Username/password is empty"];
    if (newUser && ([self.usernameField.text isEqual:@""] || [self.passwordField.text isEqual:@""] || [self.emailField.text isEqual:@""]))
        [self failedAttempt:@"You must fill out all the fields when signing up"];
}

- (void) failedAttempt:(NSString*) errorMessage{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Failed Attempt" message:errorMessage preferredStyle:(UIAlertControllerStyleAlert)];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}];
    [alert addAction:cancelAction];

    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
    [alert addAction:okAction];
    
    [self presentViewController:alert animated:YES completion:^{}];
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
