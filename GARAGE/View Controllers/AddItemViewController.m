//
//  AddItemViewController.m
//  GARAGE
//
//  Created by Sanjana Meduri on 7/12/21.
//

#import "AddItemViewController.h"
#import "Listing.h"

@interface AddItemViewController () <UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *priceField;
@property (weak, nonatomic) IBOutlet UITextView *descriptionView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *conditionControl;
@property (weak, nonatomic) IBOutlet UITextField *tagField;
@property (weak, nonatomic) IBOutlet UITextField *addressField;

@end

@implementation AddItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.imageView.image = nil;
    self.descriptionView.delegate = @"";
    
    self.descriptionView.delegate = self;
    self.descriptionView.layer.borderWidth = 2.0f;
    self.descriptionView.layer.borderColor = [[UIColor grayColor] CGColor];
    self.descriptionView.layer.cornerRadius = 8;
    
    //stack overflow
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:gestureRecognizer];
    gestureRecognizer.cancelsTouchesInView = NO;
}

- (void)dismissKeyboard
{
     [self.view endEditing:YES];
}

- (IBAction)onTakePicture:(id)sender {
    [self getPicture:YES];
}

- (IBAction)onUploadImage:(id)sender {
    [self getPicture:NO];
}

- (IBAction)onCancel:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (IBAction)onAddItem:(id)sender {
    UIImage *itemImage = self.imageView.image;
    NSString *itemDescription = self.descriptionView.text;
    NSString *itemName = self.nameField.text;
    NSString *itemTag = self.tagField.text;
    NSString *itemAddress = self.addressField.text;
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    NSNumber *itemPrice = [formatter numberFromString:self.priceField.text];
    
    NSString *itemCondition = @"Okay";
    if (self.conditionControl.selectedSegmentIndex == 1)
        itemCondition = @"Good";
    if (self.conditionControl.selectedSegmentIndex == 2)
        itemCondition = @"Great";
    
    [Listing postListing:itemImage withDescription:itemDescription withName:itemName withCondition:itemCondition withTag:itemTag withAddress:itemAddress withPrice:itemPrice withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded){
            NSLog(@"posted listing successfuly");
            [self dismissViewControllerAnimated:true completion:nil];
        }
        else{
            NSLog(@"Error posting listin: %@", error.localizedDescription);
        }
    }];
        
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
    
    [self.imageView setImage:resizedImage];
    
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
