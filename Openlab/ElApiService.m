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
#import "TimeUtils.h"
const static int DEFAULT_TIME_OUT=11;
const static NSString* WEBSERVICE_IP=@"202.38.78.70";//202.38.78.70
const static int WEBSERVICE_PORT=8080;
const NSString* KEY_USERID=@"userID_KEY";
const NSString* KEY_SECTOKEN=@"sectoken_KEY";

@interface ElApiService()
#pragma mark errorCode handler
@property(nonatomic,strong,readwrite) ErrorCodeHandlerBlock block;
@property(nonatomic,strong) NSDictionary *errorCodeDictionary;

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
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [shareService readErrorCodePlistFile];
            });
        }
        return shareService;
    }
    
}
-(NSString *)getWebImageURL:(NSString *)imageName{
    return [NSString stringWithFormat:@"http://%@/openlabweb/upload/%@",WEBSERVICE_IP,imageName];
}
-(void)setIWSErrorCodeListenerBlock:(ErrorCodeHandlerBlock)block{
    self.block=block;
}
- (NSString*)urlEncodedString:(NSString *)string
{
    NSString * encodedString = (__bridge_transfer  NSString*) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)string, NULL, (__bridge CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8 );
    
    return encodedString;
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
            [self notificationErrorCode:errorCodeVal];
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
            [self notificationErrorCode:errorCodeVal];
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
        [appendStr appendFormat:@"&realName=%@",userType.realName];
    
    }
    if(userType.email!=nil){
        [appendStr appendFormat:@"&email=%@",userType.email];
        
        
    }
    if(userType.phone!=nil){
        [appendStr appendFormat:@"&phone=%@",userType.phone];
        
    }
    if(userType.userRole!=nil){
        [appendStr appendFormat:@"&userRole=%@",userType.userRole];
        
    }
    if(userType.cardId!=nil){
        [appendStr appendFormat:@"&cardId=%@",userType.cardId];
        
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
            [self notificationErrorCode:errorCodeVal];
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
            [self notificationErrorCode:errorCodeVal];
        }
        
    }
    return nil;
}

/***********************************
 * webService API begin...
 
 openlab 接口
 ***********************************
 */

-(NSArray *)getLabCourseList{
    NSString *userID=[[NSUserDefaults standardUserDefaults] objectForKey:KEY_USERID];
    NSString *secToken=[[NSUserDefaults standardUserDefaults] objectForKey:KEY_SECTOKEN];
    NSString *service=[NSString stringWithFormat:@"%@getLabCourseList?senderId=%@&secToken=%@&year=1&semester=1",self.openlabUrl,userID,secToken];
    
    
    NSLog(@"getLabCourseList service:%@",service);
    NSData *data=[self requestURLSync:service];
    if(data!=nil){
        GDataXMLElement *rootElement=[self getRootElementByData:data];
        
        NSString* errorCodeVal=[[[rootElement elementsForName:@"errorCode"] objectAtIndex:0] stringValue];
       
        if([errorCodeVal isEqualToString:@"0"]){
            NSArray *courselistNodes=[rootElement elementsForName:@"courselist"];
            NSMutableArray *courseTypeList=[NSMutableArray new];
            for (GDataXMLElement *element in courselistNodes) {
                
                CourseType *courseType=(CourseType *) [self parseCourseTypeXML:element];
                
                [courseTypeList addObject:courseType];
                
            }
            return courseTypeList;

            
        }
        
    }
    

    
    
    return nil;
}


-(NSArray *)getLabListByIncDesk:(BOOL)incDesk{
    NSString *userID=[[NSUserDefaults standardUserDefaults] objectForKey:KEY_USERID];
    NSString *secToken=[[NSUserDefaults standardUserDefaults] objectForKey:KEY_SECTOKEN];
    NSString *service=[NSString stringWithFormat:@"%@getLabList?senderId=%@&secToken=%@&incDesk=%d",self.openlabUrl,userID,secToken,incDesk];
    
    
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
            
        }else{
            [self notificationErrorCode:errorCodeVal];
        }
    }
    return nil;
}

-(BOOL)AddOrUpdAssignment:(int)asId courseCode:(NSString *)arg0 desc:(NSString *)arg1 dueDate:(NSString *)arg2{
    NSString *userID=[[NSUserDefaults standardUserDefaults] objectForKey:KEY_USERID];
    NSString *secToken=[[NSUserDefaults standardUserDefaults] objectForKey:KEY_SECTOKEN];
    NSMutableString *appendStr=[[NSMutableString alloc] init];
    
    if(arg2!=nil){
        [appendStr appendFormat:@"&dueDate=%@",arg2];
        
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
            [self notificationErrorCode:errorCodeVal];
        }
    }
    return NO;
    
    
}

