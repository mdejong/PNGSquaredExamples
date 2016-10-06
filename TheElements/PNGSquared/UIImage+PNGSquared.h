//
//  UIImage+PNGSquared.h
//  ResourcelessApp
//
//  Created by Moses DeJong on 8/11/13.
//  Copyright (c) 2013 helpurock. All rights reserved.
//
//  This implementation overloads the [UIImage imageNamed:(NSString*)name] method at runtime
//  to support automatically loading images from cached images already decoded to disk.
//  This logic implicitly assumes that *ALL* cached files are available before the first
//  call to imageNamed that will load PNGSquared image data. The loading logic will default
//  to the system defined imageNamed method when a prefix is not known to be a cached file,
//  so images that are compiled into the app as normal PNGs can be loaded normally.
//  The caller would typically wait until the notification
//  UIImagePNGSquaredAllReadyNotification has been delivered to indicate that caching of images
//  to disk is completed before launching UI elements that depend on PNGSquared compressed resources.

#import <UIKit/UIKit.h>

#define UIImagePNGSquaredAllReadyNotification @"UIImagePNGSquaredAllReadyNotification"

@interface UIImage (UIImagePNGSquared)

+ (void) setupAppInstance:(NSMutableDictionary*)cacheDict;

+ (void) clearCacheRef;

@end
