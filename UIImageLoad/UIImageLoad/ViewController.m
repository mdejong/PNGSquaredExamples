//
//  ViewController.m
//  UIImageLoad
//
//  Created by Mo DeJong on 10/16/16.
//  Copyright © 2016 HelpURock. All rights reserved.
//

#import "ViewController.h"

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
  // Explicitly load image
  self.imageView.image = [UIImage imageNamed:@"SuperMarioRun_icon_fs_2048"];
#endif // PNGSQUARED
  
  // Cycle background color
  
  self.view.backgroundColor = [UIColor redColor];
  [UIView beginAnimations:nil context:NULL];
  [UIView setAnimationDuration:5.0];
  [UIView setAnimationRepeatCount:3.5];
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

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

@end