-(BOOL)submitReport:(NSString *)courseCode file:(NSString *)arg0 desc:(NSString *)arg1 assignmentId:(int)arg2{
    NSString *userID=[[NSUserDefaults standardUserDefaults] objectForKey:KEY_USERID];
    NSString *secToken=[[NSUserDefaults standardUserDefaults] objectForKey:KEY_SECTOKEN];
    NSMutableString *appendStr=[[NSMutableString alloc] init];
    
    if(arg1!=nil){
        [appendStr appendFormat:@"&desc=%@",arg1];
        
    }
    if(arg2>0){
        [appendStr appendFormat:@"&assignmentId=%d",arg2];
        
    }
    
    NSString *service=[NSString stringWithFormat:@"%@submitReport",self.openlabUrl];
    
    NSLog(@"submitReport service:%@",service);
    NSMutableData *postBody=[[NSMutableData alloc] init];
    NSString *param=[NSString stringWithFormat:@"senderId=%@&secToken=%@&courseCode=%@&file=%@%@",userID,secToken,courseCode,arg0,appendStr] ;
    
    
    [postBody appendData:[param dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    
    NSData *data=[self requestURLSyncPOST:service postBody:postBody];
    
    if(data!=nil){
        GDataXMLElement *rootElement=[self getRootElementByData:data];
        
        NSString* errorCodeVal=[[[rootElement elementsForName:@"errorCode"] objectAtIndex:0] stringValue];
        NSString* errorMsgVal=[[[rootElement elementsForName:@"errorMsg"] objectAtIndex:0] stringValue];
        NSLog(@"errorCode:%@, errorMsg:%@",errorCodeVal,errorMsgVal);
        if([errorCodeVal isEqualToString:@"0"]){
            return YES;
        }else{
            [self notificationErrorCode:errorCodeVal];
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
            [self notificationErrorCode:errorCodeVal];
        }
    }
    
    return nil;
    
}

-(Turple *)getAssignmentList:(NSString *)courseCode{
    NSString *userID=[[NSUserDefaults standardUserDefaults] objectForKey:KEY_USERID];
    NSString *secToken=[[NSUserDefaults standardUserDefaults] objectForKey:KEY_SECTOKEN];
    
    NSMutableString *appendStr=[[NSMutableString alloc] init];
    Turple *turple=[[Turple alloc] init];
    
    
    if(courseCode!=nil){
        [appendStr appendFormat:@"&courseCode=%@",courseCode];
        
    }
    
    NSString *service=[NSString stringWithFormat:@"%@getAassignmentList?senderId=%@&secToken=%@&userId=%@%@",self.openlabUrl,userID,secToken,userID,appendStr];
    
    NSLog(@"getAssignmentList service:%@",service);
    NSData *data=[self requestURLSync:service];
    if(data!=nil){
        GDataXMLElement *rootElement=[self getRootElementByData:data];
        
        NSString* errorCodeVal=[[[rootElement elementsForName:@"errorCode"] objectAtIndex:0] stringValue];
        NSString* errorMsgVal=[[[rootElement elementsForName:@"errorMsg"] objectAtIndex:0] stringValue];
        NSLog(@"errorCode:%@, errorMsg:%@",errorCodeVal,errorMsgVal);
        if([errorCodeVal isEqualToString:@"0"]){
            NSArray *assignmentListNodes=[rootElement elementsForName:@"assignmentList"];
            
            NSArray *reportListNodes=[rootElement elementsForName:@"reportList"];
            
            NSMutableArray *assignmentList=[[NSMutableArray alloc] init];
            NSMutableArray *reportList=[[NSMutableArray alloc] init];
            
            for (GDataXMLElement *element in assignmentListNodes) {
                
                AssignmentType *assignmentType=(AssignmentType *) [self parseAssignmentTypeXML:element];
                
                [assignmentList addObject:assignmentType];
                
            }
            
            for (GDataXMLElement *element in reportListNodes) {
                
                ReportInfo *reportInfo=(ReportInfo *) [self parseReportInfoXML:element];
                
                [reportList addObject:reportInfo];
                
            }
            
            turple.assignmentTypes=assignmentList;
            turple.reportInfos=reportList;
            
            return turple;
        }else{
            [self notificationErrorCode:errorCodeVal];
        }
    }

    
    
    return nil;
}


-(BOOL)addOrUpdReservation:(NSString *)userName startTime:(NSString *)arg0 endTime:(NSString *)arg1 deskNum:(int)arg2 labId:(int)arg3 status:(int)arg4 resvId:(int)arg5{
    NSString *userID=[[NSUserDefaults standardUserDefaults] objectForKey:KEY_USERID];
    NSString *secToken=[[NSUserDefaults standardUserDefaults] objectForKey:KEY_SECTOKEN];
    
    
    NSString *service=[NSString stringWithFormat:@"%@addOrUpdReservation?senderId=%@&secToken=%@&userId=%@&userName=%@&startTime=%@&endTime=%@&deskNum=%d&labId=%d&status=%d&resvId=%d",self.openlabUrl,userID,secToken,userID,userName,[arg0 stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[arg1 stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],arg2,arg3,arg4,arg5];
    
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
            [self notificationErrorCode:errorCodeVal];
        }
    }

    return NO;
    
    
    
}


/*
 ***********************************************************
 *  end ...
 ***********************************************************
 */
-(ReportInfo *)parseReportInfoXML:(GDataXMLElement *)element{
    ReportInfo *reportInfo=[[ReportInfo alloc] init];
    reportInfo.reportId=[[[[element elementsForName:@"reportId"] objectAtIndex:0] stringValue] intValue];
    reportInfo.userId=[[[[element elementsForName:@"userId"] objectAtIndex:0] stringValue] intValue];
    reportInfo.assignmentId=[[[[element elementsForName:@"assignmentId"] objectAtIndex:0] stringValue] intValue];
    reportInfo.courseCode=[[[element elementsForName:@"courseCode"] objectAtIndex:0] stringValue];
    reportInfo.desc=[[[element elementsForName:@"description"] objectAtIndex:0] stringValue];
    reportInfo.fileName=[[[element elementsForName:@"attachFileName"] objectAtIndex:0] stringValue];
    reportInfo.submitTime=[[[element elementsForName:@"submitTime"] objectAtIndex:0] stringValue];
    
    return reportInfo;
}

-(AssignmentType *)parseAssignmentTypeXML:(GDataXMLElement *)element{
    AssignmentType *assignmentType=[[AssignmentType alloc] init];
    assignmentType.asId=[[[[element elementsForName:@"id"] objectAtIndex:0] stringValue] intValue];
    assignmentType.createdBy=[[[[element elementsForName:@"createdBy"] objectAtIndex:0] stringValue] intValue];
    
    assignmentType.courseCode=[[[element elementsForName:@"courseCode"] objectAtIndex:0] stringValue];
    assignmentType.desc=[[[element elementsForName:@"desc"] objectAtIndex:0] stringValue];
    assignmentType.dueDate=[[[element elementsForName:@"dueDate"] objectAtIndex:0] stringValue];
    assignmentType.dueDate=[TimeUtils formatData:assignmentType.dueDate from:@"yyyy-MM-dd+HH:mm" to:@"yyyy-MM-dd HH:mm"];
    
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
-(CourseType *)parseCourseTypeXML:(GDataXMLElement *)element{
    CourseType *courseType=[[CourseType alloc] init];
    courseType.courseCode=[[[element elementsForName:@"courseCode"] objectAtIndex:0] stringValue];
    courseType.name=[[[element elementsForName:@"name"] objectAtIndex:0] stringValue];
    courseType.desc=[[[element elementsForName:@"desc"] objectAtIndex:0] stringValue];
    courseType.year=[[[[element elementsForName:@"year"] objectAtIndex:0] stringValue] intValue];
    courseType.semester=[[[[element elementsForName:@"semester"] objectAtIndex:0] stringValue] intValue];
    
    return courseType;

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
-(void)readErrorCodePlistFile{
    NSDictionary *errCodeDictionary=[[NSDictionary alloc] initWithContentsOfFile:[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"errorCodePlist.plist"]];
    
    self.errorCodeDictionary=errCodeDictionary;
}
-(void)notificationErrorCode:(NSString *)errorCode{
    if([NSThread isMainThread]){
        _block(errorCode,[self.errorCodeDictionary objectForKey:errorCode]);
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            _block(errorCode,[self.errorCodeDictionary objectForKey:errorCode]);
        });
    }
    return ;
}
-(GDataXMLElement *)getRootElementByData:(NSData *)data{
    GDataXMLDocument *doc=[[GDataXMLDocument alloc] initWithData:data options:0 error:nil];
    GDataXMLElement *rootElement=[doc rootElement];
    return [rootElement copy];
}

-(NSData *)requestURLSyncPOST:(NSString *)service postBody:(NSData *)postBody{
    NSURL* url=[NSURL URLWithString:service];
    NSMutableURLRequest* request=[NSMutableURLRequest requestWithURL:url];
    [request setTimeoutInterval:12];
    [request setHTTPMethod:@"POST"];
    
    [request setHTTPBody:postBody];
    
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
             NSLog(@"errorDescription %@",errorDescription);
            [self notificationErrorCode:@"9999"];
            
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
