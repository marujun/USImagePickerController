//
//  PickerDemoViewController.m
//  CollectionView
//
//  Created by 马汝军 on 15/8/5.
//  Copyright (c) 2015年 marujun. All rights reserved.
//

#import "PickerDemoViewController.h"
#import "ImagePickerSheetController.h"

@interface PickerDemoViewController ()

@end

@implementation PickerDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"图片选择器";
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(presentImagePickerSheet:)];
    [self.view addGestureRecognizer:tapGesture];
}

- (void)presentImagePickerSheet:(UITapGestureRecognizer *)gestureRecognizer
{
    ImagePickerSheetController *controller = [[ImagePickerSheetController alloc] init];
    [controller addAction:[[ImageAction alloc] init]];
    
    [self presentViewController:controller animated:true completion:nil];
}

@end
