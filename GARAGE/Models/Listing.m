//
//  Listing.m
//  GARAGE
//
//  Created by Sanjana Meduri on 7/12/21.
//

#import "Listing.h"

@implementation Listing

@dynamic listingID;
@dynamic userID;
@dynamic seller;
@dynamic name;
@dynamic details;
@dynamic image;
@dynamic price;
@dynamic address;
@dynamic tag;
@dynamic condition;
@dynamic itemEmail;
@dynamic inInventory;
@dynamic alreadySold;

+ (nonnull NSString *)parseClassName {
    return @"Listing";
}

+ (void) postListing: ( UIImage * _Nullable )image withDescription: ( NSString * _Nullable )description withName: ( NSString * _Nullable )name withCondition:( NSString * _Nullable )condition withTag:( NSString * _Nullable )tag withAddress:( NSString * _Nullable )address withPrice:( NSNumber * _Nullable )price withCompletion: (PFBooleanResultBlock  _Nullable)completion{
    
    Listing *newListing = [Listing new];
    newListing.image = [self getPFFileFromImage:image];
    newListing.seller = [PFUser currentUser];
    newListing.details = description;
    newListing.name = name;
    newListing.price = price;
    newListing.address = address;
    newListing.tag = tag;
    newListing.condition = condition;
    newListing.inInventory = true;
    newListing.alreadySold = false;
    newListing.itemEmail = newListing.seller.email;
    
    [newListing saveInBackgroundWithBlock: completion];
    
}

+ (PFFileObject *)getPFFileFromImage: (UIImage * _Nullable)image {
     if (!image)
         return nil;
    
    NSData *imageData = UIImageJPEGRepresentation(image, 0.6);
    if (!imageData)
        return nil;
    
    return [PFFileObject fileObjectWithName:@"image.jpeg" data:imageData];
}




@end
