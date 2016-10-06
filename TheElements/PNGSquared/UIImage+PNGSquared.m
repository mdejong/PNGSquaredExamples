//
//  UIImage+PNGSquared.m
//
//  Created by Moses DeJong on 8/11/13.
//  Copyright (c) 2013 helpurock. All rights reserved.
//

#import "UIImage+PNGSquared.h"

// Need to use some load time Objective-C magic to override methods in UIImage
#import <objc/runtime.h>

// Ignore warnings about implementing same mehtod signature, since this is exactly what is being done
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

// Ref to current image cache, note that this ref is not reference is not held.
static void *imageCacheDict = nil;

@implementation UIImage (UIImagePNGSquared)

// Overloaded category implementation for [UIImage imageNamed:(NSString*)name]

+ (UIImage*) imageNamed2:(NSString*)name
{
  NSLog(@"imageNamed2 \"%@\"", name);
    
  // If name contains ".png" at the end then strip off the suffix
  
  NSString *nameNoSuffix = name;
  
  if ([nameNoSuffix hasSuffix:@".png"]) {
    nameNoSuffix = [nameNoSuffix stringByDeletingPathExtension];
  }
  
  NSMutableDictionary *imageCache = (__bridge id) imageCacheDict;
  NSAssert(imageCache, @"imageNamed invoked before setupAppInstance was invoked");
  NSString *cachedPath = [imageCache objectForKey:nameNoSuffix];
  
  if (cachedPath != nil) {
    // Image was already decoded by PNGSquared framework and is cached as a PNG
    
    // Note that invoking imageNamed with the fully qualified path name will
    // hold the image file in the cache which results in faster scrolling for
    // images used in table cells.
    
    UIImage *cachedImage;
    
    if ((1)) {
      cachedImage = [self imageWithContentsOfFile:cachedPath];
    } else {
      cachedImage = [self imageNamed:cachedPath];
    }
    
    return cachedImage;
  } else {
    // Not know to be an already decoded PNGSquared image, load via [UIImage imageNamed]
    
    UIImage *systemImage = [self imageNamed2:name];
    if (systemImage == nil) {
      return nil;
    }
    return systemImage;
  }
}

// Util method used to swap static method implementations at the Objective-C runtime level.

+ (void) swapStaticMethods:(SEL)sel1 sel2:(SEL)sel2
{
  Class thisCategoryClass = self;
  NSAssert(self == UIImage.class, @"Category class is not UIImage.class");
  Method original = class_getClassMethod(thisCategoryClass, sel1);
  Method overloaded = class_getClassMethod(thisCategoryClass, sel2);
  method_exchangeImplementations(original, overloaded);
}

// This method is invoked by the startup logic to swap method implementations
// at app startup. Since the methods swap is at the Objective-C runtime layer,
// this will have no effect on compilation or linking related issues.

+ (void) setupAppInstance:(NSMutableDictionary*)cacheDict
{
  NSAssert(cacheDict, @"setupAppInstance cacheDict argument is nil");
  imageCacheDict = (__bridge void*) cacheDict;
  [self swapStaticMethods:@selector(imageNamed:) sel2:@selector(imageNamed2:)];
}

+ (void) makeNotificationObserver
{
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(textureRenderThreadRenderAllReadyNotification:)
                                               name:UIImagePNGSquaredAllReadyNotification
                                             object:nil];
}

// Delivered once all "fast" image decoding operations have been completed.

+ (void) textureRenderThreadRenderAllReadyNotification:(NSNotification*)notification
{
#if defined(DEBUG) || 1
  NSLog(@"textureRenderThreadRenderAllReadyNotification in UIImage+PNGSquared");
#endif // DEBUG
  
  NSDictionary *cachedTable = [notification.userInfo objectForKey:@"cachedTable"];
  NSAssert(cachedTable, @"cachedTable");
  
  for (NSString *prefix in cachedTable) {
    // Set mapping "imageA" ->"/tmp/imageA@2x.png"

    NSString *cachedPNGPath = [cachedTable objectForKey:prefix];
    
#if defined(DEBUG)
    NSLog(@"update cachedTable in textureRenderThreadRenderAllReadyNotification \"%@\" -> \"%@\"", prefix, cachedPNGPath);
#endif // DEBUG

    NSMutableDictionary *imageCache = (__bridge id) imageCacheDict;
    [imageCache setObject:cachedPNGPath forKey:prefix];
  }
  
  // Deliver UIImagePNGSquaredAllReadyNotification now that cached files are known
  
  [[NSNotificationCenter defaultCenter] postNotificationName:UIImagePNGSquaredAllReadyNotification
                                                      object:self
                                                    userInfo:nil];
  
  return;
}

@end

#pragma clang diagnostic pop
