//
//  UIImage+PNGSquared.h
//
//  Created by Moses DeJong on 8/11/13.
//
//  This implementation overloads the [UIImage imageNamed:(NSString*)name] method at runtime
//  to support automatically loading images from the main bundle.
//
//  The caller would typically wait until the notification UIImagePNGSquaredAllReadyNotification
//  has been delivered to indicate that the main bundle has been read and the cache of decoded
//  images is ready to use.

#import <UIKit/UIKit.h>

#define UIImagePNGSquaredAllReadyNotification @"UIImagePNGSquaredAllReadyNotification"

@interface UIImage (UIImagePNGSquared)

+ (void) setupAppInstance:(NSMutableDictionary*)cacheDict;

+ (void) clearCache;

+ (void) dropCacheRef;

@end
