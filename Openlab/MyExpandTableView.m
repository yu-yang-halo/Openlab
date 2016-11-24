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
#import "UIColor+hexStr.h"
@interface MyExpandTableView(){
    int clickParentIndex;
}
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
    clickParentIndex=-1;
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
        
        if([[_courseDatas objectAtIndex:section] scoreType]==nil){
            return [[[_courseDatas objectAtIndex:section] assignmentTypes] count];
            
        }else{
            return [[[_courseDatas objectAtIndex:section] assignmentTypes] count]+1;

        }
        
    }

}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *reusableIdentifierHeader=@"assignmentCellHeader";
    static NSString *reusableIdentifier=@"assignmentCell";
    int row=indexPath.row;
    
    ScoreType *scoreType=[[_courseDatas objectAtIndex:indexPath.section] scoreType];
    
    
     //没有期末成绩时
    if(scoreType!=nil){
        if(indexPath.row==0){
            UITableViewCell *cell=[tableView dequeueReusableHeaderFooterViewWithIdentifier:reusableIdentifierHeader];
            
            if(cell==nil){
                cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reusableIdentifierHeader];
                
            }
            [cell setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.5]];
        
           
            cell.textLabel.text=[NSString stringWithFormat:@"你的期末成绩 : %.1f",scoreType.score];
            [cell.textLabel setFont:[UIFont systemFontOfSize:16]];
            
            [cell.textLabel setTextColor:[UIColor colorWithHexString:@"#0067DC"]];
            
            [cell setUserInteractionEnabled:NO];
            return cell;
        }
        
        
         row=indexPath.row-1;
    }
   
    /*
     * 显示子节点数据
     */
    
    
    AssignmentTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:reusableIdentifier];
    if(cell==nil){
        cell=[[[NSBundle mainBundle] loadNibNamed:@"AssignmentTableViewCell" owner:nil options:nil] lastObject];
        
    }
    
    NSArray *assignmentTypes=[[_courseDatas objectAtIndex:indexPath.section] assignmentTypes];
//    NSArray *reportInfos=[[_courseDatas objectAtIndex:indexPath.section] reportInfos];
    
    
    
    AssignmentType *assignmentType=[assignmentTypes objectAtIndex:row];
    ReportInfo *reportInfo=[self findAssignmentReport:indexPath.section assignmentId:assignmentType.asId];
    
    cell.nameLabel.text=assignmentType.desc;
    cell.dueLabel.text=[NSString stringWithFormat:@"过期时间:%@",assignmentType.dueDate];
    
    if(reportInfo!=nil){
        cell.statusLabel.text=@"已上传报告";
    }else{
        cell.statusLabel.text=@"未上传报告";
    }
    
    if (reportInfo.status==1) {
        [cell.scoreLabel setTextColor:[UIColor colorWithHexString:@"#0067DC"]];
        [cell.scoreLabel setText:[NSString stringWithFormat:@"作业成绩:%.1f",reportInfo.score]];
        
        cell.statusLabel.text=@"成绩已出";
        
    }else{
        [cell.scoreLabel setText:@""];
    }
    [cell setBackgroundColor:[UIColor colorWithWhite:0.9 alpha:0.7]];
    
    return cell;

   
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ScoreType *scoreType=[[_courseDatas objectAtIndex:indexPath.section] scoreType];
    
    
    NSUInteger row=indexPath.row;
    
    if(scoreType!=nil){
       
        if(indexPath.row==0){
            return;
        }
        
        row=indexPath.row-1;
    }
    
    NSLog(@"%@",indexPath);
    clickParentIndex=indexPath.section;
    MyAssignmentUploadViewController *vc=[[MyAssignmentUploadViewController alloc] init];
    NSArray<ReportInfo *> *reportInfos=[[_courseDatas objectAtIndex:indexPath.section] reportInfos];
    
    AssignmentType *assignmentType=[[[_courseDatas objectAtIndex:indexPath.section] assignmentTypes] objectAtIndex:row];
   
    vc.reportList=reportInfos;
    vc.assignmentId=assignmentType.asId;
    vc.courseCode=assignmentType.courseCode;
    vc.title=assignmentType.desc;
    
    
    [self.viewControllerDelegate.navigationController pushViewController:vc animated:YES];
}

-(ReportInfo *)findAssignmentReport:(int)section assignmentId:(int)assignmentId{
    NSArray<ReportInfo *> *reportInfos=[[_courseDatas objectAtIndex:section] reportInfos];
    ReportInfo *_reportInfo=nil;
    for(ReportInfo *reportInfo in reportInfos){
        if(reportInfo.assignmentId==assignmentId){
            _reportInfo=reportInfo;
            break;
        }
    }
    
    return _reportInfo;
    
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
    
    UIImageView *arrowImageView=[[UIImageView alloc] initWithFrame:CGRectMake(10,(50-6)/2,13,6)];
    if([[_courseDatas objectAtIndex:section] isExpandYN]){
       [arrowImageView setImage:[UIImage imageNamed:@"arrow_up"]];
    }else{
       [arrowImageView setImage:[UIImage imageNamed:@"arrow_down"]];
    }
    
    UILabel *label=[[UILabel alloc] initWithFrame:CGRectMake(70,0,250,50)];
    [label setTextAlignment:NSTextAlignmentLeft];
    [label setFont:[UIFont systemFontOfSize:17]];
    
    label.text=courseType.name;
   
    [backgroundView addSubview:arrowImageView];
    [backgroundView addSubview:label];
    return backgroundView;
}
-(void)reloadChildDataUseCache:(BOOL)useCache{
    if(clickParentIndex<0){
        return;
    }
    [[_courseDatas objectAtIndex:clickParentIndex] setIsExpandYN:NO];
    [self reloadChildData:clickParentIndex useCache:useCache];
}
-(void)reloadChildData:(int)selectCourseIndex useCache:(BOOL)useCache{
  
    CourseType *courseType=[_courseDatas objectAtIndex:selectCourseIndex];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        _block(courseType.courseCode,useCache);
        dispatch_async(dispatch_get_main_queue(), ^{
            if([[_courseDatas objectAtIndex:selectCourseIndex] isExpandYN]){
                [[_courseDatas objectAtIndex:selectCourseIndex] setIsExpandYN:NO];
            }else{
                [[_courseDatas objectAtIndex:selectCourseIndex] setIsExpandYN:YES];
            }
            
            [self reloadSections:[NSIndexSet indexSetWithIndex:selectCourseIndex] withRowAnimation:UITableViewRowAnimationFade];
            
        });
    });
}

-(void)groupExpand:(UIButton *)sender{
    //clickParentIndex=sender.tag;
    [self reloadChildData:sender.tag useCache:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 50;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    ScoreType *scoreType=[[_courseDatas objectAtIndex:indexPath.section] scoreType];
    
    if(scoreType!=nil&&indexPath.row==0){
        return 50;
    }
    return 130;
}

@end
