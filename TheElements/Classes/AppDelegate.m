/*
     File: AppDelegate.m
 Abstract: Application delegate that sets up the application.
  Version: 1.12
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2013 Apple Inc. All Rights Reserved.
 
 */

#import "AppDelegate.h"

#import "UIImage+PNGSquared.h"

#import "ElementsTableViewController.h"

// each data source responsible for backing our 4 varying table view controllers
#import "ElementsSortedByNameDataSource.h"
#import "ElementsSortedByAtomicNumberDataSource.h"
#import "ElementsSortedBySymbolDataSource.h"
#import "ElementsSortedByStateDataSource.h"

@interface AppDelegate ()

// An app wide ref to a PNGSquared render thread must be held by the AppDelegate

@property (nonatomic, retain) UIImageView *imageView;

@property (nonatomic, retain) UIViewController *rootViewController;

// A ref counted dictionary is required to hold active refs to UIImage objects
// cached by the custom UIImage overloaded methods.

@property (nonatomic, retain) NSMutableDictionary *imageCache;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	
#if defined(PNGSQUARED)
  
  // Invoke setup method to swap in custom impl of [UIImage imageNamed:]
  
  self.imageCache = [NSMutableDictionary dictionary];
  [UIImage setupAppInstance:self.imageCache];
  
  // When using the PNGSquared target, need to ensure that all image resources are
  // decoded before the main tab bar can be created since the images used in the
  // tab bar need to be decoded first. Continue to display the Default.png image
  // until the cache can be checked to ensure that all images have been decoded.
  
  UIImage *defaultImage = [UIImage imageNamed:@"Default"];
  UIImageView *imageView = [[UIImageView alloc] initWithImage:defaultImage];
  self.imageView = imageView;
  
  [self.window.rootViewController.view removeFromSuperview];
  self.rootViewController = self.window.rootViewController;
  self.window.rootViewController = nil;
  
  [self.window addSubview:imageView];
  
  self.window.rootViewController = [[UIViewController alloc] init];
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(allReadyNotification:)
                                               name:UIImagePNGSquaredAllReadyNotification
                                             object:nil];
  
#else
  [self makeTabBar];
#endif // PNGSQUARED
  
  return YES;
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
  // Drop refs to cached UIImage objects when a memory warning is delivered.
  // Note that this logic does not deallocate the ref or remove the keys
  // that indicate which images map to .png2 decode sources.
  
#if defined(PNGSQUARED)
  [UIImage clearCache];
#endif // PNGSQUARED
}

- (void) makeTabBar
{
  // for each tableview 'screen' we need to create a datasource instance
  // (the class that is passed in) we then need to create an instance of
  // ElementsTableViewController with that datasource instance finally we need to return
  // a UINaviationController for each screen, with the ElementsTableViewController as the
  // root view controller.
  //
  UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
  
  // the class type for the datasource is not crucial, but that it implements the
  // ElementsDataSource protocol and the UITableViewDataSource Protocol
  //
  id<ElementsDataSource, UITableViewDataSource> dataSource;
  
  UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
  NSMutableArray *viewControllers = [NSMutableArray arrayWithCapacity:4];
  
  // create our tabbar view controllers, since we already have one defined in our storyboard
  // we will create 3 more instances of it, and assign each it's own kind data source
  
  // by name
  UINavigationController *navController = [storyboard instantiateViewControllerWithIdentifier:@"navForTableView"];
  ElementsTableViewController *viewController =
  (ElementsTableViewController *)[navController topViewController];
  dataSource = [[ElementsSortedByNameDataSource alloc] init];
  viewController.dataSource = dataSource;
  [viewControllers addObject:navController];
  
  // by atomic number
  navController = [storyboard instantiateViewControllerWithIdentifier:@"navForTableView"];
  viewController = (ElementsTableViewController *)[navController topViewController];
  dataSource = [[ElementsSortedByAtomicNumberDataSource alloc] init];
  viewController.dataSource = dataSource;
  [viewControllers addObject:navController];
  
  // by symbol
  navController = [storyboard instantiateViewControllerWithIdentifier:@"navForTableView"];
  viewController = (ElementsTableViewController *)[navController topViewController];
  dataSource = [[ElementsSortedBySymbolDataSource alloc] init];
  viewController.dataSource = dataSource;
  [viewControllers addObject:navController];
  
  // by state
  navController = [storyboard instantiateViewControllerWithIdentifier:@"navForTableView"];
  viewController = (ElementsTableViewController *)[navController topViewController];
  dataSource = [[ElementsSortedByStateDataSource alloc] init];
  viewController.dataSource = dataSource;
  [viewControllers addObject:navController];
  
  tabBarController.viewControllers = viewControllers;
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
  
  [self.imageView removeFromSuperview];
  self.imageView = nil;
  
  self.window.rootViewController = self.rootViewController;
  
  [self makeTabBar];
  
  return;
}

#endif // PNGSQUARED

@end

