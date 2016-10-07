//
//  DecodedDataProvider.h
//
//  Created by Moses DeJong on 8/11/13.
//
//  Implement a CoreGraphics data provider that blocks until data has been
//  decoded in a secondary thread. This implementation will cache UIImage
//  objects in the indicated NSMutableDictionary so that another call
//  to load the same image by name will get the cached image object.

#import <CoreGraphics/CoreGraphics.h>

@interface DecodedDataProvider : NSObject

+ (DecodedDataProvider*) decodedDataProvider:(NSString*)prefix
                                      bundle:(NSBundle*)bundle
                                   cacheDict:(NSMutableDictionary*)cacheDict;

// Kick off decoding operation, note that the UIImage holds a ref to this object

- (UIImage*) decodeWrapperImg;

@end
