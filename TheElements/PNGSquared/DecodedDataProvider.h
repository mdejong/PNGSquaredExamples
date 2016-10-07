//
//  DecodedDataProvider.h
//
//  Created by Moses DeJong on 8/11/13.
//  Copyright (c) 2013 helpurock. All rights reserved.
//
//  Implement a CoreGraphics data provider that blocks until data has been
//  decoded in a secondary thread.

#import <CoreGraphics/CoreGraphics.h>

@interface DecodedDataProvider : NSObject

+ (DecodedDataProvider*) decodedDataProvider;

// Kick off decoding

- (void) decode;

@end
