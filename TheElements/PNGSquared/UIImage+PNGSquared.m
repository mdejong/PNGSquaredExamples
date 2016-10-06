//
//  UIImage+PNGSquared.m
//
//  Created by Moses DeJong on 8/11/13.
//  Copyright (c) 2013 helpurock. All rights reserved.
//

#import "UIImage+PNGSquared.h"

#import "PNGSquared/PNGSquared.h"

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
  //NSLog(@"imageNamed2 \"%@\"", name);
    
  // If name contains ".png" at the end then strip off the suffix
  
  NSString *nameNoSuffix = name;
  
  if ([nameNoSuffix hasSuffix:@".png"]) {
    nameNoSuffix = [nameNoSuffix stringByDeletingPathExtension];
  }
  
  NSMutableDictionary *imageCache = (__bridge id) imageCacheDict;
  NSAssert(imageCache, @"imageNamed invoked before setupAppInstance was invoked");
  id obj = [imageCache objectForKey:nameNoSuffix];
  
  if (obj == (id)[NSNull null]) {
    // Not cached
    NSAssert(FALSE, @"image not cached \"%@\"", nameNoSuffix);
    return nil;
  } else if (obj != nil) {
    // already cached
    return (UIImage*)obj;
  } else {
    // Not know to be an already decoded PNGSquared image, load via [UIImage imageNamed]
    NSAssert(obj == nil, @"imageCache returned nil");
    
    UIImage *systemImage = [self imageNamed2:nameNoSuffix];
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
  
  [self scanMainBundle];
  
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    @autoreleasepool {
      [self decodeAll];
    }
  });
}

+ (void) clearCacheRef
{
  imageCacheDict = NULL;
}

// Scan all files in main bundle and looks for .png2 images that can be decompressed directly.

+ (void) scanMainBundle
{
  const BOOL debug = FALSE;
  
  NSBundle *mainBundle = [NSBundle mainBundle];
  
  NSMutableDictionary *imageCache = (__bridge id) imageCacheDict;
  NSAssert(imageCache, @"imageCache");
  
  NSArray *allPng2ImagePaths = [mainBundle pathsForResourcesOfType:@"png2" inDirectory:nil];
  
  for ( NSString *png2Path in allPng2ImagePaths ) {
    //NSLog(@"png2Path \"%@\"", png2Path);
    
    // Grab just the path tail without the extension
    NSString *pathTail = [png2Path lastPathComponent];
    NSString *pathTailNoExtension = [pathTail stringByDeletingPathExtension];
    
    imageCache[pathTailNoExtension] = [NSNull null];
    
    if (debug) {
      NSLog(@"png2 extension \"%@\"", pathTailNoExtension);
    }
  }
  
  return;
}

// Decompress all the indicated PNG2 images and cache them as decoded UIImage objects

+ (void) decodeAll
{
  const BOOL debug = FALSE;
  
  __block NSMutableDictionary *mLoadedImagesDict = [NSMutableDictionary dictionary];

  // Iterate over each image prefix and load
  
  NSMutableDictionary *imageCache = (__bridge id) imageCacheDict;
  NSAssert(imageCache, @"imageCache");
  
  NSArray *allKeys = [NSArray arrayWithArray:imageCache.allKeys];

  NSBundle *mainBundle = [NSBundle mainBundle];
  
  for ( NSString *prefix in allKeys ) {
    if (debug) {
      NSLog(@"prefix \"%@\"", prefix);
    }
    
    NSString *fullPath = [mainBundle pathForResource:prefix ofType:@"png2"];
    NSAssert(fullPath, @"fullPath");
    
    // Prefix like "name_gray" -> "name_gray.png2"
    NSString *prefixWithPng2Ext = [fullPath lastPathComponent];
  
    // Kick off loading in this thread
    
    [PNGSquared decodePNG2:prefixWithPng2Ext bundle:mainBundle readyBlock:^(UIImage *img){
      if (debug) {
        NSLog(@"readyBlock");
      }
      
      if (img == nil) {
        NSLog(@"Failed to load \"%@\"", prefixWithPng2Ext);
        NSAssert(FALSE, @"Failed to load \"%@\"", prefixWithPng2Ext);
        return;
      }
      
      @synchronized (mLoadedImagesDict) {
        mLoadedImagesDict[prefix] = img;
      }
    }];
    
    // Wait for block to be invoked.
    
    while (1) {
      NSString *obj = nil;
      @synchronized (mLoadedImagesDict) {
        obj = [mLoadedImagesDict objectForKey:prefix];
      }
      
      if (obj == nil)
      {
        if (debug) {
          NSLog(@"sleep");
        }
        [NSThread sleepForTimeInterval:0.01];
      } else {
        // Image loaded
        if (debug) {
          NSLog(@"image loaded \"%@\"", prefix);
        }
        break;
      }
    }
  }
  
  // Add UIImage refs to cache
  
  for ( NSString * prefix in mLoadedImagesDict.allKeys ) {
    imageCache[prefix] = mLoadedImagesDict[prefix];
  }
  
  // Send notification on main thread
  
  dispatch_async(dispatch_get_main_queue(), ^{
    [[NSNotificationCenter defaultCenter] postNotificationName:UIImagePNGSquaredAllReadyNotification
                                                        object:self
                                                      userInfo:nil];
  });
  
  return;
}

@end

#pragma clang diagnostic pop
