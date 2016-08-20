//
//  MainViewController.m
//  Openlab
//
//  Created by admin on 16/4/20.
//  Copyright © 2016年 cn.lztech  合肥联正电子科技有限公司. All rights reserved.
//

#import "MainViewController.h"
#import "MyRadioGroupView.h"
#import "UIButton+BackgroundColor.h"
#import "DateHelper.h"
#import "NSDate+CalculateDay.h"
#import "KMDatePicker.h"
#import "UIButton+Animation.h"
#import <RBBAnimation/RBBTweenAnimation.h>
#import "ElApiService.h"
#import <ActionSheetPicker-3.0/ActionSheetStringPicker.h>
#import <UIView+Toast.h>
#import "Constants.h"
#import <LGAlertView/LGAlertView.h>
#import "TimeUtils.h"
@interface MainViewController()<UITextFieldDelegate, KMDatePickerDelegate>
{
    NSArray *labList;
    int selectedIndex;
    int labId;
    
    NSString *startTime;
    NSString *endTime;
    
    NSString *selectDate;
}

@property (weak, nonatomic) IBOutlet UIView *viewContainer0;
@property (weak, nonatomic) IBOutlet UIView *viewContainer1;
@property (weak, nonatomic) IBOutlet UILabel *labText;
@property (weak, nonatomic) IBOutlet UILabel *timeText;

@property (weak, nonatomic) IBOutlet UIButton *reservationButton;
@property (weak, nonatomic) IBOutlet UIView *viewContainerHeader;
- (IBAction)selectLab:(id)sender;
- (IBAction)selectTime:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *selectLabButton;

@property (weak, nonatomic) IBOutlet UIButton *selectTimeButton;

@end
@implementation MainViewController
-(void)viewDidLoad{
    [super viewDidLoad];
    self.title=@"首页";
    
    selectedIndex=-1;
    labId=-1;
    
    
    
    self.reservationButton.layer.cornerRadius=25;
    
    MyRadioGroupView *radioGroupView=[[MyRadioGroupView alloc] initWithFrame:self.viewContainerHeader.bounds];
    [radioGroupView setButtonImages:@[@"icon_normal0",@"icon_temp0"] selecteds:@[@"icon_normal1",@"icon_temp1"]];
    [radioGroupView setRadioButtonClickBlock:^(NSInteger tag) {
       
        NSLog(@"select index %d",tag);
        selectedIndex=tag;
        
        if(selectedIndex==0){
            [self.view.window makeToast:@"一般预约"  duration:0.5 position:CSToastPositionBottom];
        }else{
            [self.view.window makeToast:@"临时预约"  duration:0.5 position:CSToastPositionBottom];
        }
        
        [self resetData];
        
    }];
    
  
    
    
    [self.viewContainerHeader addSubview:radioGroupView];
    
    
    [self.selectLabButton setBackgroundColor:[UIColor clearColor] forState:UIControlStateNormal];
    
    [self.selectLabButton setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.8] forState:UIControlStateHighlighted];
    
    
    [self.selectTimeButton setBackgroundColor:[UIColor clearColor] forState:UIControlStateNormal];
    
    [self.selectTimeButton setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.8] forState:UIControlStateHighlighted];
    
    
    [_reservationButton setButtonState:UIButtonState_NORMAL];
    [_reservationButton addTarget:self action:@selector(toReservation:) forControlEvents:UIControlEventTouchUpInside];
    
    [self netDataGet];
    
}

-(void)resetData{
    labId=-1;
    startTime=@"";
    endTime=@"";
    selectDate=@"";
    
    _labText.text=@"";
    _timeText.text=@"";
}

