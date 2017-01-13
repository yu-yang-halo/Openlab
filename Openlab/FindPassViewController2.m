//
//  FindPassViewController2.m
//  Openlab
//
//  Created by admin on 16/9/26.
//  Copyright © 2016年 cn.lztech  合肥联正电子科技有限公司. All rights reserved.
//

#import "FindPassViewController2.h"
#import <UIView+Toast.h>
#import "MyStringUtils.h"
#import "ElApiService.h"
#import <LGAlertView/LGAlertView.h>
@interface FindPassViewController2 ()<UITextFieldDelegate>{
    UITextField *firstResponderTF;
    CGFloat kbHeight;
    double  duration;
    NSInteger timeVal;
}
@property (weak, nonatomic) IBOutlet UITextField *nePassTF;
@property (weak, nonatomic) IBOutlet UITextField *rePassTF;
- (IBAction)fixPass:(id)sender;
@end

@implementation FindPassViewController2

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title=@"修改密码";
    self.nePassTF.delegate=self;
    self.rePassTF.delegate=self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [firstResponderTF resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)fixPass:(id)sender {
    NSString *nepass=self.nePassTF.text;
    NSString *repass=self.rePassTF.text;

    [firstResponderTF resignFirstResponder];
    
    if (![MyStringUtils isVaildPass:nepass]){
        [self.view.window makeToast:@"密码由6-20位的字母、数字、下划线组成"];
    }else if (![nepass isEqualToString:repass]){
        [self.view.window makeToast:@"两次输入密码不一致"];
    }else{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            BOOL SUCCESS=[[ElApiService shareElApiService] updateUser:nil phone:nil pass:nepass vcode:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if(SUCCESS){
                    LGAlertView *alerView=[[LGAlertView alloc] initWithTitle:@"提示" message:@"密码修改成功，请重新登录" style:(LGAlertViewStyleAlert) buttonTitles:@[@"确定"] cancelButtonTitle:nil destructiveButtonTitle:nil actionHandler:^(LGAlertView *alertView, NSString *title, NSUInteger index) {
                       [self.navigationController popToRootViewControllerAnimated:YES];
                    } cancelHandler:^(LGAlertView *alertView) {
                        
                    } destructiveHandler:^(LGAlertView *alertView) {
                        
                    }];
                    [alerView setCancelOnTouch:NO];
                    
                    [alerView showAnimated:YES completionHandler:^{
                        
                    }];
                    
                    
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
