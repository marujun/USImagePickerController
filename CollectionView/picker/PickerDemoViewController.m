//
//  PickerDemoViewController.m
//  CollectionView
//
//  Created by 马汝军 on 15/8/5.
//  Copyright (c) 2015年 marujun. All rights reserved.
//

#import "PickerDemoViewController.h"
#import "ImagePickerSheetController.h"

@interface PickerDemoViewController () <UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@end

@implementation PickerDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"图片选择器";
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(presentImagePickerSheet:)];
    [self.view addGestureRecognizer:tapGesture];
}

- (void)presentImagePickerController:(UIImagePickerControllerSourceType)sourceType
{
    if (![UIImagePickerController isSourceTypeAvailable:sourceType]) {
        [[[UIAlertView alloc] initWithTitle:@"该设备不支持拍照"
                                    message:nil
                                   delegate:nil
                          cancelButtonTitle:@"知道了"
                          otherButtonTitles:nil, nil] show];
        
        return;
    }
    
    UIImagePickerController *controller = [[UIImagePickerController alloc] init];
    controller.delegate = self;
    controller.sourceType = sourceType;
    [self presentViewController:controller animated:true completion:nil];
}

- (void)presentImagePickerSheet:(UITapGestureRecognizer *)gestureRecognizer
{
    ImagePickerSheetController *controller = [[ImagePickerSheetController alloc] init];
    controller.maximumSelection = 8;
    controller.displaySelectMaxLimit = YES;
    
    ImageAction *action = [[ImageAction alloc] init];
    action.title = @"照片图库";
    action.style = ImageActionStyleDefault;
    [action setSecondaryTitle:^NSString *(NSInteger num) {
        return [NSString stringWithFormat:@"发送 %@ 张照片",@(num)];
    }];
    [action setHandler:^(ImageAction *action) {
        [self presentImagePickerController:UIImagePickerControllerSourceTypePhotoLibrary];
    }];
    [action setSecondaryHandler:^(ImageAction *action, NSInteger num) {
        
    }];
    [controller addAction:action];
    
    action = [[ImageAction alloc] init];
    action.title = @"拍照或录像";
    action.style = ImageActionStyleDefault;
    [action setSecondaryTitle:^NSString *(NSInteger num) {
        return @"添加注释";
    }];
    [action setHandler:^(ImageAction *action) {
        [self presentImagePickerController:UIImagePickerControllerSourceTypeCamera];
    }];
    [action setSecondaryHandler:^(ImageAction *action, NSInteger num) {
        
    }];
    [controller addAction:action];
    
    action = [[ImageAction alloc] init];
    action.title = @"取消";
    action.style = ImageActionStyleCancel;
    [controller addAction:action];
    
    [self presentViewController:controller animated:true completion:nil];
}

@end
