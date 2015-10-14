//
//  ActivityViewController.h
//  CollectionView
//
//  Created by 马汝军 on 15/8/5.
//  Copyright (c) 2015年 marujun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCActivityCollectionLayout.h"

@interface ActivityViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>
{
    __weak IBOutlet UICollectionView *_collectionView;
    __weak IBOutlet MCActivityCollectionLayout *_activityLayout;
}

@end
