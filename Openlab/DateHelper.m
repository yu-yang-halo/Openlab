//
//  DateHelper.m
//  KMDatePicker
//
//  Created by KenmuHuang on 15/10/8.
//  Copyright © 2015年 Kenmu. All rights reserved.
//

#import "DateHelper.h"

@implementation DateHelper

+ (NSDate *)localeDate {
    NSDate *date = [NSDate date];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate:date];
    return [date dateByAddingTimeInterval:interval];
}
+ (NSDate *)defaultDate {
    NSDate *date = [NSDate date];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate:date];
    date=[date dateByAddingTimeInterval:interval];
    
    NSCalendar *greCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateComponentsForDate = [greCalendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSWeekCalendarUnit | NSWeekdayCalendarUnit | NSWeekOfMonthCalendarUnit | NSWeekOfYearCalendarUnit fromDate:date];
    if(dateComponentsForDate.minute>=30){
        [dateComponentsForDate setMinute:0];
        [dateComponentsForDate setHour:dateComponentsForDate.hour+1];
    }else{
        [dateComponentsForDate setMinute:30];
    }
    
    date = [greCalendar dateFromComponents:dateComponentsForDate];
    
    
    return date;
    
}

+ (NSDate *)dateFromString:(NSString *)dateStr withFormat:(NSString *)format {
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    formatter.dateFormat = format ?: @"yyyy-MM-dd HH:mm";
    return [formatter dateFromString:dateStr];
}

+ (NSString *)dateToString:(NSDate *)date withFormat:(NSString *)format {
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    formatter.dateFormat = format ?: @"yyyy-MM-dd HH:mm";
    return [formatter stringFromDate:date];
}

+(NSInteger)currentMonth:(NSDate *)date{
    NSCalendar *greCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateComponentsForDate = [greCalendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSWeekCalendarUnit | NSWeekdayCalendarUnit | NSWeekOfMonthCalendarUnit | NSWeekOfYearCalendarUnit fromDate:date];
    
    
    return dateComponentsForDate.month;
    
}

@end
