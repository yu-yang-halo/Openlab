//
//  UIButton+Animation.h
//  Openlab
//
//  Created by admin on 16/4/28.
//  Copyright © 2016年 cn.lztech  合肥联正电子科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger,UIButtonState){
    UIButtonState_NORMAL=100,
    UIButtonState_COMPLETE,
    UIButtonState_FAILED,
};

@interface UIButton(Animation)

-(void)beginAnimation;
-(void)setButtonState:(UIButtonState)state;
-(UIButtonState)myButtonState;
@end
