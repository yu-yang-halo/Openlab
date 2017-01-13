//
//  RegexUtils.m
//  Openlab
//
//  Created by admin on 16/4/19.
//  Copyright © 2016年 cn.lztech  合肥联正电子科技有限公司. All rights reserved.
//

#import "MyStringUtils.h"

@implementation MyStringUtils
+(BOOL)isVaildDomainAddr:(NSString *)domain{
    /**
     * 域名验证
     */
    NSString * PASSREG = @"(?=^.{4,253}$)(^((?!-)[a-zA-Z0-9-]{1,63}(?<!-)\\.)+[a-zA-Z]{2,63}\\.?$)";
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", PASSREG];
    
    
    if ([regextestmobile evaluateWithObject:domain] == YES)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}
+(BOOL)isVaildIpAddr:(NSString *)ipaddr
{
    /**
     * ip验证
     */
    NSString * PASSREG = @"^((?:(?:25[0-5]|2[0-4]\\d|((1\\d{2})|([1-9]?\\d)))\\.){3}(?:25[0-5]|2[0-4]\\d|((1\\d{2})|([1-9]?\\d))))$";
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", PASSREG];
    
    
    if ([regextestmobile evaluateWithObject:ipaddr] == YES)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}
+(BOOL)isVaildPass:(NSString *)pass
{
    /**
     * 密码验证
     */
    NSString * PASSREG = @"^[0-9a-zA-Z_]{6,20}$";
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", PASSREG];
    
    
    if ([regextestmobile evaluateWithObject:pass] == YES)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}
+(BOOL)isNumber:(NSString *)num{
    /**
     * 是不是数字
     */
    NSString * NUMBER = @"^\\d{2,7}$";
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", NUMBER];
    
    
    if ([regextestmobile evaluateWithObject:num] == YES)
    {
        return YES;
    }
    else
    {
        return NO;
    }

}
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
