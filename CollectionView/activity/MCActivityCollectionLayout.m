//
//  MCActivityCollectionLayout.m
//  CollectionView
//
//  Created by 马汝军 on 15/8/5.
//  Copyright (c) 2015年 marujun. All rights reserved.
//

#import "MCActivityCollectionLayout.h"

NSString *const MCCollectionActivityKindSectionHeader = @"MCCollectionActivityKindSectionHeader";
NSString *const MCCollectionActivityKindSectionFooter = @"MCCollectionActivityKindSectionFooter";

NSString *const MCCollectionActivityKindCollectionHeader = @"MCCollectionActivityKindCollectionHeader";
NSString *const MCCollectionActivityKindCollectionFooter = @"MCCollectionActivityKindCollectionFooter";


@interface MCItemLayout : NSObject

@property (nonatomic, assign) CGFloat xOffset;
@property (nonatomic, assign) CGFloat yOffset;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;

@property (nonatomic, assign) CGFloat rotate;
@property (nonatomic, assign) CGFloat scale;
@property (nonatomic, assign) CGFloat radius;
@property (nonatomic, assign) BOOL animation;

@end

@implementation MCItemLayout
@end

@interface MCSectionLayout : NSObject

@property (nonatomic, assign) CGRect header;
@property (nonatomic, assign) CGRect footer;
@property (nonatomic, assign) CGFloat height;

@property (nonatomic, strong) NSArray *items;
@property (nonatomic, assign) NSInteger itemCount;

@end

@implementation MCSectionLayout
@end

@interface MCActivityCollectionLayout ()
{
    float _scale;
}

/** 活动模板 */
@property (nonatomic, strong) NSDictionary *template;

/** 通过模板生成的最终布局数组 */
@property (nonatomic, strong) NSMutableArray *layoutArray;

/** 通过模板生成的最终布局分类 */
@property (nonatomic, strong) NSMutableDictionary *layoutClassify;

@property (nonatomic, weak) id <USActivityListLayoutDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *sectionItemAttributes;
@property (nonatomic, strong) NSMutableArray *allItemAttributes;
@property (nonatomic, strong) NSMutableDictionary *headersAttribute;
@property (nonatomic, strong) NSMutableDictionary *footersAttribute;
@property (nonatomic, strong) UICollectionViewLayoutAttributes *collectionHeaderAttributes;
@property (nonatomic, strong) UICollectionViewLayoutAttributes *collectionFooterAttributes;
@property (nonatomic, strong) NSMutableArray *unionRects;

@end


@implementation MCActivityCollectionLayout

/// How many items to be union into a single rectangle
static const NSInteger unionSize = 20;

#pragma mark - Init
- (void)commonInit {
    _scale = [UIScreen mainScreen].bounds.size.width/320;
}

- (id)init {
    if (self = [super init]) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self commonInit];
    }
    return self;
}

- (id <USActivityListLayoutDelegate> )delegate {
    return (id <USActivityListLayoutDelegate> )self.collectionView.delegate;
}

- (void)setRandomFirstShortSection:(BOOL)randomFirstShortSection {
    if(_randomFirstShortSection != randomFirstShortSection){
        _randomFirstShortSection = randomFirstShortSection;
        [self invalidateLayout];
    }
}

- (void)setRandomLastShortSection:(BOOL)randomLastShortSection {
    if(_randomLastShortSection != randomLastShortSection){
        _randomLastShortSection = randomLastShortSection;
        [self invalidateLayout];
    }
}

- (void)setLoopitemSpace:(float)loopitemSpace
{
    if(_loopitemSpace != loopitemSpace){
        _loopitemSpace = loopitemSpace;
        [self invalidateLayout];
    }
}

/**
 *  设置活动模板
 */
