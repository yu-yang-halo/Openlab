//
//  ElApiService.m
//  ehome
//
//  Created by admin on 14-7-21.
//  Copyright (c) 2014年 cn.lztech  合肥联正电子科技有限公司. All rights reserved.
//

#import "ElApiService.h"
#import "GDataXMLNode.h"
#import "WsqMD5Util.h"

const static int DEFAULT_TIME_OUT=11;
const static NSString* WEBSERVICE_IP=@"202.38.78.70";
const static int WEBSERVICE_PORT=8080;
static  NSString* KEY_USERID=@"userID_KEY";
static  NSString* KEY_SECTOKEN=@"sectoken_KEY";

@interface ElApiService()
-(NSData *)requestURLSync:(NSString *)service;
-(NSData *)requestURL:(NSString *)service;
-(GDataXMLElement *)getRootElementByData:(NSData *)data;
#pragma mark 网络错误汇报
-(void)notificationErrorCode:(NSString *)errorCode;
@end

@implementation ElApiService

+(ElApiService *) shareElApiService{
    @synchronized([ElApiService class]){
        if(shareService==nil){
            shareService=[[ElApiService alloc] init];
            shareService.openlabUrl=[NSString stringWithFormat:@"http://%@:%d/elws/services/openlab/",WEBSERVICE_IP,WEBSERVICE_PORT];
            shareService.authapiUrl=[NSString stringWithFormat:@"http://%@:%d/elws/services/authapi/",WEBSERVICE_IP,WEBSERVICE_PORT];
        }
        return shareService;
    }
    
}
/***********************************
 * webService API begin...
 
    authapi
 ***********************************
 */

-(BOOL)login:(NSString *)name password:(NSString *)pass{
    return [self syslogin:name password:[WsqMD5Util getmd5WithString:pass]];
}

-(BOOL)logout{
    NSString *userID=[[NSUserDefaults standardUserDefaults] objectForKey:KEY_USERID];
    NSString *secToken=[[NSUserDefaults standardUserDefaults] objectForKey:KEY_SECTOKEN];
    NSString *service=[NSString stringWithFormat:@"%@logout?userId=%@&secToken=%@",self.authapiUrl,userID,secToken];
    NSLog(@"logout service:%@",service);
    
    NSData *data=[self requestURLSync:service];
    if(data!=nil){
        GDataXMLElement *rootElement=[self getRootElementByData:data];
        
        NSString* errorCodeVal=[[[rootElement elementsForName:@"errorCode"] objectAtIndex:0] stringValue];
        NSString* errorMsgVal=[[[rootElement elementsForName:@"errorMsg"] objectAtIndex:0] stringValue];
        
    
        if([errorCodeVal isEqualToString:@"0"]){
            
            
            return YES;
        }else{
            [self notificationErrorCode:errorMsgVal];
        }
        
    }
    
    return NO;
}

