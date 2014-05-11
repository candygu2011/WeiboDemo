//
//  Status.h
//  WeiboDemo
//
//  Created by Lx JeOam on 14-5-7.
//  Copyright (c) 2014年 JeOam. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Status : NSObject

// 微博 ID
@property (nonatomic) long long statusID;

// 微博创建时间
@property (nonatomic, strong) NSString *createdAt;
// 微博信息内容
@property (nonatomic, strong) NSString *text;
// 微博来源
@property (nonatomic, strong) NSString *source;
// 微博来源 URL
@property (nonatomic, strong) NSString *sourceURL;

// 是否已收藏，true：是，false：否
@property (nonatomic, assign) BOOL favorited;

// 缩略图片地址，没有时不返回此字段
@property (nonatomic, strong) NSString *thumbnailPic;
// 中等尺寸图片地址，没有时不返回此字段
@property (nonatomic, strong) NSString *bMiddlePic;
// 原始图片地址，没有时不返回此字段
@property (nonatomic, strong) NSString *originalPic;

// 作者信息
//@property (nonatomic, retain) User *user;
// 微博作者
@property (nonatomic, strong) NSString *screenName;
// 微博作者头像
@property (nonatomic, strong) NSString *profileImageURL;

// 评论数
@property (nonatomic, assign) int commentsCount;
// 转发数
@property (nonatomic, assign) int repostsCount;
// 转发的博文，内容为status，如果不是转发，则没有此字段
@property (nonatomic, retain) Status *retweetedStatus;

// 转发的微博是否带图片
@property (nonatomic, assign) BOOL hasForwardedPic;
// 原创的微博是否带图片
@property (nonatomic, assign) BOOL hasPic;



- (Status *)initWithJSONDictionary:(NSDictionary *)dic;

+ (Status *)statusWithJSONDictionary:(NSDictionary *)dic;



@end
