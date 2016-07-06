//
//  USAssetsPageViewController.h
//  CollectionView
//
//  Created by marujun on 16/6/27.
//  Copyright © 2016年 marujun. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^USAssetsPageHandler)(NSInteger index);

@interface USAssetsPageViewController : UIPageViewController

/** 当前展示的照片的顺序 */
@property (nonatomic, assign) NSInteger pageIndex;

/** 当前展示的照片次序发生变化时的回调处理 */
@property (nonatomic, copy) USAssetsPageHandler indexChangedHandler;

/** 单击屏幕事件的回调处理 */
@property (nonatomic, copy) USAssetsPageHandler singleTapHandler;

- (instancetype)initWithAssets:(NSArray *)assets;

@end