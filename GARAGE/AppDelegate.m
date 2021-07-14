//
//  AppDelegate.m
//  GARAGE
//
//  Created by Sanjana Meduri on 7/12/21.
//

#import "AppDelegate.h"
#import "Parse/Parse.h"
@import GoogleMaps;

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    ParseClientConfiguration *config = [ParseClientConfiguration  configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration) {
            configuration.applicationId = @"0fYrDl0XdBuWoFWZBMDbGT0WNiUd9cnBznLRD4bB";
            configuration.clientKey = @"9HwuDAqFeLQZU8eVpUS3T2JQDbXDVgukzWMDFtvk";
            configuration.server = @"https://parseapi.back4app.com";
        }];

        [Parse initializeWithConfiguration:config];
    
    [GMSServices provideAPIKey:@"AIzaSyB3uTAyKC64dPGL_nnZpz0KPcm0PpFXyNc"];
    //[GMSPlacesClient provideAPIKey:@"AIzaSyB3uTAyKC64dPGL_nnZpz0KPcm0PpFXyNc"];


    
    return YES;
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end
