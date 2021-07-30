//
//  Listing.h
//  GARAGE
//
//  Created by Sanjana Meduri on 7/12/21.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface Listing : PFObject<PFSubclassing>

@property (nonatomic, strong) NSString *listingID;
@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) PFUser *seller;

@property (nonatomic, strong) NSString *details;
@property (nonatomic, assign) BOOL alreadySold;
@property (nonatomic, assign) BOOL inInventory;
@property (nonatomic, assign) BOOL newNotif;
@property (nonatomic, strong) NSString *tag;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *condition;
@property (nonatomic, strong) PFFileObject *image;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *itemEmail;
@property (nonatomic, strong) NSNumber *price;
@property (nonatomic, strong) NSString *sellerName;
@property (nonatomic, assign) double addressLat;
@property (nonatomic, assign) double addressLong;

+ (void) postListing: ( UIImage * _Nullable )image withDescription: ( NSString * _Nullable )description withName: ( NSString * _Nullable )name withCondition:( NSString * _Nullable )condition withTag:( NSString * _Nullable )tag withAddress:( NSString * _Nullable )address withPrice:( NSNumber * _Nullable )price withCompletion: (PFBooleanResultBlock  _Nullable)completion;

+ (PFFileObject *)getPFFileFromImage: (UIImage * _Nullable)image;

@end

NS_ASSUME_NONNULL_END