-(BOOL)syslogin:(NSString *)name password:(NSString *)pass{
 
    NSString *service=[NSString stringWithFormat:@"%@login?name=%@&password=%@",self.authapiUrl,name,pass];
    NSLog(@"login service:%@",service);
    NSData *data=[self requestURLSync:service];
    if(data!=nil){
        GDataXMLElement *rootElement=[self getRootElementByData:data];
        
        NSString* errorCodeVal=[[[rootElement elementsForName:@"errorCode"] objectAtIndex:0] stringValue];
        NSString* userIdVal=[[[rootElement elementsForName:@"userId"] objectAtIndex:0] stringValue];
        NSString* secTokenVal=[[[rootElement elementsForName:@"secToken"] objectAtIndex:0] stringValue];
       
        
        NSLog(@"errorCode:%@, userId:%@ ,secToken:%@",errorCodeVal,userIdVal,secTokenVal);
        if([errorCodeVal isEqualToString:@"0"]){
            [[NSUserDefaults standardUserDefaults] setObject:userIdVal forKey:KEY_USERID];
            [[NSUserDefaults standardUserDefaults] setObject:secTokenVal forKey:KEY_SECTOKEN];
            
            return YES;
        }else{
            [self notificationErrorCode:nil];
        }
        
    }
    
    return NO;
}
-(BOOL)createUser:(UserType *)userType{
    [self syslogin:@"root" password:@"root"];
    NSString *userID=[[NSUserDefaults standardUserDefaults] objectForKey:KEY_USERID];
    NSString *secToken=[[NSUserDefaults standardUserDefaults] objectForKey:KEY_SECTOKEN];
    
    NSMutableString *appendStr=[[NSMutableString alloc] init];
    
    if(userType.realName!=nil){
        [appendStr appendFormat:[NSString stringWithFormat:@"&realName=%@",userType.realName]];
    
    }
    if(userType.email!=nil){
        [appendStr appendFormat:[NSString stringWithFormat:@"&email=%@",userType.email]];
        
        
    }
    if(userType.phone!=nil){
        [appendStr appendFormat:[NSString stringWithFormat:@"&phone=%@",userType.phone]];
        
    }
    if(userType.userRole!=nil){
        [appendStr appendFormat:[NSString stringWithFormat:@"&userRole=%@",userType.userRole]];
        
    }
    if(userType.cardId!=nil){
        [appendStr appendFormat:[NSString stringWithFormat:@"&cardId=%@",userType.cardId]];
        
    }
    
    
    
    NSString *service=[NSString stringWithFormat:@"%@createUser?senderId=%@&secToken=%@&name=%@&password=%@%@",self.authapiUrl,userID,secToken,userType.name,[WsqMD5Util getmd5WithString:userType.password],appendStr];
    
    
    NSLog(@"createUser service:%@",service);
    NSData *data=[self requestURLSync:service];
    if(data!=nil){
        GDataXMLElement *rootElement=[self getRootElementByData:data];
        
        NSString* errorCodeVal=[[[rootElement elementsForName:@"errorCode"] objectAtIndex:0] stringValue];
        
        NSString* errorMsgVal=[[[rootElement elementsForName:@"errorMsg"] objectAtIndex:0] stringValue];
       
        if([errorCodeVal isEqualToString:@"0"]){
            return YES;
        }else{
            [self notificationErrorCode:errorMsgVal];
        }
        
    }
    return NO;
}

-(UserType *)getUser{
    NSString *userID=[[NSUserDefaults standardUserDefaults] objectForKey:KEY_USERID];
    NSString *secToken=[[NSUserDefaults standardUserDefaults] objectForKey:KEY_SECTOKEN];
    NSString *service=[NSString stringWithFormat:@"%@getUser?senderId=%@&secToken=%@&userId=%@",self.authapiUrl,userID,secToken,userID];
    
    
    NSLog(@"getUser service:%@",service);
    NSData *data=[self requestURLSync:service];
    if(data!=nil){
        GDataXMLElement *rootElement=[self getRootElementByData:data];
        
        NSString* errorCodeVal=[[[rootElement elementsForName:@"errorCode"] objectAtIndex:0] stringValue];
        NSString* errorMsgVal=[[[rootElement elementsForName:@"errorMsg"] objectAtIndex:0] stringValue];
        NSLog(@"errorCode:%@, errorMsg:%@",errorCodeVal,errorMsgVal);
        if([errorCodeVal isEqualToString:@"0"]){
            NSArray *userNodes=[rootElement elementsForName:@"user"];
             UserType *userType=[[UserType alloc] init];
            for (GDataXMLElement *element in userNodes) {
               
                userType.userId=[[[[element elementsForName:@"userId"] objectAtIndex:0] stringValue] intValue];
                userType.name=[[[element elementsForName:@"name"] objectAtIndex:0] stringValue];
                userType.password=[[[element elementsForName:@"password"] objectAtIndex:0] stringValue];
                userType.realName=[[[element elementsForName:@"realName"] objectAtIndex:0] stringValue];
                userType.phone=[[[element elementsForName:@"phone"] objectAtIndex:0] stringValue];
                userType.email=[[[element elementsForName:@"email"] objectAtIndex:0] stringValue];
                userType.lastSecToken=[[[element elementsForName:@"lastSecToken"] objectAtIndex:0]stringValue];
                userType.lastLoginTime=[[[element elementsForName:@"lastLoginTime"] objectAtIndex:0] stringValue];
                                        
                 userType.cardId=[[[element elementsForName:@"cardId"] objectAtIndex:0] stringValue];
                                        
                
                break;
                
            }
            return userType;
            
            
        }else{
            [self notificationErrorCode:errorMsgVal];
        }
        
    }
    return nil;
}

