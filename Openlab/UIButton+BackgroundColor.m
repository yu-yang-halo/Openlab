//
//  UIButton+BackgroundColor.m
//  Openlab
//
//  Created by admin on 16/4/15.
//  Copyright © 2016年 cn.lztech  合肥联正电子科技有限公司. All rights reserved.
//

#import "UIButton+BackgroundColor.h"
#import <objc/runtime.h>
#define CONTEXT_NEW_VALUE "context_new_value"
@implementation UIButton(BackgroundColor)

-(instancetype)init{
    self=[super init];
    if(self!=nil){
        NSLog(@"UIButton class catagery bgcolor init");
    }
    return self;
}
-(void)setBackgroundColor:(UIColor *)color forState:(UIControlState)state{

    NSString *key=nil;
    if(state==UIControlStateNormal){
        key=@"state0";
        [self setBackgroundColor:color];
    }else{
        key=@"state1";
    }
    
    
    objc_setAssociatedObject(self, (__bridge const void *)(key),color, OBJC_ASSOCIATION_RETAIN);
    
    [self addObserver:self forKeyPath:@"self.highlighted" options:NSKeyValueObservingOptionNew context:CONTEXT_NEW_VALUE];
    
    
}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if(context==CONTEXT_NEW_VALUE){
        id value=[change objectForKey:NSKeyValueChangeNewKey];
       //  NSLog(@"change value %@",value);
        if([value intValue]==1){
            UIColor *color=objc_getAssociatedObject(self,@"state1");
            [self setBackgroundColor:color];
        }else{
            UIColor *color=objc_getAssociatedObject(self,@"state0");
            [self setBackgroundColor:color];
        }
    }
   
}


@end