-(void)netDataGet{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        labList=[[ElApiService shareElApiService] getLabListByIncDesk:NO];
        
        
    });
    
}
-(void)toReservation:(id)sender{
    
    if(_reservationButton.myButtonState!=UIButtonState_NORMAL){
        LGAlertView *alerView=[[LGAlertView alloc] initWithTitle:@"提示" message:@"是否重新预约" style:(LGAlertViewStyleAlert) buttonTitles:@[@"确定"] cancelButtonTitle:@"取消" destructiveButtonTitle:nil actionHandler:^(LGAlertView *alertView, NSString *title, NSUInteger index) {
            [_reservationButton setButtonState:UIButtonState_NORMAL];
            [self resetData];
        } cancelHandler:^(LGAlertView *alertView) {
            
        } destructiveHandler:^(LGAlertView *alertView) {
            
        }];
        
        [alerView showAnimated:YES completionHandler:^{
            
        }];
       
        return;
    }
    
    if(labId<0){
        [self.view.window makeToast:@"请选择实验室"];
    }else if (startTime==nil||[startTime isEqualToString:@""]){
        [self.view.window makeToast:@"起始时间不能为空"];
    }else if (endTime==nil||[endTime isEqualToString:@""]){
        [self.view.window makeToast:@"结束时间不能为空"];
    }else{
        
        
        NSLog(@"selectedIndex:%d,labId:%d,startTime:%@,endTime:%@",selectedIndex,labId,startTime,endTime);
        
        NSDateFormatter *formatter=[[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *date0=[formatter dateFromString:startTime];
        NSDate *date1=[formatter dateFromString:endTime];
        
        NSComparisonResult result=[date0 compare:date1];
        
        if(result==NSOrderedDescending||result==NSOrderedSame){
            [self.view.window makeToast:@"开始时间不得大于或等于结束时间"];
        }else{
            [_reservationButton beginAnimation];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
               
                
                NSString *loginName=[[NSUserDefaults standardUserDefaults] objectForKey:KEY_USERNAME];
                
                
                BOOL addOrUpdSuccess=[[ElApiService shareElApiService] addOrUpdReservation:loginName startTime:startTime endTime:endTime deskNum:-1 labId:labId status:0 resvId:0];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                   
                    if(addOrUpdSuccess){
                        [_reservationButton setButtonState:UIButtonState_COMPLETE];
                    }else{
                        [_reservationButton setButtonState:UIButtonState_FAILED];
                    }
                    
                });
                
            });
            
        }
    }
    
    
}



