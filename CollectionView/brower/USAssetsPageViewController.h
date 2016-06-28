//
//  USAssetsPageViewController.h
//  CollectionView
//
//  Created by marujun on 16/6/27.
//  Copyright © 2016年 marujun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface USAssetsPageViewController : UIPageViewController

/**
 *  The index of the photo or video with the currently showing item.
 */
@property (nonatomic, assign) NSInteger pageIndex;


- (instancetype)initWithAssets:(NSArray *)assets;

@end
