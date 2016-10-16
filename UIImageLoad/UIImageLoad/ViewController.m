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
  // Do any additional setup after loading the view, typically from a nib.
  
  NSAssert(self.imageView, @"imageView");
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

@end
