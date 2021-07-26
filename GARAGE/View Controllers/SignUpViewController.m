//
//  SignUpViewController.m
//  GARAGE
//
//  Created by Sanjana Meduri on 7/15/21.
//

#import "SignUpViewController.h"
#import "Parse/Parse.h"

@interface SignUpViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameLabel;
@property (weak, nonatomic) IBOutlet UITextField *passwordLabel;
@property (weak, nonatomic) IBOutlet UITextField *emailLabel;
@property (weak, nonatomic) IBOutlet UIButton *signupButton;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;

@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];

    gradient.frame = self.view.bounds;
    UIColor *lightColor = [UIColor colorWithRed: 0.75 green: 0.91 blue: 0.91 alpha: 1.00];
    UIColor *darkColor = [UIColor colorWithRed: 0.38 green: 0.71 blue: 0.80 alpha: 1.00];
    gradient.colors = @[(id)lightColor.CGColor, (id)darkColor.CGColor];

    [self.view.layer insertSublayer:gradient atIndex:0];
    
    self.backButton.layer.cornerRadius = 15;
    self.signupButton.layer.cornerRadius = 15;
    self.logoImageView.layer.cornerRadius = 15;
}

- (IBAction)onSignUp:(id)sender {
    [self checkEmptyFields:YES];
    
    PFUser *newUser = [PFUser user];
    
    newUser.username = self.usernameLabel.text;
    newUser.password = self.passwordLabel.text;
    newUser.email = self.emailLabel.text;
    
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
        if (error != nil) {
            NSLog(@"Error: %@", error.localizedDescription);
            [self failedAttempt:[NSString stringWithFormat:(@"Error: %@", error.localizedDescription)]];
        } else {
            NSLog(@"User registered successfully");
            [self performSegueWithIdentifier:@"signUpSegue" sender:nil];
        }
    }];
}

-(void) checkEmptyFields:(BOOL)newUser{
    if (!newUser && ([self.usernameLabel.text isEqual:@""] || [self.passwordLabel.text isEqual:@""]))
        [self failedAttempt:@"Username/password is empty"];
    if (newUser && ([self.usernameLabel.text isEqual:@""] || [self.passwordLabel.text isEqual:@""] || [self.emailLabel.text isEqual:@""]))
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