/***********************************
 * webService API begin...
 
 openlab 接口
 ***********************************
 */

-(NSArray *)getLabListByIncDesk:(BOOL)incDesk{
    NSString *userID=[[NSUserDefaults standardUserDefaults] objectForKey:KEY_USERID];
    NSString *secToken=[[NSUserDefaults standardUserDefaults] objectForKey:KEY_SECTOKEN];
    NSString *service=[NSString stringWithFormat:@"%@getLabListByIncDesk?senderId=%@&secToken=%@&incDesk=%d",self.openlabUrl,userID,secToken,incDesk];
    
    
    NSLog(@"getLabListByIncDesk service:%@",service);
    NSData *data=[self requestURLSync:service];
    if(data!=nil){
        GDataXMLElement *rootElement=[self getRootElementByData:data];
        
        NSString* errorCodeVal=[[[rootElement elementsForName:@"errorCode"] objectAtIndex:0] stringValue];
        NSString* errorMsgVal=[[[rootElement elementsForName:@"errorMsg"] objectAtIndex:0] stringValue];
        NSLog(@"errorCode:%@, errorMsg:%@",errorCodeVal,errorMsgVal);
        if([errorCodeVal isEqualToString:@"0"]){
            NSArray *lablistNodes=[rootElement elementsForName:@"lablist"];
            
            NSMutableArray *lablist=[[NSMutableArray alloc] init];
            
            for (GDataXMLElement *element in lablistNodes) {
                
                LabInfoType *labInfoType=(LabInfoType *) [self parseLabInfoTypeXML:element];
                
                [lablist addObject:labInfoType];
                
            }
            return lablist;
            
        }
    }
    return nil;
}

-(BOOL)AddOrUpdAssignment:(int)asId courseCode:(NSString *)arg0 desc:(NSString *)arg1 dueDate:(NSString *)arg2{
    NSString *userID=[[NSUserDefaults standardUserDefaults] objectForKey:KEY_USERID];
    NSString *secToken=[[NSUserDefaults standardUserDefaults] objectForKey:KEY_SECTOKEN];
    NSMutableString *appendStr=[[NSMutableString alloc] init];
    
    if(arg2!=nil){
        [appendStr appendFormat:[NSString stringWithFormat:@"&dueDate=%@",arg2]];
        
    }
    
    NSString *service=[NSString stringWithFormat:@"%@AddOrUpdAssignment?senderId=%@&secToken=%@&asId=%d&courseCode=%@&desc=%@%@",self.openlabUrl,userID,secToken,asId,arg0,arg1,appendStr];
    
    NSLog(@"AddOrUpdAssignment service:%@",service);
    NSData *data=[self requestURLSync:service];
    if(data!=nil){
        GDataXMLElement *rootElement=[self getRootElementByData:data];
        
        NSString* errorCodeVal=[[[rootElement elementsForName:@"errorCode"] objectAtIndex:0] stringValue];
        NSString* errorMsgVal=[[[rootElement elementsForName:@"errorMsg"] objectAtIndex:0] stringValue];
        NSLog(@"errorCode:%@, errorMsg:%@",errorCodeVal,errorMsgVal);
        if([errorCodeVal isEqualToString:@"0"]){
            return YES;
        }else{
            [self notificationErrorCode:errorMsgVal];
        }
    }
    return NO;
    
    
}

