//
//  utils.m
//  GARAGE
//
//  Created by Sanjana Meduri on 7/16/21.
//

#import "utils.h"

@implementation utils

int numListings = 20;

+ (PFQuery*) setUpQuery{
    PFQuery *query = [PFQuery queryWithClassName:@"Listing"];
    [query orderByDescending:@"createdAt"];
    [query includeKey:@"seller"];
    [query includeKey:@"description"];
    [query includeKey:@"alreadySold"];
    [query includeKey:@"inInventory"];
    [query includeKey:@"createdAt"];
    [query includeKey:@"tag"];
    [query includeKey:@"name"];
    [query includeKey:@"condition"];
    [query includeKey:@"image"];
    [query includeKey:@"address"];
    [query includeKey:@"price"];
    [query includeKey:@"itemEmail"];
    
    query.limit = numListings;
    
    return query;
}

@end
