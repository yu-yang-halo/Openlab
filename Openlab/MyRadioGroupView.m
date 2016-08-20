//
//  MyRadioGroupView.m
//  Openlab
//
//  Created by admin on 16/4/20.
//  Copyright © 2016年 cn.lztech  合肥联正电子科技有限公司. All rights reserved.
//

#import "MyRadioGroupView.h"
@interface MyRadioGroupView(){
    
    UIButton *radioButton0;
    UIButton *radioButton1;
    
    
    
    CGRect rootFrame;
    float  percentage;//button 相对比例
    float  betweenHalfSpace;//button 与中间线间距
    float  scale;//button 缩小0.6
    
    
    CGRect radioFrame0;
    CGRect radioFrame1;
    
}
@property(nonatomic,strong) RadioButtonSelectedBlock block;
@property(nonatomic,strong) NSArray *normals;
@property(nonatomic,strong) NSArray *selecteds;
@end
@implementation MyRadioGroupView

-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if(self){
        rootFrame=frame;
        percentage=0.9;
        betweenHalfSpace=10;
        scale=0.75;
        
        
        NSLog(@"initWithFrame");
    }
    return self;
}
-(void)layoutSubviews{
    
    radioButton0.frame=radioFrame0;
    radioButton1.frame=radioFrame1;
    
}
-(void)setRadioButtonClickBlock:(RadioButtonSelectedBlock)block{
    self.block=block;
    _block(0);
}

-(void)setButtonImages:(NSArray *)normals selecteds:(NSArray *)selecteds{
    if(normals==nil||[normals count]!=2){
        return ;
    }
    if(selecteds==nil||[selecteds count]!=2){
        return ;
    }
    
    self.normals=normals;
    self.selecteds=selecteds;
    
   
    
    
    radioButton0=[[UIButton alloc] initWithFrame:CGRectZero];
    radioButton1=[[UIButton alloc] initWithFrame:CGRectZero];
    
    [self addSubview:radioButton0];
    [self addSubview:radioButton1];
    
    
    
    
    [radioButton0 setTag:0];
    [radioButton0 setSelected:YES];
    [radioButton0 setImage:[UIImage imageNamed:_normals[0]] forState:UIControlStateNormal];
    [radioButton0 setImage:[UIImage imageNamed:_selecteds[0]] forState:UIControlStateSelected];
    [radioButton1 setTag:1];
    [radioButton1 setSelected:NO];
    [radioButton1 setImage:[UIImage imageNamed:_normals[1]] forState:UIControlStateNormal];
    [radioButton1 setImage:[UIImage imageNamed:_selecteds[1]] forState:UIControlStateSelected];
    
    
    [radioButton0 addTarget:self action:@selector(selectButton:) forControlEvents:UIControlEventTouchUpInside];
    [radioButton1 addTarget:self action:@selector(selectButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [self startAnimation:NO];
}



-(void)selectButton:(UIButton *)sender{
 
    if(sender.selected){
        [sender setSelected:NO];
       
    }else{
        [sender setSelected:YES];
    }
    if(sender==radioButton0){
        [radioButton1 setSelected:!sender.selected];
    }else{
        [radioButton0 setSelected:!sender.selected];
    }
    
    if(radioButton0.isSelected){
        _block(radioButton0.tag);
    }else{
        _block(radioButton1.tag);
    }
    
    [self startAnimation:YES];
    
}


-(void)layoutView{
    if(radioButton0.selected){
        
        radioFrame0=CGRectMake(rootFrame.size.width/2-rootFrame.size.height*percentage-betweenHalfSpace,rootFrame.size.height*(1-percentage)/2, rootFrame.size.height*percentage,rootFrame.size.height*percentage);
        
        radioFrame1=CGRectMake(rootFrame.size.width/2+betweenHalfSpace+rootFrame.size.height*percentage*(1-scale)/2,(rootFrame.size.height-rootFrame.size.height*percentage*scale)/2, rootFrame.size.height*percentage*scale,rootFrame.size.height*percentage*scale);
        
    }else{
        
        radioFrame0=CGRectMake(rootFrame.size.width/2-betweenHalfSpace-rootFrame.size.height*percentage+rootFrame.size.height*percentage*(1-scale)/2,(rootFrame.size.height-rootFrame.size.height*percentage*scale)/2, rootFrame.size.height*percentage*scale,rootFrame.size.height*percentage*scale);
        radioFrame1=CGRectMake(rootFrame.size.width/2+betweenHalfSpace,rootFrame.size.height*(1-percentage)/2, rootFrame.size.height*percentage,rootFrame.size.height*percentage);
        
        
    }
    radioButton0.frame=radioFrame0;
    radioButton1.frame=radioFrame1;
}
-(void)startAnimation:(BOOL)animateYN{
    if(animateYN){
        [UIView animateWithDuration:0.5 animations:^{
            [self layoutView];
        }];
    }else{
        [self layoutView];
    }
   
    
}


@end
