//
//  weiboAPI.m
//  WeiboDemo
//
//  Created by Lx JeOam on 14-5-7.
//  Copyright (c) 2014年 JeOam. All rights reserved.
//

#import "weiboAPI.h"
#import "JSONKit.h"

@implementation weiboAPI

+(NSString *) returnOAuthUrlString{
    return [NSString stringWithFormat:@"%@?client_id=%@&redirect_uri=%@&response_type=code&display=mobile&state=authorize",OAuth_URL,APP_KEY,APP_REDIRECT_URL];
}

-(void) getAccessToken:(NSString *)code{
    
    // 请求获得 access_token 时用的 URL 的 string
    NSMutableString *accessTokenUrlString = [[NSMutableString alloc]
                                             initWithFormat:@"%@?client_id=%@&client_secret=%@&grant_type=authorization_code&redirect_uri=%@&code=",ACCESS_TOKEN_URL,APP_KEY,APP_SECRET,APP_REDIRECT_URL];
    [accessTokenUrlString appendString:code];
    
    // 创建 URL
    NSURL *urlstring = [NSURL URLWithString:accessTokenUrlString];
    
    // 创建请求的 URLRequest
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:urlstring cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    [request setHTTPMethod:@"POST"];//设置请求方式为POST，默认为GET
    
    // 连接服务器
    NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *receivedString = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
    
    // 把得到的 JSON 数据转换成 Dictionary 对象
    NSDictionary *dictionary = [receivedString objectFromJSONString]; // 这里用了 JSONKit 库，这个库不支持 ARC，需要一些额外的设置
    
    // 把 access_token 数据写入到环境设置中,用 NSUserDefaults 实现数据持久化，这样的好处是，如果是第一次登陆就出现授权界面，授权后保存access_token，之后登陆就不出现授权界面，直接进入微博主页视图了。
    [[NSUserDefaults standardUserDefaults] setObject:[dictionary objectForKey:@"access_token"] forKey:@"access_token"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSLog(@"the access_token is %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"access_token"]);
    //return: the access_token is 2.00URdPvBsZnwgC28657e54610Mfrvy
    
}

+ (NSString *) returnAccessTokenString {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"access_token"];
}

-(void) getUIDString{
    
    //组成一个 URL，根据这个 URL 查询 uid 的值，返回格式为：{"uid":1762109904}
    NSString *uidURLString = [[NSString alloc]
                              initWithFormat:@"%@?access_token=%@",
                              GET_UID_URL,
                              [weiboAPI returnAccessTokenString]];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:uidURLString]];
    NSError *error = nil;
    NSData *uidData = [NSURLConnection sendSynchronousRequest:request
                                            returningResponse:nil
                                                        error:&error];
    NSString *uidString = [[NSString alloc] initWithData:uidData encoding:NSUTF8StringEncoding];
    NSDictionary *uidDictionary = [uidString objectFromJSONString];
    [[NSUserDefaults standardUserDefaults] setObject:[uidDictionary objectForKey:@"uid"] forKey:@"uid"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSString *) returnFriendsTimelintURLString:(int)page{
    return [NSString stringWithFormat:@"%@?access_token=%@&page=%d",FRIENDS_TIMELINE,[weiboAPI returnAccessTokenString],page];
}

@end
