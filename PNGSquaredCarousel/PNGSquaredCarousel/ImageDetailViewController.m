//
//  ImageDetailViewController.m
//

#import "ImageDetailViewController.h"

@interface ImageDetailViewController () <UIGestureRecognizerDelegate, UIViewControllerTransitioningDelegate>

@property (nonatomic, retain) UIImageView *detailImageView;

@end

@implementation ImageDetailViewController

-(void)viewDidLoad
{
  [super viewDidLoad];

  self.detailImageView = [[UIImageView alloc] initWithFrame:self.view.frame];
  
  self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  self.detailImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  
  [self.view addSubview:self.detailImageView];
  
  self.detailImageView.image = self.detailImage;
  
  // Tap detector to close modal view
  
  UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap:)];
  tapGesture.delegate = (id <UIGestureRecognizerDelegate>)self;
  [self.view addGestureRecognizer:tapGesture];
}

- (void) viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  self.detailImageView.image = self.detailImage;
}

- (void) viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];
  self.detailImageView.image = nil;
}

- (void)didTap:(UITapGestureRecognizer *)tapGesture
{
  [self dismissViewControllerAnimated:TRUE completion:^{
    self.isDisplayed = FALSE;
  }];
}

@end
