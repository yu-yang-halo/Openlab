//
//  MyAssignmentUploadViewController.h
//  Openlab
//
//  Created by admin on 16/7/22.
//  Copyright © 2016年 cn.lztech  合肥联正电子科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyAssignmentUploadViewController : UIViewController
@property(nonatomic,strong) NSArray *reportList;
@property(nonatomic,assign) int assignmentId;
@property(nonatomic,strong) NSString *courseCode;
@end
