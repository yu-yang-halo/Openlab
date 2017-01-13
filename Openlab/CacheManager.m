//
//  CacheManager.m
//  Openlab
//
//  Created by admin on 2016/12/14.
//  Copyright © 2016年 cn.lztech  合肥联正电子科技有限公司. All rights reserved.
//

#import "CacheManager.h"
static NSString *KEY_IP=@"key_ip";
static NSString *KEY_PORT=@"key_port";
static NSString *defaultIP=@"202.38.78.70";
static NSString *defaultPort=@"8080";
@implementation CacheManager
+(NSArray *)fetchServerIpAndPort{
    NSString *ip=[[NSUserDefaults standardUserDefaults] objectForKey:KEY_IP];
    NSString *port=[[NSUserDefaults standardUserDefaults] objectForKey:KEY_PORT];
    
    if(ip==nil||[[ip stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]){
        ip=defaultIP;
    }
    if(port==nil||[[port stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]){
        port=defaultPort;
    }
    
    
    return @[ip,port];
}
+(void)cacheServerIp:(NSString *)ipAddr AndPort:(NSString *)port{
    [[NSUserDefaults standardUserDefaults] setObject:ipAddr forKey:KEY_IP];
    [[NSUserDefaults standardUserDefaults] setObject:port forKey:KEY_PORT];
    
}
@end