- (void)setLayoutTemplate:(NSDictionary *)dictionary
{
    if (_template == dictionary) {
        return;
    }
    
    _template = dictionary;
    _layoutArray = [NSMutableArray array];
    _layoutClassify = [NSMutableDictionary dictionary];
    
    CGFloat baseWidth = [_template[@"width"] floatValue];
    _scale = [UIScreen mainScreen].bounds.size.width/baseWidth;
    
    for (NSDictionary *sectionItem in _template[@"band"]) {
        
        MCSectionLayout *sectionLayout = [[MCSectionLayout alloc] init];
        sectionLayout.height = [sectionItem[@"height"] floatValue]*_scale;
        for (NSDictionary *item in sectionItem[@"textbox"]) {
            CGRect rect = CGRectZero;
            rect.origin.x = [item[@"x"] floatValue]*_scale;
            rect.origin.y = [item[@"y"] floatValue]*_scale;
            rect.size.width = [item[@"width"] floatValue]*_scale;
            rect.size.height = [item[@"height"] floatValue]*_scale;
            
            if ([item[@"id"] isEqualToString:@"header"]) {
                sectionLayout.header = rect;
            } else if ([item[@"id"] isEqualToString:@"footer"]) {
                sectionLayout.footer = rect;
            }
        }
        
        NSMutableArray *scaleItems = [NSMutableArray array];
        for (NSDictionary *components in sectionItem[@"rect"]) {
            
            MCItemLayout *itemLayout = [[MCItemLayout alloc] init];
            
            itemLayout.xOffset = [components[@"x"] floatValue]*_scale;
            itemLayout.yOffset = [components[@"y"] floatValue]*_scale;
            itemLayout.width = [components[@"width"] floatValue]*_scale;
            itemLayout.height = [components[@"height"] floatValue]*_scale;
            
            //缩放比例
            itemLayout.scale = [components[@"scale"] floatValue];
            
            //旋转的角度
            float angle = [components[@"rotation"] floatValue];
            itemLayout.rotate = M_PI*(angle/180.f);
            
            //圆角
            itemLayout.radius = [components[@"round"] floatValue];
            
            //是否有动画
            itemLayout.animation = [components[@"animation"] boolValue];
            
            [scaleItems addObject:itemLayout];
        }
        sectionLayout.items = scaleItems;
        sectionLayout.itemCount = scaleItems.count;
        
        NSNumber *key = @(sectionLayout.itemCount);
        NSMutableArray *itemArray = _layoutClassify[key];
        if (!itemArray) {
            itemArray = [NSMutableArray array];
            [_layoutClassify setObject:itemArray forKey:key];
        }
        [itemArray addObject:sectionLayout];
        
        [_layoutArray addObject:sectionLayout];
    }
    
    [self invalidateLayout];
}

/**
 *  把源数据(一维数组) 转换成 和模板对应的二维数组
 *
 *  @param array 源数据(一维数组)
 */
- (NSMutableArray *)dataSourceWithArray:(NSArray *)array
{
    if ([self needRandomFirstSection:array.count]) {
        return [@[array] mutableCopy];
    }
    
    NSMutableArray *sourceArray = [NSMutableArray array];
    NSMutableArray *sectionArray = nil;
    
    NSInteger secIdx = 0;
    NSInteger secCount = 0;
    NSInteger itemIdx = 0;
    for (NSInteger i=0; i < array.count; i++) {
        id obj = array[i];
        
        if(i==0){
            sectionArray = [NSMutableArray array];
            [sourceArray addObject:sectionArray];
            secCount = ((MCSectionLayout *)_layoutArray[secIdx]).itemCount;
        }
        
        if (itemIdx >= secCount) {
            secIdx ++;
            if (secIdx >= _layoutArray.count) {
                secIdx = 0;
            }
            itemIdx = 0;
            sectionArray = [NSMutableArray array];
            [sourceArray addObject:sectionArray];
            secCount = ((MCSectionLayout *)_layoutArray[secIdx]).itemCount;
        }
        
        [sectionArray addObject:obj];
        itemIdx ++;
    }
    
    if (![sourceArray.lastObject count]) {
        [sourceArray removeLastObject];
    }
    
    return sourceArray;
}

- (BOOL)needRandomFirstSection:(NSInteger)count
{
    return _randomFirstShortSection && _layoutClassify && [_layoutClassify.allKeys containsObject:@(count)];
}

