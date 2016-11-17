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
#import "TimeUtils.h"
#import "JSDropDownMenu.h"
#import <UIView+Toast.h>
@interface MyAssignmentController()<JSDropDownMenuDataSource,JSDropDownMenuDelegate>
{
    int seme;

    NSInteger selectYear;
    NSInteger selectSemester;
}
@property(nonatomic,strong) MyExpandTableView *tableView;
@property(nonatomic,strong) JSDropDownMenu *menu;
@property(nonatomic,strong) NSArray *courseTypeList;
@property(nonatomic,strong) NSArray *semeArr;
@property(nonatomic,strong) NSArray *yearArr;
@end
@implementation MyAssignmentController
-(void)viewDidLoad{
    [super viewDidLoad];
     self.title=@"我的作业";
     self.semeArr=@[@"第一学期",@"第二学期"];
     self.yearArr=@[@"2016",@"2017"];
     selectYear=-1;
     selectSemester=-1;
    
    
    self.menu = [[JSDropDownMenu alloc] initWithOrigin:CGPointMake(0, 64) andHeight:45];

    
    _menu.indicatorColor = [UIColor colorWithRed:175.0f/255.0f green:175.0f/255.0f blue:175.0f/255.0f alpha:1.0];
    _menu.separatorColor = [UIColor colorWithRed:210.0f/255.0f green:210.0f/255.0f blue:210.0f/255.0f alpha:1.0];
    _menu.textColor = [UIColor colorWithRed:83.f/255.0f green:83.f/255.0f blue:83.f/255.0f alpha:1.0f];
    _menu.dataSource = self;
    _menu.delegate = self;

    
    [self.view addSubview:_menu];
    
    
    
     self.tableView=[[MyExpandTableView alloc] initWithFrame:CGRectMake(0,64+45,self.view.bounds.size.width, self.view.bounds.size.height-64-49-45) style:UITableViewStylePlain];

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
    [self.tableView setBackgroundColor:[UIColor colorWithWhite:1 alpha:1]];

    [self.view addSubview:_tableView];
    
    id semeOBJ=[[NSUserDefaults standardUserDefaults] objectForKey:@"SEME"];
    if(semeOBJ==nil){
        seme=1;
    }else{
        seme=[semeOBJ intValue];
    }
    
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        self.yearArr=[[ElApiService shareElApiService] getSemesterList];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
           
            
            
        });
        
        
    });
    
}


-(void)viewWillAppear:(BOOL)animated{
    [_tableView reloadChildData];
    

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
        
        if(selectYear<0||selectSemester<0){
            [self.tableView.mj_header endRefreshing];
            return ;
        }
        
        self.courseTypeList=[[ElApiService shareElApiService] getLabCourseList:_yearArr[selectYear] semester:(selectSemester+1)];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_tableView setCourseDatas:_courseTypeList];
            [_tableView reloadData];

            
            
            [self.tableView.mj_header endRefreshing];
            
            if(_courseTypeList==nil||[_courseTypeList count]<=0){
                [self.view makeToast:@"暂无作业~" duration:5 position:CSToastPositionCenter];
            }
        });
    });
}

#pragma mark dropmenu delegate

- (NSInteger)numberOfColumnsInMenu:(JSDropDownMenu *)menu{
    return 2;
}

- (NSInteger)menu:(JSDropDownMenu *)menu numberOfRowsInColumn:(NSInteger)column leftOrRight:(NSInteger)leftOrRight leftRow:(NSInteger)leftRow{
    if(column==0){
        return _yearArr.count;
    }else if(column==1){
        return _semeArr.count;
    }
    return 0;
}
- (NSString *)menu:(JSDropDownMenu *)menu titleForRowAtIndexPath:(JSIndexPath *)indexPath{
    if (indexPath.column==0) {
        return _yearArr[indexPath.row];
    } else {
        return _semeArr[indexPath.row];
    }
    
}
- (NSString *)menu:(JSDropDownMenu *)menu titleForColumn:(NSInteger)column{
    switch (column) {
        case 0: return @"选择学年";
            break;
        case 1: return @"选择学期";
            break;
        default:
            return nil;
            break;
    }
}
/**
 * 表视图显示时，左边表显示比例
 */
- (CGFloat)widthRatioOfLeftColumn:(NSInteger)column{
    return 1;
}
/**
 * 表视图显示时，是否需要两个表显示
 */
- (BOOL)haveRightTableViewInColumn:(NSInteger)column{
      return NO;
}

/**
 * 返回当前菜单左边表选中行
 */
- (NSInteger)currentLeftSelectedRow:(NSInteger)column{
    if (column==0) {
        return selectYear;
    }
    if (column==1) {
        return selectSemester;
    }
    return 0;
}
- (void)menu:(JSDropDownMenu *)menu didSelectRowAtIndexPath:(JSIndexPath *)indexPath{
    if (indexPath.column == 0) {
        selectYear=indexPath.row;
    } else if(indexPath.column == 1){
        selectSemester = indexPath.row;
    }
    
    if(selectYear<0||selectSemester<0){
        [self.view.window makeToast:@"请选择学年和学期"];
    }else{
        [self loadTableData];
        
    }

}

@end