- (IBAction)selectLab:(id)sender {
    if(labList!=nil&&[labList count]>0){
    
        
        ActionSheetStringPicker *assp = [[ActionSheetStringPicker alloc] initWithTitle:@"选择实验室" rows:labList initialSelection:0 doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
            
            labId=[selectedValue labId];
            [self writeData:[selectedValue description] toText:_labText];
            
        } cancelBlock:^(ActionSheetStringPicker *picker) {
            NSLog(@"cancelBlock %@",picker);
        } origin:self.view];
        [assp setDoneButton:[[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:nil]];
        [assp setCancelButton:[[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:nil]];
        
        [assp showActionSheetPicker];
        
        
        
    }else{
        [self.view.window makeToast:@"实验室数据为空，请重试"];
        [self netDataGet];
    }
}

- (IBAction)selectTime:(id)sender {
    
    if(selectedIndex==0){
        [self selectDate];
    }else{
        [self selectHHmm:1];
    }
    
    
   
}

-(void)selectDate{
    CGRect rect = [[UIScreen mainScreen] bounds];
    rect = CGRectMake(0.0,self.view.frame.size.height-216.0, rect.size.width, 216.0);
    
    KMDatePicker *datePicker=[[KMDatePicker alloc] initWithFrame:rect block:^(KMDatePicker *datePicker, KMDatePickerDateModel *datePickerDate) {
        NSString *dateStr = [NSString stringWithFormat:@"%@-%@-%@",
                             datePickerDate.year,
                             datePickerDate.month,
                             datePickerDate.day
                             ];
        [self writeData:dateStr toText:_timeText];
        
        selectDate=dateStr;
        
        [self selectHHmm:0];
        
    } datePickerStyle:KMDatePickerStyleYearMonthDay];
    
    datePicker.minLimitedDate = [[DateHelper localeDate] addMonthAndDay:0 days:0];
    datePicker.maxLimitedDate = [datePicker.minLimitedDate addMonthAndDay:0 days:0];
    [datePicker setTitle:@"选择预约日期"];
    
    
    [datePicker show];

}

-(void)selectHHmm:(int)type{
    CGRect rect = [[UIScreen mainScreen] bounds];
    rect = CGRectMake(0.0,self.view.frame.size.height-216.0, rect.size.width, 216.0);
    if(selectedIndex==1){
        NSDateComponents *components=[[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute fromDate:[NSDate new]];
        
        startTime=[NSString stringWithFormat:@"%d-%@-%@ %@:%@:00",components.year,[self addZero:components.month],[self addZero:components.day],[self addZero:components.hour],[self addZero:components.minute]];
    }
    
    
    KMDatePicker *datePicker=[[KMDatePicker alloc] initWithFrame:rect block:^(KMDatePicker *datePicker, KMDatePickerDateModel *datePickerDate) {
        NSString *dateStr = [NSString stringWithFormat:@"%@:%@:00",
                             [self addZero:[datePickerDate.hour intValue]],
                             [self addZero:[datePickerDate.minute intValue]]
                             ];
       
        
        if(type==0){
            startTime=[NSString stringWithFormat:@"%@ %@",selectDate,dateStr];
            [self writeData:startTime toText:_timeText];
            
            [self selectHHmm:1];
        }else{
            if(selectedIndex==1){
               NSDateComponents *components=[[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute fromDate:[NSDate new]];
                
                endTime=[NSString stringWithFormat:@"%d-%@-%@ %@",components.year,[self addZero:components.month],[self addZero:components.day],dateStr];
       
                [self writeData:[NSString stringWithFormat:@"开始时间:%@\n结束时间:%@",startTime,endTime] toText:_timeText];
            }else{
                endTime=[NSString stringWithFormat:@"%@ %@",selectDate,dateStr];
                [self writeData:[NSString stringWithFormat:@"开始时间:%@\n结束时间:%@",startTime,endTime] toText:_timeText];
            }
          
        }
        
        
    } datePickerStyle:KMDatePickerStyleHourMinute];
    
    if(type==0){
         [datePicker setTitle:@"开始时间"];
    }else{
         NSDate *date=[TimeUtils dateFromString:startTime format:@"yyyy-MM-dd HH:mm:ss"];
         NSDate *newDate0=[TimeUtils addHoursAndMin:0 minutes:30 toDate:date];
        
         [datePicker setScrollToDate:newDate0];
         [datePicker setTitle:@"结束时间"];
    }
   
    
    
    [datePicker show];
}
-(NSString *)addZero:(int)val{
    if(val>=0&&val<10){
        return [NSString stringWithFormat:@"0%d",val];
    }else{
        return [NSString stringWithFormat:@"%d",val];
    }
}

-(void)writeData:(NSString *)dataStr toText:(UILabel *)label{
    float x=label.frame.origin.x;
    float width=label.frame.size.width;
    
    
    CGSize size=[dataStr sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]}];
    
    float fromX=self.view.frame.size.width-(x+(width-size.width)/2)+x;
    
    
    
    label.text=[NSString stringWithFormat:@"%@",dataStr];
    RBBTweenAnimation *animation = [RBBTweenAnimation animationWithKeyPath:@"position.x"];
    
    animation.fromValue=@(fromX);
    animation.toValue=@(x);
    animation.duration=1.5;
    animation.additive=YES;
    
    [label.layer addAnimation:animation forKey:@"animation"];

}



#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
}

//#pragma mark - KMDatePickerDelegate
//- (void)datePicker:(KMDatePicker *)datePicker didSelectDate:(KMDatePickerDateModel *)datePickerDate {
//    
//  
//    [self show];
//}


@end
