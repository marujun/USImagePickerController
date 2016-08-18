//
//  USAssetItemViewController.h
//  USImagePickerController
//
//  Created by marujun on 16/6/27.
//  Copyright © 2016年 marujun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "USAssetScrollView.h"

@interface USAssetItemViewController : UIViewController

@property (nonatomic, strong, readonly) id asset;

@property (nonatomic, strong, readonly) USAssetScrollView *scrollView;

+ (instancetype)viewControllerForAsset:(id)asset;

@end
