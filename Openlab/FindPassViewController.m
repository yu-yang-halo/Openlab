//
//  FindPassViewController.m
//  Openlab
//
//  Created by admin on 16/9/19.
//  Copyright © 2016年 cn.lztech  合肥联正电子科技有限公司. All rights reserved.
//

#import "FindPassViewController.h"
#import "MyStringUtils.h"
#import <UIView+Toast.h>
#import "ElApiService.h"
@interface FindPassViewController ()<UITextFieldDelegate>{
      UITextField *firstResponderTF;
      CGFloat kbHeight;
      double  duration;
      NSInteger timeVal;
}
@property(nonatomic,strong) NSTimer *timer;
@property (weak, nonatomic) IBOutlet UITextField *numberTF;
@property (weak, nonatomic) IBOutlet UITextField *phoneTF;
@property (weak, nonatomic) IBOutlet UITextField *nePassTF;
@property (weak, nonatomic) IBOutlet UITextField *rePassTF;
@property (weak, nonatomic) IBOutlet UITextField *vcodeTF;
@property (weak, nonatomic) IBOutlet UIButton *vcodeBtn;
- (IBAction)fixPass:(id)sender;

@end

@implementation FindPassViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.title=@"修改密码";
    self.numberTF.delegate=self;
    self.nePassTF.delegate=self;
    self.rePassTF.delegate=self;
    self.vcodeTF.delegate=self;
    self.phoneTF.delegate=self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    
    [self.vcodeBtn addTarget:self action:@selector(getVCode:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [firstResponderTF resignFirstResponder];
}
-(void)getVCode:(id)sender{
    [firstResponderTF resignFirstResponder];
    NSString *phone =self.phoneTF.text;
    if(![MyStringUtils isMobileNumber:phone]){
        [self.view makeToast:@"请输入正确的手机号码"];
    }else{
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[ElApiService shareElApiService] sendShortMsgCode:phone type:0];
        });
        
        [self.vcodeBtn setUserInteractionEnabled:NO];
        timeVal=40;
        self.timer=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(secondsUpdate) userInfo:nil repeats:YES];
    }
}
-(void)secondsUpdate{
    [self.vcodeBtn setTitle:[NSString stringWithFormat:@"%ds",timeVal] forState:UIControlStateNormal];
    
    timeVal--;
    if(timeVal<=0){
        [_vcodeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
        [_vcodeBtn setUserInteractionEnabled:YES];
        [_timer invalidate];
    }
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)fixPass:(id)sender {
    [firstResponderTF resignFirstResponder];
    
    NSString *loginName=self.numberTF.text;
    
    NSString *nepass=self.nePassTF.text;
    NSString *repass=self.rePassTF.text;
    NSString *vcode=self.vcodeTF.text;
    NSString *phone=self.phoneTF.text;
    
    
    if([MyStringUtils isEmpty:loginName]){
        [self.view.window makeToast:@"学号或职工号不能为空"];
    }else if (![MyStringUtils isVaildPass:nepass]){
        [self.view.window makeToast:@"密码由6-20位的字母、数字、下划线组成"];
    }else if (![nepass isEqualToString:repass]){
        [self.view.window makeToast:@"两次输入密码不一致"];
    }else if (![MyStringUtils isMobileNumber:phone]){
        [self.view.window makeToast:@"请输入正确的手机号"];
    }else if ([MyStringUtils isEmpty:vcode]){
        [self.view.window makeToast:@"验证码不能为空"];
    }else{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            BOOL SUCCESS=[[ElApiService shareElApiService] updateUser:loginName phone:phone pass:nepass vcode:vcode];
            dispatch_async(dispatch_get_main_queue(), ^{
               
                if(SUCCESS){
                    [self.view.window makeToast:@"密码修改成功"];
                    [self.navigationController popViewControllerAnimated:YES];
                }else{
                    [self.view.window makeToast:@"密码修改失败,请重试"];
                }
                
            });
            
        });
    }
    
   
}



#pragma mark UITextField delegate
-(void)autoLayoutSelfView{
    if(kbHeight<=0||firstResponderTF==nil){
        return;
    }
    CGFloat offset=kbHeight-(self.view.frame.size.height-firstResponderTF.frame.origin.y-firstResponderTF.frame.size.height);
    offset=offset>0?offset+70:((-offset)<40?70:0);
    
    
    [UIView animateWithDuration:duration animations:^{
        CGRect frame=self.view.frame;
        frame.origin.y=-offset;
        
        self.view.frame=frame;
    }];
}

-(void)keyBoardWillShow:(NSNotification *)notification{
    kbHeight=[[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    duration=[[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [self autoLayoutSelfView];
}

-(void)keyBoardWillHide:(NSNotification *)notification{
    
    double duration2=[[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [UIView animateWithDuration:duration2 animations:^{
        CGRect frame=self.view.frame;
        frame.origin.y=0;
        self.view.frame=frame;
    }];
    
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    
    return YES;
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    firstResponderTF=textField;
    [self autoLayoutSelfView];
    return YES;
}

@end
