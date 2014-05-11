//
//  ViewController.h
//  WeiboDemo
//
//  Created by Lx JeOam on 14-5-7.
//  Copyright (c) 2014年 JeOam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<UIWebViewDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIWebView *webView;

@end
