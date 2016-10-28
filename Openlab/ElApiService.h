//
//  ElApiService.h
//  ehome
//
//  Created by admin on 14-7-21.
//  Copyright (c) 2014年 cn.lztech  合肥联正电子科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MyObjectDataBean.h"

typedef void (^ErrorCodeHandlerBlock)(NSString *errorCode ,NSString *errorMsg);

extern const NSString* KEY_USERID;

@class ElApiService;
static ElApiService* shareService=nil;
@interface ElApiService : NSObject{
    
}
@property(nonatomic,retain) NSString* openlabUrl;
@property(nonatomic,retain) NSString* authapiUrl;

+(ElApiService *) shareElApiService;


-(NSData *)requestURLSync:(NSString *)service;


-(NSString *)getWebImageURL:(NSString *)imageName;

-(void)setIWSErrorCodeListenerBlock:(ErrorCodeHandlerBlock)block;

-(BOOL)login:(NSString *)name password:(NSString *)pass;
-(BOOL)logout;
-(BOOL)createUser:(UserType *)userType;
-(UserType *)getUser;

-(BOOL)verificationCode:(NSString *)key code:(NSString *)code;
-(BOOL)sendShortMsgCode:(NSString *)key type:(int)type;
-(BOOL)updateUser:(NSString *)loginName phone:(NSString *)phone pass:(NSString *)pwd vcode:(NSString *)vcode;


/*
 ** openlab api
 **
 */
-(NSArray *)getSemesterList;
-(NSArray *)getLabCourseList:(NSString *)currerYear semester:(int)seme;
-(NSArray *)getLabListByIncDesk:(BOOL)incDesk;
-(BOOL)AddOrUpdAssignment:(int)asId courseCode:(NSString *)arg0 desc:(NSString *)arg1 dueDate:(NSString *)arg2;
-(BOOL)submitReport:(NSString *)courseCode file:(NSString *)arg0 desc:(NSString *)arg1 assignmentId:(int)arg2;
-(ScoreType *)getStudentScoreList:(NSString *)courseCode;

-(NSArray *)getReservationList:(NSString *)name;
-(Turple *)getAssignmentList:(NSString *)courseCode;
-(BOOL)addOrUpdReservation:(NSString *)userName startTime:(NSString *)arg0 endTime:(NSString *)arg1 deskNum:(int)arg2 labId:(int)arg3 status:(int)arg4 resvId:(int)arg5;




@end

