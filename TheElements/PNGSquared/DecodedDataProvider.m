//
//  DecodedDataProvider.m
//
//  Created by Moses DeJong on 8/11/13.

#import "DecodedDataProvider.h"

#import <CoreGraphics/CGDataProvider.h>

#import "PNGSquared/PNGSquared.h"

@interface DecodedDataProvider ()

@property (nonatomic, copy) NSString *imagePrefix;

@property (nonatomic, retain) NSBundle *bundle;

@property (nonatomic, retain) UIImage *backingImg;

@property (nonatomic, retain) DecodedDataProvider *selfRef;

@property (nonatomic, assign) uint32_t *cachedPixelPtr;

// Note that a ref to this cache is not held here

@property (nonatomic, assign) NSMutableDictionary *cacheDict;

@end

static
const void * getBytePointerCallback(void *info)
{
#if defined(DEBUG)
  const int debug = TRUE;
#else
  const int debug = FALSE;
#endif // DEBUG
  
  DecodedDataProvider *provider = (__bridge DecodedDataProvider*) info;
  
  if (debug) {
    NSLog(@"getBytePointerCallback \"%@\" : %p", provider.imagePrefix, info);
  }
 
  uint32_t *cachedPixelPtr = provider.cachedPixelPtr;
  
  if (cachedPixelPtr) {
    // Nop
    
    if (debug) {
      NSLog(@"getBytePointerCallback (cached) %p -> %p", info, cachedPixelPtr);
    }
  } else {
    // Kick off stage 2 loading where the image data is decompressed
    // in the current thread using a blocking API.
    
    if (debug) {
      NSLog(@"getBytePointerCallback (not cached) %p", info);
    }
    
    NSString *png2Prefix = provider.imagePrefix;
    NSBundle *bundle = provider.bundle;
    NSDictionary *dict = [PNGSquared blockingDecodePNG2:png2Prefix bundle:bundle];
    
    if (dict == nil) {
      // Image could not be loaded
      
      provider.backingImg = nil;
      provider.cachedPixelPtr = NULL;
    } else {
      UIImage *img = dict[@"uiimage"];
      
      provider.backingImg = img;
      
      // Pointer to image data buffer
      
      NSValue *ptrValue = dict[@"pointer"];
      
      // FIXME: verify width and height and bpp
      
      cachedPixelPtr = [ptrValue pointerValue];
      
      // Add actual UIImage to the cache, not the wrapper
      
      NSMutableDictionary *cacheDict = provider.cacheDict;
      
      if (cacheDict) {
        // Remove .png2 extension before adding to cache
        
        NSString *cachePrefix = [png2Prefix stringByDeletingPathExtension];
        cacheDict[cachePrefix] = img;
      }
      
      // Note that this pointer is valid only while a ref
      // to backingImg is held.
      
      provider.cachedPixelPtr = cachedPixelPtr;
    }
  }
  
  return (void*)cachedPixelPtr;
}

static
void releaseBytePointerCallback(void *info, const void *  pointer)
{
#if defined(DEBUG)
  const int debug = TRUE;
#else
  const int debug = FALSE;
#endif // DEBUG
  
  DecodedDataProvider *provider = (__bridge DecodedDataProvider*) info;
  
  if (debug) {
    NSLog(@"releaseBytePointerCallback \"%@\" : %p", provider.imagePrefix, info);
  }

  // No need to release cachedPixelPtr here since the cached value can be used again
  
  //provider.cachedPixelPtr = NULL;
  
  return;
}

// Release image data provider

static void releaseCallback(void *info) {
#if defined(DEBUG)
  const int debug = TRUE;
#else
  const int debug = FALSE;
#endif // DEBUG
  
  DecodedDataProvider *provider = (__bridge DecodedDataProvider*) info;
  
  if (debug) {
    NSLog(@"releaseCallback \"%@\" : %p", provider.imagePrefix, info);
  }
  
  // Actually release the reference to the DecodedDataProvider which will drop the ref
  // to the backing UIImage.
  
  provider.selfRef = nil;
}

