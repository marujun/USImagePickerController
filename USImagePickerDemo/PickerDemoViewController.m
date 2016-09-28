//
//  PickerDemoViewController.m
//  USImagePickerController
//
//  Created by 马汝军 on 15/8/5.
//  Copyright (c) 2015年 marujun. All rights reserved.
//

#import "PickerDemoViewController.h"
#import "ImagePickerSheetController.h"
#import "USImagePickerController.h"

@interface PickerDemoViewController () <UIImagePickerControllerDelegate,UINavigationControllerDelegate,USImagePickerControllerDelegate>

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
    
    if (sourceType == UIImagePickerControllerSourceTypeCamera) {
        UIImagePickerController *controller = [[UIImagePickerController alloc] init];
        controller.sourceType = sourceType;
        controller.delegate = self;
        [self presentViewController:controller animated:true completion:nil];
    }
    else {
        USImagePickerController *imagePicker = [[USImagePickerController alloc] init];
        imagePicker.delegate = self;
//        imagePicker.allowsEditing = YES;
//        imagePicker.cropMaskAspectRatio = 0.5;
        imagePicker.allowsMultipleSelection = YES;
        imagePicker.maxSelectNumber = 9;
        
//        imagePicker.tintColor = [UIColor greenColor];
//        imagePicker.hideOriginalImageCheckbox = YES;
//        
//        imagePicker.navigationBar.tintColor = [UIColor whiteColor];
//        imagePicker.navigationBar.barTintColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
//        imagePicker.navigationBar.translucent = NO;
//        
//        NSShadow *shadow = [NSShadow new];
//        [shadow setShadowColor: [UIColor clearColor]];
//        NSDictionary * dict = @{NSForegroundColorAttributeName:[UIColor whiteColor],
//                                NSShadowAttributeName:shadow};
//        imagePicker.navigationBar.titleTextAttributes = dict;
        
        [self presentViewController:imagePicker animated:true completion:nil];
    }
}

#pragma mark - USImagePickerControllerDelegate
- (void)imagePickerController:(USImagePickerController *)picker didFinishPickingMediaWithAssets:(NSArray *)mediaArray
{
    NSLog(@"selectedOriginalImage %zd didFinishPickingMediaWithArray %@", picker.selectedOriginalImage, mediaArray);
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(USImagePickerController *)picker didFinishPickingMediaWithAsset:(id)asset
{
    NSLog(@"didFinishPickingMediaWithAsset\n %@",asset);
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(USImagePickerController *)picker didFinishPickingMediaWithImage:(UIImage *)mediaImage
{
    NSLog(@"didFinishPickingMediaWithImage %@",mediaImage);
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    Class libraryClass;
    
    if (NSClassFromString(@"PHPhotoLibrary")) {
        libraryClass = [PHPhotoLibrary class];
    }
    else {
        libraryClass = [ALAssetsLibrary class];
    }
    
    UIImage *originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    NSDictionary *metadata = [info objectForKey:UIImagePickerControllerMediaMetadata];
    
    NSString *album = @"US";
    [libraryClass writeImage:originalImage metadata:metadata toAlbum:album completionHandler:^(id asset, NSError *error) {
        if (error) return;
        NSLog(@"照片已成功保存到相册: %@ Asset: %@",album ,asset);
    }];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
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
        NSLog(@"controller.selectedImageAssets %@", controller.selectedImageAssets);
    }];
    [controller addAction:action];
    
    action = [[ImageAction alloc] init];
    action.title = @"拍照";
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
