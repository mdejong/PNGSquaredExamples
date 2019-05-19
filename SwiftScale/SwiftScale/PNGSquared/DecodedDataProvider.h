//
//  DecodedDataProvider.h
//
//  Created by Moses DeJong on 8/11/13.
//
//  Implement a CoreGraphics data provider that blocks until data has been
//  decoded in a secondary thread. This implementation will cache UIImage
//  objects in the indicated NSMutableDictionary so that another call
//  to load the same image by name will get the cached image object.

#import <Foundation/Foundation.h>

#import <CoreGraphics/CoreGraphics.h>

#import <UIKit/UIKit.h>

@interface DecodedDataProvider : NSObject

+ (DecodedDataProvider*) decodedDataProvider:(NSString*)prefix
                                      bundle:(NSBundle*)bundle
                                   cacheDict:(NSMutableDictionary*)cacheDict;

// Kick off decoding operation, note that the UIImage holds a ref to this object

- (UIImage*) decodeWrapperImg;

// Given a path name like ".../Bundle/Application/XYZ/one.png2" trim the path down to the path component not including a .png2 extension
// and without a device specific or scale extension. For example, both "one@2x.png2" and "one@3x~ipad.png2" return "one"

+ (NSString*) pathPrefixNoScaleOrExt:(NSString*)path;

@end
