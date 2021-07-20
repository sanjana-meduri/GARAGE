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

+ (void) geocodeRequest: (NSString*)address WithCompletion:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completion{
    NSString *urlString = [[@"https://maps.googleapis.com/maps/api/geocode/json?address=" stringByAppendingString:address] stringByAppendingString:@"&key=AIzaSyB3uTAyKC64dPGL_nnZpz0KPcm0PpFXyNc"];
    
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *requestUrl = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:requestUrl cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:completion];
    [task resume];
}

@end
