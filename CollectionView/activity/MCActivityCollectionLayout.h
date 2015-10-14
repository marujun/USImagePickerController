//
//  MCActivityCollectionLayout.h
//  CollectionView
//
//  Created by 马汝军 on 15/8/5.
//  Copyright (c) 2015年 marujun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBObject.h"

extern NSString *const MCCollectionActivityKindSectionHeader;
extern NSString *const MCCollectionActivityKindSectionFooter;

extern NSString *const MCCollectionActivityKindCollectionHeader;
extern NSString *const MCCollectionActivityKindCollectionFooter;

@protocol USActivityListLayoutDelegate <UICollectionViewDelegate>
@optional
- (CGFloat)collectionView:(UICollectionView *)collectionView heightForHeaderInSection:(NSInteger)section;
- (CGFloat)collectionView:(UICollectionView *)collectionView heightForFooterInSection:(NSInteger)section;

@end

@interface MCActivityCollectionLayout : UICollectionViewLayout

@property (nonatomic, assign) CGFloat collectionHeaderHeight;
@property (nonatomic, assign) CGFloat collectionFooterHeight;

/** 第一组数据相对较少时是否随机选择样式，默认NO */
@property (nonatomic, assign) BOOL randomFirstShortSection;

/** 最后一组数据不足时是否随机选择样式，默认NO */
@property (nonatomic, assign) BOOL randomLastShortSection;

/** 如果section里 给定元素数量大于模板元素数量 循环模板往下布局时之间的间距，默认为0 */
@property (nonatomic, assign) float loopitemSpace;

/** 画布的最小高度，默认为0 */
@property (nonatomic, assign) CGFloat minContentHeight;

/** 填充内容之后画布的高度 */
@property (nonatomic, assign, readonly) CGFloat contentHeight;

/** 设置活动模板 */
- (void)setLayoutTemplate:(NSDictionary *)dictionary;

/** 把源数据(一维数组) 转换成 和模板对应的二维数组 */
- (NSMutableArray *)dataSourceWithArray:(NSArray *)array;

@end


