//
//  MyReservationController.m
//  Openlab
//
//  Created by admin on 16/4/20.
//  Copyright © 2016年 cn.lztech  合肥联正电子科技有限公司. All rights reserved.
//

#import "MyReservationController.h"
#import <HMSegmentedControl/HMSegmentedControl.h>
#import "ElApiService.h"
#import "Constants.h"
#import "ReservationTableViewCell.h"
#import "TimeUtils.h"
#import <UIView+Toast.h>
#import <MJRefresh/MJRefresh.h>
@interface MyReservationController()<UITableViewDataSource,UITableViewDelegate>
{
    NSArray<ReservationType *> *reservationArr;
    
    NSMutableArray<ReservationType *> *currentArr;
    int currentStatus;
    
    UserType *user;
    NSArray  *lablist;
    NSString *userName;
}
@property(nonatomic,strong) UITableView *tableView;
@property(nonatomic,strong) UILabel     *emptyView;
@end

@implementation MyReservationController
-(void)viewDidLoad{
    [super viewDidLoad];
     self.title=@"我的预约";
    userName=[[NSUserDefaults standardUserDefaults] objectForKey:KEY_USERNAME];
    
    HMSegmentedControl *segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:@[@"当前预约", @"已激活", @"已取消",@"已过期",@"已使用"]];
    currentStatus=STATUS_NORMAL;
    [segmentedControl setSelectedSegmentIndex:0];
    segmentedControl.selectionIndicatorHeight=4.0;
    [segmentedControl setSelectionStyle:HMSegmentedControlSelectionStyleFullWidthStripe];
    
    [segmentedControl setSelectionIndicatorLocation:HMSegmentedControlSelectionIndicatorLocationDown];
    [segmentedControl setBackgroundColor:[UIColor colorWithRed:115/255.0 green:162/255.0 blue:232/255.0 alpha:1]];
    [segmentedControl setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont systemFontOfSize:14]}];
    [segmentedControl setSelectionIndicatorColor:[UIColor colorWithRed:59/255.0 green:127/255.0 blue:229/255.0 alpha:1.0]];
   
    [segmentedControl setSelectionIndicatorBoxOpacity:0.8];
    segmentedControl.frame = CGRectMake(0,64,self.view.bounds.size.width, 45);
    [segmentedControl addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:segmentedControl];
    
    self.tableView=[[UITableView alloc] initWithFrame:CGRectMake(0, 64+45, self.view.bounds.size.width,self.view.bounds.size.height-64-45-49) style:UITableViewStylePlain];
    
    self.emptyView=[[UILabel alloc] initWithFrame:_tableView.frame];
    _emptyView.textAlignment=NSTextAlignmentCenter;
    _emptyView.text=@"暂无数据";
    [_emptyView setHidden:YES];
    
    
    
    _tableView.delegate=self;
    _tableView.dataSource=self;
    [_tableView setRowHeight:153];
    [_tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    
    [self.view addSubview:_tableView];
    [self.view addSubview:_emptyView];
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        // 进入刷新状态后会自动调用这个block
        [self netDataGet];
    }];
    
   
    
}
-(void)viewWillAppear:(BOOL)animated{
    // 马上进入刷新状态
    [self.tableView.mj_header beginRefreshing];
}

-(void)netDataGet{
    
    if([NSThread currentThread]==[NSThread mainThread]){
        [self.emptyView setHidden:YES];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

       
        reservationArr=[[ElApiService shareElApiService] getReservationList:userName];
        user=[[ElApiService shareElApiService] getUser];
        lablist=[[ElApiService shareElApiService] getLabListByIncDesk:NO];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.tableView.mj_header endRefreshing];
            [self filterAndReloadData];
        });
        
    });
}

-(void)filterAndReloadData{
    currentArr=[NSMutableArray new];
    for (ReservationType *type in reservationArr) {
        if(type.status==currentStatus){
            [currentArr addObject:type];
        }
    }
    if([currentArr count]==0){
        [self.emptyView setHidden:NO];
    }else{
        [self.emptyView setHidden:YES];
    }
   
    
    [_tableView reloadData];
}


-(void)segmentedControlChangedValue:(HMSegmentedControl *)sender{
    NSLog(@"index %d",sender.selectedSegmentIndex);
    switch (sender.selectedSegmentIndex) {
        case 0:
            currentStatus=STATUS_NORMAL;
            break;
        case 1:
            currentStatus=STATUS_ACTIVE;
            break;
        case 2:
            currentStatus=STATUS_CANCEL;
            break;
        case 3:
            currentStatus=STATUS_EXPIRED;
            break;
        case 4:
            currentStatus=STATUS_USED;
            break;
    }
     [self filterAndReloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [currentArr count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ReservationTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"ReservationTableViewCell"];
    if(cell==nil){
        cell=[[[NSBundle mainBundle] loadNibNamed:@"ReservationTableViewCell" owner:nil options:nil] lastObject];
    }
    ReservationType *reservationType=[currentArr objectAtIndex:indexPath.row];
    
    cell.labnameText.text=[self findLabName:reservationType.labId];
    cell.usernameText.text=user.realName;
    cell.deskNumText.text=[NSString stringWithFormat:@"%d",reservationType.deskNum];
    
    cell.startTimeText.text=[TimeUtils normalShowTime:reservationType.startTime];
    cell.endTimeText.text=[TimeUtils normalShowTime:reservationType.endTime];
    
    if(reservationType.status==STATUS_NORMAL){
        [cell.cancelBtn setHidden:NO];
        [cell.cancelBtn setTag:indexPath.row];
        [cell.cancelBtn addTarget:self action:@selector(cancelReservation:) forControlEvents:UIControlEventTouchUpInside];
    }else{
        [cell.cancelBtn setHidden:YES];
    } 
    
    return cell;
}
-(void)cancelReservation:(UIButton *)sender{
    int index=sender.tag;
    ReservationType *reservationOBJ=[currentArr objectAtIndex:index];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
         BOOL isSuccessYN=[[ElApiService shareElApiService] addOrUpdReservation:userName startTime:[TimeUtils normalShowTime:reservationOBJ.startTime] endTime:[TimeUtils normalShowTime:reservationOBJ.endTime] deskNum:reservationOBJ.deskNum labId:reservationOBJ.labId status:STATUS_CANCEL resvId:reservationOBJ.resvId];
        dispatch_async(dispatch_get_main_queue(), ^{
            if(isSuccessYN){
                 [self netDataGet];
            }else{
                [self.view.window makeToast:@"无法取消"];
            }
           
        });
    });
}
-(NSString *)findLabName:(int)labId{
    NSString *labName=@"";
    for (LabInfoType *labInfo in lablist) {
        if(labInfo.labId==labId){
            labName=labInfo.name;
            break;
        }
    }
    return labName;
}

@end
