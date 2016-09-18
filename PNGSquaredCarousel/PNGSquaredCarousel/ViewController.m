//
//  ViewController.m
//  PNGSquaredCarousel
//
//  Created by Mo DeJong on 6/26/15.
//  Copyright (c) 2015 helpurock. All rights reserved.
//
//  This example app provides 2 install targets, the first one "BatArt" loads
//  images from normal PNG images. The "BatArt2" target loads images using
//  the PNGSquared framework. Note the size differences between the original
//  PNGs and the significantly smaller .png2 images.

#import "ViewController.h"

#import "ImageDetailViewController.h"

#import "iCarousel.h"

#if defined(PNGSQUARED)
@import PNGSquared;
#endif // PNGSQUARED

@interface ViewController () <iCarouselDataSource, iCarouselDelegate>

@property (nonatomic, strong) iCarousel *carousel;

@property (nonatomic, strong) NSMutableArray *items;

@property (nonatomic, retain) NSTimer *endOfScrollTimer;

@property (nonatomic, retain) ImageDetailViewController *imageDetailViewController;

@property (nonatomic, assign) BOOL finishedInitialLoad;

@property (nonatomic, retain) NSMutableDictionary *imageCache;

@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  [self makeDataSource];
  
  self.carousel = [[iCarousel alloc] initWithFrame:self.view.bounds];
  self.carousel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  self.carousel.type = iCarouselTypeInvertedCylinder;
  self.carousel.delegate = self;
  self.carousel.dataSource = self;
  
  self.carousel.backgroundColor = [UIColor darkGrayColor];
  
  [self.view addSubview:self.carousel];
}

- (void) makeDataSource
{
  if (self.items == nil) {
    self.items = [NSMutableArray array];
  } else {
    [self.items removeAllObjects];
  }
  
  [self.items addObjectsFromArray:@[
                                    @"BatSymbol",
                                    @"BatEyes",
                                    @"BatSymbolProjected",
                                    @"Bat8Bit",
                                    @"JokerStabBatman",
                                    @"BatArmor",
                                    @"Lightning",
                                    @"RedBatman",
                                    @"Smile"
                                    ]];
}

- (void)viewDidUnload {
  [super viewDidUnload];
  self.carousel.delegate = nil;
  self.carousel.dataSource = nil;
  self.carousel = nil;
  
  [self.endOfScrollTimer invalidate];
  self.endOfScrollTimer = nil;
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
  NSLog(@"didReceiveMemoryWarning");
}

- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
  return [self.items count];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
  __block UIImageView *contentImageView = nil;
  
  //create new view if no view is available for recycling
  if (view == nil)
  {
    view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 300.0f, 300.0f)];
    UIImage *img = [UIImage imageNamed:@"page"];
    NSAssert(img, @"embedded resource \"page\" could not be loaded");
    ((UIImageView *)view).image = img;
    view.contentMode = UIViewContentModeCenter;
    
    contentImageView = [[UIImageView alloc] initWithFrame:view.bounds];

    contentImageView.backgroundColor = [UIColor clearColor];
    contentImageView.tag = 1;
    [view addSubview:contentImageView];
  }
  else
  {
    //get a reference to the label in the recycled view
    contentImageView = (UIImageView *)[view viewWithTag:1];
  }
  
  NSString *imagePrefix = self.items[index];
  
#if defined(PNGSQUARED)
  // Invoke non-blocking decode API that will invoke block associated with
  // the contentImageView.
  
  // Append ".png2" to the prefix name so that "BatEyes" becomes "BatEyes.png2"
  
  NSString *png2ResName = [NSString stringWithFormat:@"%@.png2", imagePrefix];
  
  if (self.imageCache == nil) {
    self.imageCache = [NSMutableDictionary dictionary];
  }
  
  UIImage *cachedImg = self.imageCache[png2ResName];
  
  if (cachedImg) {
    NSLog(@"cached loading %@", png2ResName);
    
    contentImageView.image = cachedImg;
  } else {
    // Kick off loading operation as an async task
    
    [PNGSquared decodePNG2:png2ResName bundle:nil readyBlock:^(UIImage *img){
      //NSLog(@"readyBlock");
      
      if (img == nil) {
        NSLog(@"Failed to load resource \"%@\"", png2ResName);
        contentImageView.image = [UIImage imageNamed:@"placeholder"];
        return;
      }
      
      NSLog(@"done loading %@", png2ResName);
      
      contentImageView.image = img;
      
      self.imageCache[png2ResName] = img;

      // This is not perfect, but the Carousel API does not seem
      // to provide a way to redisplay the elements without kicking off
      // another image load operation, so this logic does a reload
      // after idle so that cached UIImage* will be used from the
      // local hashtable when reloading the contents of views.
      
      dispatch_async(dispatch_get_main_queue(), ^{
        [self.carousel reloadData];
      });

    }];
  }