-(BOOL)submitReport:(NSString *)courseCode file:(NSString *)arg0 desc:(NSString *)arg1 assignmentId:(int)arg2{
    NSString *userID=[[NSUserDefaults standardUserDefaults] objectForKey:KEY_USERID];
    NSString *secToken=[[NSUserDefaults standardUserDefaults] objectForKey:KEY_SECTOKEN];
    NSMutableString *appendStr=[[NSMutableString alloc] init];
    
    if(arg1!=nil){
        [appendStr appendFormat:[NSString stringWithFormat:@"&desc=%@",arg1]];
        
    }
    if(arg2>0){
        [appendStr appendFormat:[NSString stringWithFormat:@"&assignmentId=%d",arg2]];
        
    }
    
    NSString *service=[NSString stringWithFormat:@"%@submitReport?senderId=%@&secToken=%@&courseCode=%@&file=%@%@",self.openlabUrl,userID,secToken,courseCode,arg0,appendStr];
    
    NSLog(@"submitReport service:%@",service);
    NSData *data=[self requestURLSync:service];
    if(data!=nil){
        GDataXMLElement *rootElement=[self getRootElementByData:data];
        
        NSString* errorCodeVal=[[[rootElement elementsForName:@"errorCode"] objectAtIndex:0] stringValue];
        NSString* errorMsgVal=[[[rootElement elementsForName:@"errorMsg"] objectAtIndex:0] stringValue];
        NSLog(@"errorCode:%@, errorMsg:%@",errorCodeVal,errorMsgVal);
        if([errorCodeVal isEqualToString:@"0"]){
            return YES;
        }else{
            [self notificationErrorCode:errorMsgVal];
        }
    }
    return NO;
    
    
}

-(NSArray *)getReservationList:(NSString *)name{
    NSString *userID=[[NSUserDefaults standardUserDefaults] objectForKey:KEY_USERID];
    NSString *secToken=[[NSUserDefaults standardUserDefaults] objectForKey:KEY_SECTOKEN];
    NSString *service=[NSString stringWithFormat:@"%@getReservationList?senderId=%@&secToken=%@&name=%@",self.openlabUrl,userID,secToken,name];
    NSLog(@"getReservationList service:%@",service);
    NSData *data=[self requestURLSync:service];
    if(data!=nil){
        GDataXMLElement *rootElement=[self getRootElementByData:data];
        
        NSString* errorCodeVal=[[[rootElement elementsForName:@"errorCode"] objectAtIndex:0] stringValue];
        NSString* errorMsgVal=[[[rootElement elementsForName:@"errorMsg"] objectAtIndex:0] stringValue];
        NSLog(@"errorCode:%@, errorMsg:%@",errorCodeVal,errorMsgVal);
        if([errorCodeVal isEqualToString:@"0"]){
            NSArray *reservationNodes=[rootElement elementsForName:@"reservation"];
            
            NSMutableArray *reservationList=[[NSMutableArray alloc] init];
            
            for (GDataXMLElement *element in reservationNodes) {
                
                ReservationType *reservationType=(ReservationType *) [self parseReservationTypeXML:element];
                
                [reservationList addObject:reservationType];
                
            }
            return reservationList;
            
            
        }else{
            [self notificationErrorCode:errorMsgVal];
        }
    }
    
    return nil;
    
}

-(NSArray *)getAssignmentList:(NSString *)courseCode{
    NSString *userID=[[NSUserDefaults standardUserDefaults] objectForKey:KEY_USERID];
    NSString *secToken=[[NSUserDefaults standardUserDefaults] objectForKey:KEY_SECTOKEN];
    
    NSMutableString *appendStr=[[NSMutableString alloc] init];
    
    if(courseCode!=nil){
        [appendStr appendFormat:[NSString stringWithFormat:@"&courseCode=%@",courseCode]];
        
    }
    
    NSString *service=[NSString stringWithFormat:@"%@getAssignmentList?senderId=%@&secToken=%@&userId=%@%@",self.openlabUrl,userID,secToken,userID,appendStr];
    
    NSLog(@"getAssignmentList service:%@",service);
    NSData *data=[self requestURLSync:service];
    if(data!=nil){
        GDataXMLElement *rootElement=[self getRootElementByData:data];
        
        NSString* errorCodeVal=[[[rootElement elementsForName:@"errorCode"] objectAtIndex:0] stringValue];
        NSString* errorMsgVal=[[[rootElement elementsForName:@"errorMsg"] objectAtIndex:0] stringValue];
        NSLog(@"errorCode:%@, errorMsg:%@",errorCodeVal,errorMsgVal);
        if([errorCodeVal isEqualToString:@"0"]){
            NSArray *assignmentListNodes=[rootElement elementsForName:@"assignmentList"];
            
            NSMutableArray *assignmentList=[[NSMutableArray alloc] init];
            
            for (GDataXMLElement *element in assignmentListNodes) {
                
                AssignmentType *assignmentType=(AssignmentType *) [self parseAssignmentTypeXML:element];
                
                [assignmentList addObject:assignmentType];
                
            }
            return assignmentList;
            
            
        }else{
            [self notificationErrorCode:errorMsgVal];
        }
    }

    
    
    return nil;
}


