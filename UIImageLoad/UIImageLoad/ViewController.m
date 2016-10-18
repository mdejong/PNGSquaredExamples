//
//  ViewController.m
//  UIImageLoad
//
//  Created by Mo DeJong on 10/16/16.
//  Copyright © 2016 HelpURock. All rights reserved.
//

#import "ViewController.h"

#if defined(PNGSQUARED)
@import PNGSquared;
#import "UIImage+PNGSquared.h"
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
  
#if defined(PNGSQUARED)
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(allReadyNotification:)
                                               name:UIImagePNGSquaredAllReadyNotification
                                             object:nil];
#else
  // nop
#endif // PNGSQUARED
  
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
}


#if defined(PNGSQUARED)

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  
  // Drop refs to cached UIImage objects when a memory warning is delivered.
  // Note that this logic does not deallocate the ref or remove the keys
  // that indicate which images map to .png2 decode sources.
  
  [UIImage clearCache];
}

// This notification is delivered when the main bundle has been scanned and normal
// PNG image loading from .png2 sources is ready to begin.

- (void) allReadyNotification:(NSNotification*)notification
{
#if defined(DEBUG)
  NSLog(@"allReadyNotification");
#endif // DEBUG
  
  // Explicitly load image
  
  self.imageView.image = [UIImage imageNamed:@"SuperMarioRun_icon_fs_2048"];
  
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:UIImagePNGSquaredAllReadyNotification
                                                object:nil];
  
  return;
}

#endif // PNGSQUARED

@end
