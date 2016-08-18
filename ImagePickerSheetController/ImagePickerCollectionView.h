//
//  ImagePickerCollectionView.h
//  ImagePickerSheetController
//
//  Created by marujun on 15/8/6.
//  Copyright (c) 2015年 marujun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImagePreviewFlowLayout.h"

@interface ImagePickerCollectionView : UICollectionView

@property (nonatomic, assign) BOOL bouncing;
@property (nonatomic, strong) ImagePreviewFlowLayout *imagePreviewLayout;


@end
