//
//  MyExpandTableView.h
//  Openlab
//
//  Created by admin on 16/6/14.
//  Copyright © 2016年 cn.lztech  合肥联正电子科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyObjectDataBean.h"
typedef void (^ChildDataLoadBlock)(int courseId,BOOL useCache);
@interface MyExpandTableView : UITableView<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,strong) NSArray<CourseType *> *courseDatas;
@property(nonatomic,weak) UIViewController *viewControllerDelegate;
-(void)beginLoadChildData:(ChildDataLoadBlock)block;
-(void)reloadChildDataUseCache:(BOOL)useCache;
@end
