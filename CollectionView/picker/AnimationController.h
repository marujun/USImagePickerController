//
//  AnimationController.h
//  CollectionView
//
//  Created by marujun on 15/8/6.
//  Copyright (c) 2015年 marujun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImagePickerSheetController.h"

@interface AnimationController : NSObject

- (instancetype)init:(ImagePickerSheetController *)imagePickerSheetController presenting:(BOOL)presenting;

@end
