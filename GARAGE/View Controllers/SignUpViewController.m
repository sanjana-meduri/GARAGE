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

@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
