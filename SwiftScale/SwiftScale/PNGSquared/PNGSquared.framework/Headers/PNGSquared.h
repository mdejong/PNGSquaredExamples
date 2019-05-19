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
// Note that passing nil as the bundle will default to use the main bundle. Note also that the readyBlock
// is always invoked on the main thread.

+ (void) decodePNG2:(NSString*)imageResName
             bundle:(NSBundle*)bundle
         readyBlock:(void (^)(UIImage*))readyBlock;

// Blocking API that will decode from a png2 file in the current thread. Typically this API is
// useful only in cases where decoding has to be done on the main thread for compatibility
// with poorly designed blocking UIImage APIs. The results are returned as a read only
// NSDictionary, the key "uiimage" contains a ref to the UIImage* result along with meta-data.

+ (NSDictionary*) blockingDecodePNG2:(NSString*)imageResName
                              bundle:(NSBundle*)bundle;

// Blocking API that reads the image dimensions and BPP settings from png2 header without
// decoding image data. This API is useful for a case where image properties need to be
// known before decoding image data is finished, for example when creating a CoreGraphics image.
// Returns TRUE one success, FALSE when file cannot be read or is not the proper type.

+ (BOOL) detectPNG2Properties:(NSString*)imageResName
                       bundle:(NSBundle*)bundle
                         size:(CGSize*)size
                          bpp:(uint8_t*)bpp;

@end