@implementation DecodedDataProvider

+ (DecodedDataProvider*) decodedDataProvider:(NSString*)prefix
                                      bundle:(NSBundle*)bundle
                                   cacheDict:(NSMutableDictionary*)cacheDict
{
  DecodedDataProvider *obj = [[DecodedDataProvider alloc] init];
  
  // Prefix like "name_gray" -> "name_gray.png2"
  obj.imagePrefix = [NSString stringWithFormat:@"%@.png2", prefix];
  
  if (bundle == nil) {
    obj.bundle = [NSBundle mainBundle];
  } else {
    obj.bundle = bundle;
  }
  
  obj.cacheDict = cacheDict;
  
  return obj;
}

- (CGBitmapInfo) getBitmapInfo:(int)bitsPerPixel
{
  CGBitmapInfo bitmapInfo = 0;
  if (bitsPerPixel == 24) {
    bitmapInfo |= kCGImageAlphaNoneSkipFirst;
  } else if (bitsPerPixel == 32) {
      // Treat 32BPP as premultiplied (the default)
      bitmapInfo |= kCGImageAlphaPremultipliedFirst;
  } else {
    assert(0);
  }
  
  bitmapInfo |= kCGBitmapByteOrder32Host;
  
  return bitmapInfo;
}

// Decode a UIImage* that acts as a wrapper around the actual image data.
// Note that the actual image data will only be decompressed once and
// then the actual decoded UIImage* will be cached.

- (UIImage*) decodeWrapperImg
{
  // Setup C level callbacks that will block up until a backingImg is defined
  
  __block NSString *png2Prefix = self.imagePrefix;
  NSBundle *bundle = self.bundle;
  
  // Interface with CoreGraphics and create a wrapper that matches the
  // dimensions of the image data to be decoded without actually starting
  // a decode operation yet.
  
  CGDataProviderDirectCallbacks cb;
  
  cb.version = 0;
  cb.getBytePointer = getBytePointerCallback;
  cb.releaseBytePointer = releaseBytePointerCallback;
  cb.getBytesAtPosition = NULL;
  cb.releaseInfo = releaseCallback;
  
  CGSize size = CGSizeZero;
  uint8_t bpp = 0;
  BOOL worked = [PNGSquared detectPNG2Properties:png2Prefix bundle:bundle size:&size bpp:&bpp];
  
  if (!worked) {
    return nil;
  }
  
  int numBytes = (int)size.width * (int)size.height * sizeof(uint32_t); // number of bytes in image
  
  // Lock self by having self hold a ref to itself.
  // Note that this object does not ref the returned UIImage
  // so there is no loop at this point.
  
  self.selfRef = self;
  
  void *selfPtr = (__bridge void*) self;
  
  CGDataProviderRef dataProviderRef = CGDataProviderCreateDirect(selfPtr, numBytes, &cb);
  
  assert(dataProviderRef);

  // Make UIImage based on provider data
  
  size_t bitsPerComponent = 8;
  size_t numComponents = 4;
  size_t bitsPerPixel = bitsPerComponent * numComponents;
  size_t bytesPerRow = (int)size.width * (bitsPerPixel / 8);
  
  CGBitmapInfo bitmapInfo = [self getBitmapInfo:bpp];
  
  CGColorRenderingIntent renderIntent = kCGRenderingIntentDefault;
  
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  
  BOOL shouldInterpolate = FALSE; // images at exact size already
  
  CGImageRef cgImgRef = CGImageCreate(size.width, size.height, bitsPerComponent, bitsPerPixel, bytesPerRow,
                                        colorSpace, bitmapInfo, dataProviderRef, NULL,
                                        shouldInterpolate, renderIntent);

  CGDataProviderRelease(dataProviderRef);
  
  CGColorSpaceRelease(colorSpace);
  
  UIImage *img = [UIImage imageWithCGImage:cgImgRef];
  
  CGImageRelease(cgImgRef);
  
  return img;
}

@end
