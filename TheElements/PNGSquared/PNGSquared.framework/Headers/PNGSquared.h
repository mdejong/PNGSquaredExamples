//
//  PNGSquared.h
//  PNGSquared
//
//  Created by Mo DeJong on 6/2/15.
//  Copyright (c) 2015 helpurock. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for PNGSquared.
FOUNDATION_EXPORT double PNGSquaredVersionNumber;

//! Project version string for PNGSquared.
FOUNDATION_EXPORT const unsigned char PNGSquaredVersionString[];

// Public interface

@interface PNGSquared : NSObject

// Decompress a single file in a GCD thread and generate a UIImage when the async decoding process has completed.
// If an image could not be decompressed from the indicated resource then the ready block is invoked with nil as the UIImage value.
// Note that passing nil as the bundle will default to use the main bundle.

+ (void) decodePNG2:(NSString*)imageResName
             bundle:(NSBundle*)bundle
         readyBlock:(void (^)(UIImage*))readyBlock;

@end
