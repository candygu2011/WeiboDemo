//
//  weiboAPI.h
//  WeiboDemo
//
//  Created by Lx JeOam on 14-5-7.
//  Copyright (c) 2014年 JeOam. All rights reserved.
//

#import <Foundation/Foundation.h>

#define APP_KEY                         @"[需要替换]"
#define APP_SECRET                      @"[需要替换]"
#define APP_REDIRECT_URL                @"http://weibo.com"

#define OAuth_URL                       @"https://api.weibo.com/oauth2/authorize"
#define ACCESS_TOKEN_URL                @"https://api.weibo.com/oauth2/access_token"
#define GET_UID_URL                     @"https://api.weibo.com/2/account/get_uid.json"

//发送文字微博
#define WEIBO_UPDATE                    @"https://api.weibo.com/2/statuses/update.json"
//发送文字和图片微博
#define WEIBO_UPLOAD                    @"https://api.weibo.com/2/statuses/upload.json"


#

#define FRIENDS_TIMELINE                @"https://api.weibo.com/2/statuses/friends_timeline.json"

@interface weiboAPI : NSObject

// 获取请求授权时所用的 URL
+ (NSString *) returnOAuthUrlString;

// 发微博时需要调用
+ (NSString *)returnAccessTokenString;


// 用授权成功后的 code 获取 access_token
- (void) getAccessToken:(NSString *)code;


//用于加载 已关注好友 的微博数据 的URL (加载的页数：page)
+ (NSString *) returnFriendsTimelintURLString :(int)page;

@end