#else
  UIImage *resImg = [UIImage imageNamed:imagePrefix];
  //NSAssert(resImg, @"could not load image \"%@\"", imagePrefix);
  
  if (resImg == nil) {
    resImg = [UIImage imageNamed:@"placeholder"];
  }
  contentImageView.image = resImg;
#endif // PNGSQUARED
  
  return view;
}

- (CATransform3D)carousel:(iCarousel *)carousel itemTransformForOffset:(CGFloat)offset baseTransform:(CATransform3D)transform
{
  //implement 'flip3D' style carousel
  transform = CATransform3DRotate(transform, M_PI / 8.0f, 0.0f, 1.0f, 0.0f);
  return CATransform3DTranslate(transform, 0.0f, 0.0f, offset * carousel.itemWidth);
}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
  //customize carousel display
  switch (option)
  {
    case iCarouselOptionWrap:
    {
      return YES;
    }
    case iCarouselOptionSpacing:
    {
      //add a bit of spacing between the item views
      return value * 1.05f;
    }
    case iCarouselOptionFadeMax:
    {
      if (carousel.type == iCarouselTypeCustom)
      {
        //set opacity based on distance from camera
        return 0.0f;
      }
      return value;
    }
    default:
    {
      return value;
    }
  }
}

- (void)carouselDidEndScrollingAnimation:(iCarousel *)carousel
{
  NSLog(@"carouselDidEndScrollingAnimation");
  
  [self.endOfScrollTimer invalidate];
  self.endOfScrollTimer = nil;
  
  if (self.imageDetailViewController.isDisplayed) {
    NSLog(@"carouselDidEndScrollingAnimation return nop since isDisplayed is TRUE");
    return;
  }
  
  if (self.finishedInitialLoad == FALSE) {
    self.finishedInitialLoad = TRUE;
    return;
  }
  
  self.endOfScrollTimer = [NSTimer timerWithTimeInterval:1.0
                                                  target:self
                                                selector:@selector(endOfScrollTimerFired:)
                                                userInfo:nil
                                                 repeats:FALSE];
  
  [[NSRunLoop currentRunLoop] addTimer:self.endOfScrollTimer forMode:NSDefaultRunLoopMode];
}

- (void)carouselWillBeginDragging:(__unused iCarousel *)carousel
{
  NSLog(@"carouselWillBeginDragging");
  
  [self.endOfScrollTimer invalidate];
  self.endOfScrollTimer = nil;
}

- (void)carousel:(__unused iCarousel *)carousel didSelectItemAtIndex:(__unused NSInteger)index {
  [self endOfScrollTimerFired:nil];
  return;
}

- (void) endOfScrollTimerFired:(NSTimer*)timer
{
  NSLog(@"endOfScrollTimerFired");
  
  if (self.imageDetailViewController == nil) {
    self.imageDetailViewController = [[ImageDetailViewController alloc] init];
  }
  
  if (self.imageDetailViewController.isDisplayed) {
    NSLog(@"endOfScrollTimerFired return nop since isDisplayed is TRUE");
    return;
  }
  
  // Grab UIImage object currently defined for the specific view

  NSInteger currentItemIndex = self.carousel.currentItemIndex;
  UIView *currentItemView = [self.carousel itemViewAtIndex:currentItemIndex];
  UIImageView *contentImageView = (UIImageView *)[currentItemView viewWithTag:1];
  UIImage *resImg = contentImageView.image;
  self.imageDetailViewController.detailImage = resImg;
  
  self.imageDetailViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
  self.imageDetailViewController.modalPresentationStyle = UIModalPresentationOverFullScreen;
  
  self.imageDetailViewController.isDisplayed = TRUE;
  
  [self presentViewController:self.imageDetailViewController animated:TRUE completion:nil];
}

@end
