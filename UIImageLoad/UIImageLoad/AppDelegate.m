//
//  AppDelegate.m
//  UIImageLoad
//
//  Created by Mo DeJong on 10/16/16.
//  Copyright © 2016 HelpURock. All rights reserved.
//

#import "AppDelegate.h"

#if defined(PNGSQUARED)
@import PNGSquared;
@import CoreGraphics;
@import ImageIO;
@import QuartzCore;
@import MobileCoreServices;
#import "UIImage+PNGSquared.h"
#endif // PNGSQUARED

@interface AppDelegate ()

#if defined(PNGSQUARED)
// A ref counted dictionary is required to hold active refs to UIImage objects
// cached by the custom UIImage overloaded methods.

@property (nonatomic, retain) NSMutableDictionary *imageCache;

#endif // PNGSQUARED

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  // Override point for customization after application launch.
  
#if defined(PNGSQUARED)
  // Invoke setup method to swap in custom impl of [UIImage imageNamed:]
  
  self.imageCache = [NSMutableDictionary dictionary];
  [UIImage setupAppInstance:self.imageCache];
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(allReadyNotification:)
                                               name:UIImagePNGSquaredAllReadyNotification
                                             object:nil];
#else
  // nop
#endif // PNGSQUARED
  
  return YES;
}

#if defined(PNGSQUARED)

// This notification is delivered when the main bundle has been scanned and normal
// PNG image loading from .png2 sources is ready to begin.

- (void) allReadyNotification:(NSNotification*)notification
{
#if defined(DEBUG)
  NSLog(@"allReadyNotification");
#endif // DEBUG
  
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:UIImagePNGSquaredAllReadyNotification
                                                object:nil];
  
  // FIXME: Invoke method to signal the view controller that image can now be loaded
  
  return;
}

#endif // PNGSQUARED

- (void)applicationWillResignActive:(UIApplication *)application {
  // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
  // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
  // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
  // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
  // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
  // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
