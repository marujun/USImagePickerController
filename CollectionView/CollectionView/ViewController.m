//
//  ViewController.m
//  CollectionView
//
//  Created by 马汝军 on 15/8/5.
//  Copyright (c) 2015年 marujun. All rights reserved.
//

#import "ViewController.h"
#import "ActivityViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    UINavigationController *nav
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)activityButtonAction:(UIButton *)sender
{
    ActivityViewController *vc = [[ActivityViewController alloc] initWithNibName:nil bundle:nil];
    
}

- (IBAction)imagePickerButtonAction:(UIButton *)sender
{
}


@end