-(BOOL)addOrUpdReservation:(NSString *)userName startTime:(NSString *)arg0 endTime:(NSString *)arg1 deskNum:(int)arg2 labId:(int)arg3 status:(int)arg4 resvId:(int)arg5{
    NSString *userID=[[NSUserDefaults standardUserDefaults] objectForKey:KEY_USERID];
    NSString *secToken=[[NSUserDefaults standardUserDefaults] objectForKey:KEY_SECTOKEN];
    
    
    NSString *service=[NSString stringWithFormat:@"%@addOrUpdReservation?senderId=%@&secToken=%@&userId=%@&userName=%@&startTime=%@&endTime=%@&deskNum=%d&labId=%d&status=%d&resvId=%d",self.openlabUrl,userID,secToken,userID,userName,arg0,arg1,arg2,arg3,arg4,arg5];
    
    NSLog(@"addOrUpdReservation service:%@",service);
    NSData *data=[self requestURLSync:service];
    if(data!=nil){
        GDataXMLElement *rootElement=[self getRootElementByData:data];
        
        NSString* errorCodeVal=[[[rootElement elementsForName:@"errorCode"] objectAtIndex:0] stringValue];
        NSString* errorMsgVal=[[[rootElement elementsForName:@"errorMsg"] objectAtIndex:0] stringValue];
        NSLog(@"errorCode:%@, errorMsg:%@",errorCodeVal,errorMsgVal);
        if([errorCodeVal isEqualToString:@"0"]){
            return YES;
        }else{
            [self notificationErrorCode:errorMsgVal];
        }
    }

    return NO;
    
    
    
}


/*
 ***********************************************************
 *  end ...
 ***********************************************************
 */

-(AssignmentType *)parseAssignmentTypeXML:(GDataXMLElement *)element{
    AssignmentType *assignmentType=[[AssignmentType alloc] init];
    assignmentType.asId=[[[[element elementsForName:@"id"] objectAtIndex:0] stringValue] intValue];
    assignmentType.createdBy=[[[[element elementsForName:@"createdBy"] objectAtIndex:0] stringValue] intValue];
    
    assignmentType.courseCode=[[[element elementsForName:@"courseCode"] objectAtIndex:0] stringValue];
    assignmentType.desc=[[[element elementsForName:@"desc"] objectAtIndex:0] stringValue];
    assignmentType.dueDate=[[[element elementsForName:@"dueDate"] objectAtIndex:0] stringValue];
    assignmentType.createdTime=[[[element elementsForName:@"createdTime"] objectAtIndex:0] stringValue];
    
    return assignmentType;
}

-(ReservationType *)parseReservationTypeXML:(GDataXMLElement *)element{
    ReservationType *reservationType=[[ReservationType alloc] init];
    reservationType.labId=[[[[element elementsForName:@"labId"] objectAtIndex:0] stringValue] intValue];
    reservationType.deskNum=[[[[element elementsForName:@"deskNum"] objectAtIndex:0] stringValue] intValue];
    reservationType.resvId=[[[[element elementsForName:@"resvId"] objectAtIndex:0] stringValue] intValue];
    reservationType.status=[[[[element elementsForName:@"status"] objectAtIndex:0] stringValue] intValue];
    
    reservationType.startTime=[[[element elementsForName:@"startTime"] objectAtIndex:0] stringValue];
    reservationType.endTime=[[[element elementsForName:@"endTime"] objectAtIndex:0] stringValue];
    reservationType.cancelTime=[[[element elementsForName:@"cancelTime"] objectAtIndex:0] stringValue];
    reservationType.userName=[[[element elementsForName:@"userName"] objectAtIndex:0] stringValue];
    
    return reservationType;

}

