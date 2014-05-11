//
//  Status.m
//  WeiboDemo
//
//  Created by Lx JeOam on 14-5-7.
//  Copyright (c) 2014年 JeOam. All rights reserved.
//

#import "Status.h"

@implementation Status

- (Status *)initWithJSONDictionary:(NSDictionary *)dic{
    if (self = [super init]) {
        
        // 基本信息
        self.statusID = [[dic objectForKey:@"id"] longLongValue];
        self.text = [dic objectForKey:@"text"];
        self.favorited = (BOOL)[dic objectForKey:@"favorited"];
        
        // 微博图像
        self.thumbnailPic = [dic objectForKey:@"thumbnail_pic"];
        self.bMiddlePic = [dic objectForKey:@"bmiddle_pic"];
        self.originalPic = [dic objectForKey:@"original_pic"];
        
        self.commentsCount = [[dic objectForKey:@"comments_count"] integerValue];
        self.repostsCount = [[dic objectForKey:@"reposts_count"] integerValue];
        
        // 微博作者信息
        NSDictionary *userDic = [dic objectForKey:@"user"];
        if (userDic) {
            self.screenName = [userDic objectForKey:@"screen_name"];
            self.profileImageURL = [userDic objectForKey:@"profile_image_url"];
        }
        
        // 被转发的原微博信息字段
        NSDictionary *retweetedStatusDic = [dic objectForKey:@"retweeted_status"];
        
        if (retweetedStatusDic) {
            
            self.retweetedStatus = [Status statusWithJSONDictionary:retweetedStatusDic];
            if (self.retweetedStatus.thumbnailPic) {
                NSString *forwardedPicURL = self.retweetedStatus.thumbnailPic;
                self.hasForwardedPic = (forwardedPicURL != nil && [forwardedPicURL length] != 0 ? YES : NO);
            }
            
        } else {
            NSString *picURL= self.thumbnailPic;
            self.hasPic = (picURL != nil && [picURL length] != 0 ? YES : NO);
            
        }
        
        // 处理微博信息的来源 URL
        // "source": "<a href=\"http://weibo.com/\" rel=\"nofollow\">微博 weibo.com</a>"
        NSString *src = [dic objectForKey:@"source"];
        NSRange urlStart = [src rangeOfString:@"<a href=\""];
        NSRange urlEnd;
        
        // 说明是有字符串 <a href
        if (urlStart.location != NSNotFound) {
            
            int srcLength = [src length];
            NSRange fromRange = NSMakeRange(urlStart.location + urlStart.length, srcLength - urlStart.location - urlStart.length);
            urlEnd = [src rangeOfString:@"\"" options:NSCaseInsensitiveSearch range:fromRange];
            
            if (urlEnd.location != NSNotFound) {
                self.sourceURL = [src substringWithRange:NSMakeRange(urlStart.location + urlStart.length, urlEnd.location - urlStart.length)];
            }
//            NSLog(@"the self.sourceURL is %@", self.sourceURL);
            
        }
        
        // 微博来源名称
        NSRange nameStart = [src rangeOfString:@"\">"];
        NSRange nameEnd   = [src rangeOfString:@"</a>"];
        if (nameStart.location != NSNotFound && nameEnd.location != NSNotFound) {
            NSRange temp;
            temp.location = nameStart.location + nameStart.length;
            temp.length = nameEnd.location - temp.location;
            self.source = [src substringWithRange:temp];
        }
        else {
            self.source = @"";
        }

        
        
        // 对微博创建时间进行处理
        // 格式："created_at": "Tue May 31 17:46:55 +0800 2011"
        NSString *originalCreatedAt = [dic objectForKey:@"created_at"];
        self.createdAt = [self getTimeString:originalCreatedAt];
    }
    return self;
    
}

+ (Status *)statusWithJSONDictionary:(NSDictionary *)dic
{
	return [[Status alloc] initWithJSONDictionary:dic];
}

-(NSString *) getTimeString:(NSString *) string{
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    [inputFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [inputFormatter setDateFormat:@"EEE MMM dd HH:mm:ss Z yyyy"];
    NSDate *inputDate = [inputFormatter dateFromString:string];
    
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setLocale:[NSLocale currentLocale]];
    [outputFormatter setDateFormat:@"HH:mm:ss"];
    NSString *timeString = [outputFormatter stringFromDate:inputDate];
    return timeString;
}


@end
