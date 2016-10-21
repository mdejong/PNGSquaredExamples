//
//  UIImage+PNGSquared.m
//
//  Created by Moses DeJong on 8/11/13.

#import "UIImage+PNGSquared.h"

#import "PNGSquared/PNGSquared.h"

#import "DecodedDataProvider.h"

// Need to use some load time Objective-C magic to override methods in UIImage
#import <objc/runtime.h>

// Ignore warnings about implementing same mehtod signature, since this is exactly what is being done
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

// Ref to current image cache, note that this reference count is not incremented
static void *imageCacheDict = nil;

@implementation UIImage (UIImagePNGSquared)

// Overloaded category implementation for [UIImage imageNamed:(NSString*)name]

+ (UIImage*) imageNamed2:(NSString*)name
{
  const BOOL debugPrintCacheStatus = TRUE;
  
  //NSLog(@"imageNamed2 \"%@\"", name);
    
  // If name contains ".png" at the end then strip off the suffix
  
  NSString *nameNoSuffix = name;
  
  if ([nameNoSuffix hasSuffix:@".png"]) {
    nameNoSuffix = [nameNoSuffix stringByDeletingPathExtension];
  }
  
  NSMutableDictionary *imageCache = (__bridge id) imageCacheDict;
  NSAssert(imageCache, @"imageNamed invoked before setupAppInstance was invoked");
  id obj = [imageCache objectForKey:nameNoSuffix];
  
  NSBundle *mainBundle = [NSBundle mainBundle];
  
  if (obj == (id)[NSNull null]) {
    // Prefix is know to match a .png2 extension, but it is not currently cached as a UIImage

    if (debugPrintCacheStatus) {
      NSLog(@"image not cached \"%@\"", nameNoSuffix);
    }
    
    DecodedDataProvider *provider = [DecodedDataProvider decodedDataProvider:nameNoSuffix bundle:mainBundle cacheDict:imageCache];
    
    UIImage *wrapperImg = [provider decodeWrapperImg];
    
    return wrapperImg;
  } else if (obj != nil) {
    // already cached
    
    if (debugPrintCacheStatus) {
      NSLog(@"image cached \"%@\"", nameNoSuffix);
    }
    
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
// This logic will also scan the main bundle for files with the .png2
// extension, so that a prefix like "gray" or "gray.png" will load "gray.png2".

+ (void) setupAppInstance:(NSMutableDictionary*)cacheDict
{
  NSAssert(cacheDict, @"setupAppInstance cacheDict argument is nil");
  imageCacheDict = (__bridge void*) cacheDict;
  [self swapStaticMethods:@selector(imageNamed:) sel2:@selector(imageNamed2:)];

  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    @autoreleasepool {
      [self scanMainBundle];
      
      // Send notification on main thread
      
      dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:UIImagePNGSquaredAllReadyNotification
                                                            object:self
                                                          userInfo:nil];
      });
    }
  });
}

+ (void) clearCache
{
  if (imageCacheDict) {
    NSMutableDictionary *imageCache = (__bridge id) imageCacheDict;
    
    NSArray *strKeys = imageCache.allKeys;
    
    for ( NSString *keyStr in strKeys ) {
      imageCache[keyStr] = [NSNull null];
    }
  }
}

+ (void) dropCacheRef
{
  imageCacheDict = NULL;
}

// Scan all files in main bundle and looks for .png2 images that can be decompressed directly.

+ (void) scanMainBundle
{
  const BOOL debug = TRUE;
  
  NSBundle *mainBundle = [NSBundle mainBundle];
  
  NSMutableDictionary *imageCache = (__bridge id) imageCacheDict;
  NSAssert(imageCache, @"imageCache");
  
  NSArray *allPng2ImagePaths = [mainBundle pathsForResourcesOfType:@"png2" inDirectory:nil];
  
  for ( NSString *png2Path in allPng2ImagePaths ) {
    //NSLog(@"png2Path \"%@\"", png2Path);
    
    NSString *pathTailNoExtension = [DecodedDataProvider pathPrefixNoScaleOrExt:png2Path];
    
    imageCache[pathTailNoExtension] = [NSNull null];
    
    if (debug) {
      NSLog(@"will cache png2 extension \"%@\" from path \"%@\"", pathTailNoExtension, png2Path);
    }
  }
  
  return;
}

@end

#pragma clang diagnostic pop
