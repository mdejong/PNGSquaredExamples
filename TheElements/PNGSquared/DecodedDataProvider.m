//
//  DecodedDataProvider.m
//
//  Created by Moses DeJong on 8/11/13.

#import "DecodedDataProvider.h"

#import "PNGSquared/PNGSquared.h"

//#include <ApplicationServices/ApplicationServices.h>

@interface DecodedDataProvider ()

@property (nonatomic, copy) NSString *imagePrefix;

@property (nonatomic, retain) NSBundle *bundle;

@property (nonatomic, retain) UIImage *backingImg;

@end

@implementation DecodedDataProvider

+ (DecodedDataProvider*) decodedDataProvider:(NSString*)prefix
                                      bundle:(NSBundle*)bundle
{
  DecodedDataProvider *obj = [[DecodedDataProvider alloc] init];
  obj.imagePrefix = prefix;
  if (bundle == nil) {
    obj.bundle = [NSBundle mainBundle];
  } else {
    obj.bundle = bundle;
  }
  return obj;
}

- (void) decode
{
  // Setup C level callbacks that will block up until a backingImg is defined
  
  __block NSString *png2Prefix = self.imagePrefix;
  NSBundle *bundle = self.bundle;
  
  [PNGSquared decodePNG2:png2Prefix bundle:bundle readyBlock:^(UIImage *img){
    const int debug = FALSE;
    
    if (debug) {
      NSLog(@"readyBlock");
    }
    
    // FIXME: What happens if loading fails?
    
    if (img == nil) {
      NSLog(@"Failed to load \"%@\"", png2Prefix);
      NSAssert(FALSE, @"Failed to load \"%@\"", png2Prefix);
      return;
    }
    
    self.backingImg = img;
  }];
}

- (void) makeBlockingDataProvider
{
  /*
  CGDataProviderRef provider = NULL;

  CGDataProviderDirectAccessCallbacks callbacks;
  
  callbacks.getBytes = getBytesGrayRampDirectAccess;
  callbacks.getBytePointer = NULL;
  callbacks.releaseBytePointer = NULL;
  callbacks.releaseProvider = NULL;
  
  int numBytes = 0; // number of bytes in image
  provider = CGDataProviderCreateDirectAccess(NULL, 256, &callbacks);
  
  assert(provider);
   */
}

@end
