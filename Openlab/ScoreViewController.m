//
//  ScoreViewController.m
//  Openlab
//
//  Created by admin on 16/10/24.
//  Copyright © 2016年 cn.lztech  合肥联正电子科技有限公司. All rights reserved.
//

#import "ScoreViewController.h"
#import "JSDropDownMenu.h"
#import <UIView+Toast.h>
#import "ElApiService.h"
#import "ScoreTableViewCell.h"
#import <MJRefresh/MJRefresh.h>
@interface ScoreViewController ()<JSDropDownMenuDataSource,JSDropDownMenuDelegate,UITableViewDelegate,UITableViewDataSource>
{
    int seme;
    NSInteger selectYear;
    NSInteger selectSemester;
}
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UILabel *emptyView;
@property(nonatomic,strong) NSArray *semeArr;
@property(nonatomic,strong) NSArray *yearArr;
@property(nonatomic,strong) JSDropDownMenu *menu;
@property(nonatomic,strong) NSMutableArray<ScoreType *>  *scoreTypes;
@end

@implementation ScoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.semeArr=@[@"第一学期",@"第二学期",@"第三学期"];
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
    
    
    self.tableView=[[UITableView alloc] initWithFrame:CGRectMake(0,CGRectGetMaxY(_menu.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)-CGRectGetMaxY(_menu.frame))];
    
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    
    _tableView.tableFooterView=[[UIView alloc] initWithFrame:CGRectZero];
    
    
    _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        // 进入刷新状态后会自动调用这个block
        [self loadNetData];
    }];
    
    [self.view addSubview:_tableView];
    
    self.emptyView=[[UILabel alloc] initWithFrame:_tableView.frame];
    _emptyView.textAlignment=NSTextAlignmentCenter;
    _emptyView.text=@"暂无数据";
    [_emptyView setHidden:YES];
    
    [self.view addSubview:_emptyView];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        self.yearArr=[[ElApiService shareElApiService] getSemesterList];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            
            
        });
        
        
    });

    
}

-(void)loadNetData{
    if(selectYear<0||selectSemester<0){
        
        [_tableView.mj_header endRefreshing];
         [_emptyView setHidden:NO];
        return ;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.scoreTypes=[NSMutableArray new];
        NSArray *courseTypeList=[[ElApiService shareElApiService] getLabCourseList:_yearArr[selectYear] semester:(selectSemester+1)];
        
        
        for (CourseType *course in courseTypeList) {
            ScoreType *scoreType=[[ElApiService shareElApiService] getStudentScoreList:course.courseCode];
            if(scoreType==nil){
                continue;
            }
            scoreType.courseName=course.name;
            [_scoreTypes addObject:scoreType];
        }
        
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
           
            if(_scoreTypes==nil||[_scoreTypes count]<=0){
                 [_emptyView setHidden:NO];
            }else{
                 [_emptyView setHidden:YES];
            }
            [_tableView reloadData];
           
            [_tableView.mj_header endRefreshing];
        });
        
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark tableView delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(_scoreTypes==nil){
        return 0;
    }
    return [_scoreTypes count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ScoreTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"scoreCell"];
    
    if(cell==nil){
        cell=[[[NSBundle mainBundle] loadNibNamed:@"ScoreTableViewCell" owner:nil options:nil] lastObject];
    }
    
    ScoreType *scoreType=[_scoreTypes objectAtIndex:indexPath.row];
    
    
    cell.scoreLabel.text=[NSString stringWithFormat:@"分数:%.1f",scoreType.score];
    
    cell.scoreNameLabel.text=[NSString stringWithFormat:@"课程:%@",scoreType.courseName];
    cell.scoreCommentLabel.text=[NSString stringWithFormat:@"%@",scoreType.comment];
    
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
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
        
        [self loadNetData];
    }
    
}


@end
