//
//  MyExpandTableView.m
//  Openlab
//
//  Created by admin on 16/6/14.
//  Copyright © 2016年 cn.lztech  合肥联正电子科技有限公司. All rights reserved.
//

#import "MyExpandTableView.h"
#import "AssignmentTableViewCell.h"
#import "MyAssignmentUploadViewController.h"
@interface MyExpandTableView()
@property(nonatomic,strong) ChildDataLoadBlock block;
@end
@implementation MyExpandTableView

-(instancetype)init{
    self=[super init];
    if(self){
        self.dataSource=self;
        self.delegate=self;
    }
    NSLog(@"init...");
    return self;
}
-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if(self){
        self.dataSource=self;
        self.delegate=self;
    }
    NSLog(@"initWithFrame...");
    return self;
}
-(instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style{
    self=[super initWithFrame:frame style:style];
    if(self){
        self.dataSource=self;
        self.delegate=self;
    }
    NSLog(@"initWithFrame...style ...");
    return self;

}

-(void)beginLoadChildData:(ChildDataLoadBlock)block{
    self.block=block;
}


#pragma mark datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [_courseDatas count];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    /*
     *  state expand 展开状态显示正常数据 
     *        关闭状态显示0
     */
    
    if(![[_courseDatas objectAtIndex:section] isExpandYN]){
        return 0;
    }else{
        return [[[_courseDatas objectAtIndex:section] assignmentTypes] count];
    }

}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    /*
     * 显示子节点数据
     */
    static NSString *reusableIdentifier=@"assignmentCell";
    
    AssignmentTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:reusableIdentifier];
    if(cell==nil){
        cell=[[[NSBundle mainBundle] loadNibNamed:@"AssignmentTableViewCell" owner:nil options:nil] lastObject];
        
    }
    
    NSArray *assignmentTypes=[[_courseDatas objectAtIndex:indexPath.section] assignmentTypes];
    NSArray *reportInfos=[[_courseDatas objectAtIndex:indexPath.section] reportInfos];

    
    AssignmentType *assignmentType=[assignmentTypes objectAtIndex:indexPath.row];
    
    cell.nameLabel.text=assignmentType.desc;
    cell.dueLabel.text=assignmentType.dueDate;
    
    if([self isHasReport:indexPath.section assignmentId:assignmentType.asId]){
        cell.statusLabel.text=@"已上传报告";
    }else{
        cell.statusLabel.text=@"未上传报告";
    }
   
    
    [cell setBackgroundColor:[UIColor colorWithWhite:0.9 alpha:0.7]];
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
     NSLog(@"%@",indexPath);
    MyAssignmentUploadViewController *vc=[[MyAssignmentUploadViewController alloc] init];
    NSArray<ReportInfo *> *reportInfos=[[_courseDatas objectAtIndex:indexPath.section] reportInfos];
    
    AssignmentType *assignmentType=[[[_courseDatas objectAtIndex:indexPath.section] assignmentTypes] objectAtIndex:indexPath.row];
   
    vc.reportList=reportInfos;
    vc.assignmentId=assignmentType.asId;
    vc.courseCode=assignmentType.courseCode;
    
    
    [self.viewControllerDelegate.navigationController pushViewController:vc animated:YES];
}


-(BOOL)isHasReport:(int)section assignmentId:(int)assignmentId{
    BOOL reportYN=NO;
    NSArray<ReportInfo *> *reportInfos=[[_courseDatas objectAtIndex:section] reportInfos];
    
    if(reportInfos==nil||[reportInfos count]==0){
        return reportYN;
    }
    for(ReportInfo *reportInfo in reportInfos){
        if(reportInfo.assignmentId==assignmentId){
            reportYN=YES;
            break;
        }
    }
    return reportYN;
    
}
//- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
//    return [NSString stringWithFormat:@"section %d",section];
//}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    /*
     *显示父节点数据
     */
    
    CourseType *courseType=[_courseDatas objectAtIndex:section];
    
    UIButton *backgroundView=[[UIButton alloc] initWithFrame:CGRectMake(0,0,tableView.frame.size.width, 50)];
   
    [backgroundView setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [backgroundView setTag:section];
    [backgroundView setBackgroundColor:[UIColor colorWithWhite:1 alpha:1]];
    [backgroundView addTarget:self action:@selector(groupExpand:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *arrowImageView=[[UIImageView alloc] initWithFrame:CGRectMake(10,(50-10)/2,15,10)];
    if([[_courseDatas objectAtIndex:section] isExpandYN]){
       [arrowImageView setImage:[UIImage imageNamed:@"arrow_up"]];
    }else{
       [arrowImageView setImage:[UIImage imageNamed:@"arrow_down"]];
    }
    
   
    
    
    UILabel *label=[[UILabel alloc] initWithFrame:CGRectMake(20+15,0,300,50)];
    
    
    label.text=courseType.name;
    [backgroundView addSubview:arrowImageView];
    [backgroundView addSubview:label];
    return backgroundView;
}
-(void)groupExpand:(UIButton *)sender{
    CourseType *courseType=[_courseDatas objectAtIndex:sender.tag];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
          _block(courseType.courseCode);
          dispatch_async(dispatch_get_main_queue(), ^{
              if([[_courseDatas objectAtIndex:sender.tag] isExpandYN]){
                  [[_courseDatas objectAtIndex:sender.tag] setIsExpandYN:NO];
              }else{
                  [[_courseDatas objectAtIndex:sender.tag] setIsExpandYN:YES];
              }
              
              [self reloadSections:[NSIndexSet indexSetWithIndex:sender.tag] withRowAnimation:UITableViewRowAnimationAutomatic];
          });
    });
   
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 50;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.00001;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 130;
}

@end