- (void)prepareLayout
{
    [super prepareLayout];
    
    _contentHeight = 0;
    _unionRects = [NSMutableArray array];
    _sectionItemAttributes = [NSMutableArray array];
    _allItemAttributes = [NSMutableArray array];
    
    _headersAttribute = [NSMutableDictionary dictionary];
    _footersAttribute = [NSMutableDictionary dictionary];
    
    NSInteger numberOfSections = [self.collectionView numberOfSections];
    if (numberOfSections == 0) {
        return;
    }
    NSInteger allItemCount = 0;
    for (NSInteger i=0; i<numberOfSections; i++) {
        allItemCount += [self.collectionView numberOfItemsInSection:i];
    }
    
    /*
     * set collection view header
     */
    if (_collectionHeaderHeight > 0) {
        _collectionHeaderAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:MCCollectionActivityKindCollectionHeader
                                                                                                     withIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
        _collectionHeaderAttributes.frame = CGRectMake(0, 0, self.collectionView.bounds.size.width, _collectionHeaderHeight);
        
        [self.allItemAttributes addObject:_collectionHeaderAttributes];
        
        _contentHeight += _collectionHeaderHeight;
    }
    
    /**
     *  第一组数据相对较少时随机选择样式
     */
    MCSectionLayout *randomLayout = nil;
    if([self needRandomFirstSection:allItemCount]){
        NSArray *lyArray = [_layoutClassify objectForKey:@(allItemCount)];
        randomLayout = [lyArray objectAtIndex:0]; //为了保持每次都一样，暂时选每组的第一个
        //randomLayout = [lyArray objectAtIndex:(int)(arc4random() % lyArray.count)];
    }
    
    NSInteger secTmpIdx = 0;
    UICollectionViewLayoutAttributes *attributes;
    for (NSInteger section = 0; section < numberOfSections; ++section){
        /*
         * 1. get section layout
         */
        
        NSInteger itemCount = [self.collectionView numberOfItemsInSection:section];
        
        /**
         *  最后一组数据不足时随机选择样式
         */
        MCSectionLayout *sectionLayout = randomLayout?:_layoutArray[secTmpIdx];
        if (section!=0 && section==numberOfSections-1 && _randomLastShortSection && itemCount<sectionLayout.itemCount) {
            NSArray *lyArray = [_layoutClassify objectForKey:@(itemCount)];
            sectionLayout = [lyArray objectAtIndex:0]; //为了保持每次都一样，暂时选每组的第一个
            //sectionLayout = [lyArray objectAtIndex:(int)(arc4random() % lyArray.count)];
        }
        
        secTmpIdx ++;
        if (secTmpIdx >= _layoutArray.count) {
            secTmpIdx = 0;
        }
        
        /*
         * 2. set section header
         */
        CGRect headerRect = sectionLayout.header;
        
        CGFloat headerHeight;
        CGFloat headerOffset = 0.0;
        
        if ([self.delegate respondsToSelector:@selector(collectionView:heightForHeaderInSection:)]) {
            headerHeight = [self.delegate collectionView:self.collectionView heightForHeaderInSection:section];
            headerOffset = headerHeight - headerRect.size.height;
        } else {
            headerHeight = headerRect.size.height;
        }
        
        if (!CGRectEqualToRect(headerRect, CGRectZero)) {
            attributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:MCCollectionActivityKindSectionHeader
                                                                                        withIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
            attributes.frame = CGRectMake(headerRect.origin.x,
                                          _contentHeight+headerRect.origin.y,
                                          headerRect.size.width,
                                          headerHeight);
            
            self.headersAttribute[@(section)] = attributes;
            [self.allItemAttributes addObject:attributes];
        }
        
        /*
         * 3. set section items
         */
        NSMutableArray *itemAttributes = [NSMutableArray arrayWithCapacity:itemCount];
        
        for (NSInteger idx = 0; idx < MIN(itemCount, sectionLayout.itemCount) ; idx++) {
            
            MCItemLayout *itemLayout = sectionLayout.items[idx];
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:idx inSection:section];
            attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            attributes.frame = CGRectMake(itemLayout.xOffset,
                                          _contentHeight+itemLayout.yOffset+headerOffset,
                                          itemLayout.width,
                                          itemLayout.height);
            attributes.transform = CGAffineTransformMakeRotation(itemLayout.rotate);
            attributes.transform = CGAffineTransformScale(attributes.transform, itemLayout.scale, itemLayout.scale);
            
            [_allItemAttributes addObject:attributes];
            [itemAttributes addObject:attributes];
        }
        
        [_sectionItemAttributes addObject:itemAttributes];
        
        /*
         * 4. set section footer
         */
        CGRect footerRect = sectionLayout.footer;
        
        CGFloat footerHeight;
        CGFloat footerOffset = 0.0;
        
        if ([self.delegate respondsToSelector:@selector(collectionView:heightForFooterInSection:)]) {
            footerHeight = [self.delegate collectionView:self.collectionView heightForFooterInSection:section];
            footerOffset = footerHeight - footerRect.size.height;
        } else {
            footerHeight = footerRect.size.height;
        }
        
        if (!CGRectEqualToRect(footerRect, CGRectZero)) {
            attributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:MCCollectionActivityKindSectionFooter
                                                                                        withIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
            attributes.frame = CGRectMake(footerRect.origin.x,
                                          _contentHeight+footerRect.origin.y+headerOffset,
                                          footerRect.size.width,
                                          footerHeight);
            
            self.footersAttribute[@(section)] = attributes;
            [self.allItemAttributes addObject:attributes];
        }
        
        _contentHeight += sectionLayout.height+headerOffset+footerOffset;
    }
    
    /*
     * set collection view footer
     */
    if (_collectionFooterHeight > 0) {
        _collectionFooterAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:MCCollectionActivityKindCollectionFooter
                                                                                                     withIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
        _collectionFooterAttributes.frame = CGRectMake(0, _contentHeight, self.collectionView.bounds.size.width, _collectionFooterHeight);
        
        [self.allItemAttributes addObject:_collectionFooterAttributes];
        
        _contentHeight += _collectionFooterHeight;
    }
    
    // Build union rects
    NSInteger idx = 0;
    NSInteger itemCounts = [_allItemAttributes count];
    while (idx < itemCounts) {
        CGRect unionRect = ((UICollectionViewLayoutAttributes *)_allItemAttributes[idx]).frame;
        NSInteger rectEndIndex = MIN(idx + unionSize, itemCounts);
        
        for (NSInteger i = idx + 1; i < rectEndIndex; i++) {
            unionRect = CGRectUnion(unionRect, ((UICollectionViewLayoutAttributes *)_allItemAttributes[i]).frame);
        }
        
        idx = rectEndIndex;
        
        [_unionRects addObject:[NSValue valueWithCGRect:unionRect]];
    }
}

