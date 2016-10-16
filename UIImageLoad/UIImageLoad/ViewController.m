//
//  ViewController.m
//  UIImageLoad
//
//  Created by Mo DeJong on 10/16/16.
//  Copyright © 2016 HelpURock. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, retain) IBOutlet UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  NSAssert(self.imageView, @"imageView");
  
#if defined(PNGSQUARED)
  // Explicitly load image
  self.imageView.image = [UIImage imageNamed:@"SuperMarioRun_icon_fs_2048"];
#endif // PNGSQUARED

}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

@end
