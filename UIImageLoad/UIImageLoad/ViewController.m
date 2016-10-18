//
//  ViewController.m
//  UIImageLoad
//
//  Created by Mo DeJong on 10/16/16.
//
//  Trivial loading logic that shows a PNG and plays a sound. When compiled
//  with the target "UIImageLoad" the original PNG is loaded from an app resoruce.
//  When compiled with the "UIImageLoad2" target, the original PNG is not included
//  and a 3x smaller .png2 file is decompressed instead.

#import "ViewController.h"

#if defined(PNGSQUARED)
@import CoreGraphics;
@import ImageIO;
@import QuartzCore;
@import MobileCoreServices;
@import PNGSquared;
#endif // PNGSQUARED

@import AVFoundation;

#define ENABLE_SOUND

@interface ViewController ()

@property (nonatomic, retain) IBOutlet UIImageView *imageView;

// Audio clip player

@property (nonatomic, retain) AVAudioPlayer *audioPlayer;

@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  NSAssert(self.imageView, @"imageView");
  
  // Cycle background color
  
  self.view.backgroundColor = [UIColor redColor];
  [UIView beginAnimations:nil context:NULL];
  [UIView setAnimationDuration:5.0];
  [UIView setAnimationRepeatCount:20];
  [UIView setAnimationRepeatAutoreverses:TRUE];
  self.view.backgroundColor = [UIColor blackColor];
  [UIView commitAnimations];
  
#ifdef ENABLE_SOUND
  // Intro audio clip
  
  NSString *resFilename = @"sm64_mario_its_me.wav";
  NSString* resPath = [[NSBundle mainBundle] pathForResource:resFilename ofType:nil];
  NSAssert(resPath, @"resPath is nil");
  NSURL *url = [NSURL fileURLWithPath:resPath];
  AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
  self.audioPlayer = player;

  [player play];
#endif
  
  // When using PNGSQUARED the original PNG cannot be loaded from the storyboard.
  // Invoke async block based API to load and then set the UIImageView.image property.
  
#if defined(PNGSQUARED)
  {
    NSString *resFilename = @"SuperMarioRun_icon_fs_2048.png2";
    [PNGSquared decodePNG2:resFilename
                    bundle:nil
                readyBlock:^(UIImage *img){
                  NSAssert(img, @"could not load \"%@\"", resFilename);
                  self.imageView.image = img;
                }];
  }
#endif // PNGSQUARED
}

@end
