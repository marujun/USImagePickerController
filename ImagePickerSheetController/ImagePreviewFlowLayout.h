//
//  ImagePreviewFlowLayout.h
//  ImagePickerSheetController
//
//  Created by 马汝军 on 15/8/5.
//  Copyright (c) 2015年 marujun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImagePreviewFlowLayout : UICollectionViewFlowLayout

@property (nonatomic, strong) NSIndexPath *invalidationCenteredIndexPath;

@property (nonatomic, assign) BOOL showsSupplementaryViews;


@end
