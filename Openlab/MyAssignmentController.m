//
//  MyAssignmentController.m
//  Openlab
//
//  Created by admin on 16/4/20.
//  Copyright © 2016年 cn.lztech  合肥联正电子科技有限公司. All rights reserved.
//

#import "MyAssignmentController.h"
#import "MyExpandTableView.h"
#import "ElApiService.h"
#import <MJRefresh/MJRefresh.h>
@interface MyAssignmentController()
{
    
}
@property(nonatomic,strong) MyExpandTableView *tableView;
@property(nonatomic,strong) NSArray *courseTypeList;
@end
@implementation MyAssignmentController
-(void)viewDidLoad{
    [super viewDidLoad];
     self.title=@"我的作业";
     self.tableView=[[MyExpandTableView alloc] initWithFrame:CGRectMake(0,64,self.view.bounds.size.width, self.view.bounds.size.height-64-49) style:UITableViewStylePlain];

    [_tableView setViewControllerDelegate:self];
    [_tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    [_tableView beginLoadChildData:^(NSString *courseCode) {
        if(![self hasExists:courseCode]){
            Turple *turple=[[ElApiService shareElApiService] getAssignmentList:courseCode];
            
            [self addAssignments:turple toCourseCode:courseCode];
            
        }

    }];
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        // 进入刷新状态后会自动调用这个block
         [self loadTableData];
    }];
    [self.tableView setBackgroundColor:[UIColor colorWithWhite:0.95 alpha:1]];

    [self.view addSubview:_tableView];
   
}

-(void)viewWillAppear:(BOOL)animated{
     [self loadTableData];
}

-(BOOL)hasExists:(NSString *)courseCode{
    BOOL hasYN=NO;
    for (int i=0;i<[_courseTypeList count];i++) {
        CourseType *courseType=[_courseTypeList objectAtIndex:i];
        if([courseType.courseCode isEqualToString:courseCode]){
            if(courseType.assignmentTypes!=nil){
              hasYN=YES;
            }
            break;
        }
        
    }

    return hasYN;
}

-(void)addAssignments:(Turple *)turple toCourseCode:(NSString *)courseCode{
    for (int i=0;i<[_courseTypeList count];i++) {
        CourseType *courseType=[_courseTypeList objectAtIndex:i];
        if([courseType.courseCode isEqualToString:courseCode]){
            
            [courseType setAssignmentTypes:turple.assignmentTypes];
            [courseType setReportInfos:turple.reportInfos];
            break;
        }
        
    }
    
    
}

-(void)loadTableData{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.courseTypeList=[[ElApiService shareElApiService] getLabCourseList];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_tableView setCourseDatas:_courseTypeList];
            [_tableView reloadData];
            [self.tableView.mj_header endRefreshing];
        });
    });
}



@end