-(LabInfoType *)parseLabInfoTypeXML:(GDataXMLElement *)element{
    LabInfoType *labInfoType=[[LabInfoType alloc] init];
    labInfoType.labId=[[[[element elementsForName:@"labId"] objectAtIndex:0] stringValue] intValue];
    labInfoType.name=[[[element elementsForName:@"name"] objectAtIndex:0] stringValue];
    labInfoType.desc=[[[element elementsForName:@"desc"] objectAtIndex:0] stringValue];
    labInfoType.numOfDesk=[[[[element elementsForName:@"numOfDesk"] objectAtIndex:0] stringValue] intValue];
    labInfoType.building=[[[element elementsForName:@"building"] objectAtIndex:0] stringValue];
    labInfoType.floor=[[[[element elementsForName:@"floor"] objectAtIndex:0] stringValue] intValue];
    labInfoType.room=[[[[element elementsForName:@"room"] objectAtIndex:0] stringValue] intValue];
    
    NSArray *deskInfoNodes= [element elementsForName:@"DeskInfo"] ;
    NSMutableArray *deskInfos=[[NSMutableArray alloc] init];
    
    if(deskInfoNodes!=nil&&[deskInfoNodes count]>0){
        for (GDataXMLElement *element in deskInfoNodes) {
            
            DeskInfo *deskInfo=[[DeskInfo alloc] init];
            
            deskInfo.labId=[[[[element elementsForName:@"labId"] objectAtIndex:0] stringValue] intValue];
            deskInfo.deskNum=[[[[element elementsForName:@"deskNum"] objectAtIndex:0] stringValue] intValue];
            deskInfo.type=[[[[element elementsForName:@"type"] objectAtIndex:0] stringValue] intValue];
            deskInfo.desc=[[[element elementsForName:@"desc"] objectAtIndex:0] stringValue];
            
            [deskInfos addObject:deskInfo];
            
            
        }
        [labInfoType setDeskInfos:deskInfos];
    }
    
    
    return labInfoType;
}

#pragma private

-(void)notificationErrorCode:(NSString *)errorCode{
    return ;
}
-(GDataXMLElement *)getRootElementByData:(NSData *)data{
    GDataXMLDocument *doc=[[GDataXMLDocument alloc] initWithData:data options:0 error:nil];
    GDataXMLElement *rootElement=[doc rootElement];
    return [rootElement copy];
}

-(NSData *)requestURLSync:(NSString *)service{
    NSURL* url=[NSURL URLWithString:service];
    NSMutableURLRequest* request=[NSMutableURLRequest requestWithURL:url];
    [request setTimeoutInterval:12];
    [request setHTTPMethod:@"GET"];
    NSURLResponse* response=nil;
    NSError* error=nil;
    NSData * data=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if(data!=nil){
        return data;
    }else{
        NSString *errorDescription=nil;
        errorDescription=error.localizedDescription;
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self notificationErrorCode:errorDescription];
            
        });
    }
    return nil;
}





#pragma nouse
-(NSData *)requestURL:(NSString *)service{
    NSURL* url=[NSURL URLWithString:service];
    NSMutableURLRequest* request=[NSMutableURLRequest requestWithURL:url];
    [request setTimeoutInterval:DEFAULT_TIME_OUT];
    [request setHTTPMethod:@"GET"];
    NSOperationQueue* queue=[[NSOperationQueue alloc] init];
     [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
         NSLog(@"asyn RESPONSE :%@  NSDATA :%@  NSERROR:%@",response,[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding],connectionError);
     }];
    return nil;
}

+(id)allocWithZone:(struct _NSZone *)zone{
    @synchronized(self){
        if(shareService==nil){
            shareService=[super allocWithZone:zone];
            return shareService;
        }
    }
    return nil;
}
-(id)copyWithZone:(NSZone *)zone{
    return self;
}

- (instancetype)init
{
    @synchronized(self){
        self=[super init];
        return self;
    }
    
}

@end
