//
//  ImagePickerSheetController.h
//  ImagePickerSheetController
//
//  Created by marujun on 15/8/6.
//  Copyright (c) 2015年 marujun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageAction.h"
#import "PreviewSupplementaryView.h"
#import "ImagePickerCollectionView.h"

@interface ImagePickerSheetController : UIViewController 

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) ImagePickerCollectionView *collectionView;

@property (nonatomic, assign) BOOL displaySelectMaxLimit;
@property (nonatomic, assign) NSInteger maximumSelection;
@property (nonatomic, assign) NSInteger numberOfSelectedImages;
@property (nonatomic, strong) NSArray *selectedImageAssets;

- (void)addAction:(ImageAction *)action;

@end
