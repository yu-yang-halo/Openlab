//
//  UIButton+Animation.m
//  Openlab
//
//  Created by admin on 16/4/28.
//  Copyright © 2016年 cn.lztech  合肥联正电子科技有限公司. All rights reserved.
//

#import "UIButton+Animation.h"
#import <objc/runtime.h>
#import <RBBAnimation/RBBCustomAnimation.h>
#import <RBBAnimation/RBBTweenAnimation.h>
#import <RBBAnimation/RBBCubicBezier.h>
@implementation UIButton(Animation)

-(void)beginAnimation{
   id stateOBJ=objc_getAssociatedObject(self, [NSStringFromSelector(@selector(setButtonState:)) UTF8String]);
   
   int state=[stateOBJ intValue];
   
   if(state==UIButtonState_NORMAL){
        /*
         * 执行动画
         *
         */
       
       RBBCustomAnimation *rainbow = [RBBCustomAnimation animationWithKeyPath:@"backgroundColor"];
       
       rainbow.animationBlock = ^(CGFloat elapsed, CGFloat duration) {
           UIColor *color = [UIColor colorWithHue:elapsed / duration
                                       saturation:1
                                       brightness:1
                                            alpha:1];
           
           return (id)color.CGColor;
       };
       rainbow.repeatCount=100;
       rainbow.duration=0.2;
       
       float originX=self.frame.origin.x;
       float originY=self.frame.origin.y;
       
       float width =self.frame.size.width;
       float height=self.frame.size.height;
       
     
       
       RBBTweenAnimation *boundsAnimation = [RBBTweenAnimation animationWithKeyPath:@"bounds"];
       
       boundsAnimation.fromValue =[NSValue valueWithCGRect:self.frame];
       boundsAnimation.toValue = [NSValue valueWithCGRect:CGRectMake(0,0, height, height)];
       
       boundsAnimation.duration = 0.6;
       boundsAnimation.easing=RBBEasingFunctionLinear;
       boundsAnimation.repeatCount=1;
       
     

       
       
    
       
       [self.layer addAnimation:rainbow forKey:@"backgroundColor"];
       [self.layer addAnimation:boundsAnimation forKey:@"boundsAnimation"];
        //[self.layer addAnimation:transformAnimation forKey:@"transformAnimation"];
       
   }
    
}
-(UIButtonState)myButtonState{
    id stateOBJ=objc_getAssociatedObject(self, @selector(setButtonState:));
    NSLog(@"stateOBJ %@",stateOBJ);
    return [stateOBJ intValue];
}
-(void)setButtonState:(UIButtonState)state{
    
    objc_setAssociatedObject(self, @selector(setButtonState:),@(state) , OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
     [self.layer removeAllAnimations];
    
    if(state==UIButtonState_COMPLETE){
       
        [self setBackgroundColor:[UIColor colorWithRed:71/255.0 green:157/255.0 blue:54/255.0 alpha:1]];
        [self setTitle:@"预约成功" forState:UIControlStateNormal];
    }else if (state==UIButtonState_FAILED){
        [self setBackgroundColor:[UIColor redColor]];
        [self setTitle:@"预约失败" forState:UIControlStateNormal];
    }else if(state==UIButtonState_NORMAL){
        [self setBackgroundColor:[UIColor colorWithRed:0/255.0 green:64/255.0 blue:152/255.0 alpha:1]];
        [self setTitle:@"开始预约" forState:UIControlStateNormal];
    }
    
}
@end