- (CGSize)collectionViewContentSize
{
    CGSize contentSize = self.collectionView.bounds.size;
    contentSize.height = _contentHeight;
    if (contentSize.height < _minContentHeight) {
        contentSize.height = _minContentHeight;
    }
    return contentSize;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    @try {
        return _sectionItemAttributes[indexPath.section][indexPath.row];
    }
    @catch (NSException *exception) {
        NSLog(@"request layoutAttributes not exist！");
    }
    @finally {
        return [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    }
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *attribute = nil;
    if ([kind isEqualToString:MCCollectionActivityKindSectionHeader]) {
        attribute = _headersAttribute[@(indexPath.section)];
    } else if ([kind isEqualToString:MCCollectionActivityKindSectionFooter]) {
        attribute = _footersAttribute[@(indexPath.section)];
    } else if ([kind isEqualToString:MCCollectionActivityKindCollectionHeader]) {
        attribute = _collectionHeaderAttributes;
    } else if ([kind isEqualToString:MCCollectionActivityKindCollectionFooter]) {
        attribute = _collectionFooterAttributes;
    }
    return attribute;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSInteger i;
    NSInteger begin = 0, end = _unionRects.count;
    NSMutableArray *attrs = [NSMutableArray array];
    
    for (i = 0; i < _unionRects.count; i++) {
        if (CGRectIntersectsRect(rect, [_unionRects[i] CGRectValue])) {
            begin = i * unionSize;
            break;
        }
    }
    for (i = _unionRects.count - 1; i >= 0; i--) {
        if (CGRectIntersectsRect(rect, [_unionRects[i] CGRectValue])) {
            end = MIN((i + 1) * unionSize, _allItemAttributes.count);
            break;
        }
    }
    for (i = begin; i < end; i++) {
        UICollectionViewLayoutAttributes *attr = _allItemAttributes[i];
        if (CGRectIntersectsRect(rect, attr.frame)) {
            [attrs addObject:attr];
        }
    }
    
    return [NSArray arrayWithArray:attrs];
}

- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForInsertedItemAtIndexPath:(NSIndexPath *)itemIndexPath
{
    UICollectionViewLayoutAttributes* attributes = [self layoutAttributesForItemAtIndexPath:itemIndexPath];
    attributes.alpha = 0.0;
    CGRect frame = attributes.frame;
    frame.origin.x = -frame.size.width;
    attributes.frame = frame;
    return attributes;
}

- (UICollectionViewLayoutAttributes *)finalLayoutAttributesForDeletedItemAtIndexPath:(NSIndexPath *)itemIndexPath
{
    UICollectionViewLayoutAttributes* attributes = [self layoutAttributesForItemAtIndexPath:itemIndexPath];
    attributes.alpha = 0.0;
    CGRect frame = attributes.frame;
    frame.origin.x = self.collectionView.bounds.size.width;
    attributes.frame = frame;
    attributes.transform3D = CATransform3DMakeScale(0.1, 0.1, 1.0);
    return attributes;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    //响应设备旋转
    CGRect oldBounds = self.collectionView.bounds;
    if (!CGSizeEqualToSize(oldBounds.size, newBounds.size)) {
        return YES;
    }
    return NO;
}

- (void)dealloc
{
    NSLog(@"%@ dealloc!",NSStringFromClass([self class]));
}

@end


