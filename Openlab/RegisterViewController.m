//
//  RegisterViewController.m
//  Openlab
//
//  Created by admin on 16/4/15.
//  Copyright © 2016年 cn.lztech  合肥联正电子科技有限公司. All rights reserved.
//

#import "RegisterViewController.h"
#import "ElApiService.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import <UIView+Toast.h>
#import "MyStringUtils.h"
@interface RegisterViewController ()<UITextFieldDelegate>{
    UITextField *firstResponderTF;
    CGFloat kbHeight;
    double  duration;
}
@property (weak, nonatomic) IBOutlet UITextField *numberTF;

@property (weak, nonatomic) IBOutlet UITextField *passwordTF;

@property (weak, nonatomic) IBOutlet UITextField *repasswordTF;
@property (weak, nonatomic) IBOutlet UITextField *realNameTF;
@property (weak, nonatomic) IBOutlet UITextField *phoneTF;

@property (weak, nonatomic) IBOutlet UIButton *registerBtn;


@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title=@"用户注册";
    
    
    [self.registerBtn.layer setCornerRadius:2.0];
    
    self.numberTF.delegate=self;
    self.passwordTF.delegate=self;
    self.repasswordTF.delegate=self;
    self.realNameTF.delegate=self;
    self.phoneTF.delegate=self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    
    [self.registerBtn addTarget:self action:@selector(beginRegister:) forControlEvents:UIControlEventTouchUpInside];
    
    
}

-(void)beginRegister:(id)sender{
    NSString *number   =self.numberTF.text;
    NSString *password =self.passwordTF.text;
    NSString *repassword =self.repasswordTF.text;
    NSString *realName =self.realNameTF.text;
    NSString *phone =self.phoneTF.text;
    
    if([MyStringUtils isEmpty:number]){
        [self.view makeToast:@"学生卡号不能为空"];
    }else if ([MyStringUtils isEmpty:password]){
        [self.view makeToast:@"密码不能为空"];
    }else if([MyStringUtils isEmpty:realName]){
        [self.view makeToast:@"姓名不能为空"];
    }else if([MyStringUtils isEmpty:phone]){
        [self.view makeToast:@"手机号码不能为空"];
    }else if(![password isEqualToString:repassword]){
        [self.view makeToast:@"两次密码不一致"];
    }else if(![MyStringUtils isMobileNumber:phone]){
        [self.view makeToast:@"请输入正确的手机号码"];
    }else{
        MBProgressHUD *hud=[MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText=@"注册中...";
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
           
            UserType *user=[[UserType alloc] init];
            user.name=number;
            user.password=password;
            user.realName=[MyStringUtils encodeToPercentEscapeString:realName];
            user.phone=phone;
            user.userRole=@"student";
            BOOL registerSuccessYN=[[ElApiService shareElApiService] createUser:user];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [hud hide:YES];
                if(registerSuccessYN){
                    [self.view.window makeToast:@"注册成功"];
                    [self.navigationController popViewControllerAnimated:YES];
                }
            });
        });
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
