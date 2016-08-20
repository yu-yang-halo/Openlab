//
//  RegexUtils.m
//  Openlab
//
//  Created by admin on 16/4/19.
//  Copyright © 2016年 cn.lztech  合肥联正电子科技有限公司. All rights reserved.
//

#import "MyStringUtils.h"

@implementation MyStringUtils
+(BOOL)isMobileNumber:(NSString *)mobileNum
{
    /**
     * 手机号码  简单判断11位数字
     */
    NSString * MOBILE = @"^\\d{11}$";

    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
   
    
    if ([regextestmobile evaluateWithObject:mobileNum] == YES)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}
+(BOOL)isEmpty:(NSString *)str{
    if(str==nil){
        return YES;
    }
    str=[str stringByTrimmingCharactersInSet:[NSMutableCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if([str isEqualToString:@""]){
        return YES;
    }else{
        return NO;
    }
    
}
+(NSString *)encodeToPercentEscapeString:(NSString *)input
{
    NSString *output=@"";
    output=[input stringByAddingPercentEncodingWithAllowedCharacters: [NSCharacterSet whitespaceCharacterSet]];
    
    /*
    NSString *encodeValue=CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(nil
                                                                  ,(CFStringRef)input, nil,(CFStringRef)@"!*'();:@&=+$,/?%#[]",kCFStringEncodingUTF8));
    */
    
    return output;
}



@end
