//
//  ViewController.m
//  WeiboDemo
//
//  Created by Lx JeOam on 14-5-7.
//  Copyright (c) 2014年 JeOam. All rights reserved.
//

#import "ViewController.h"
#import "weiboAPI.h"
#import "MBProgressHUD.h"

@interface ViewController ()

@end

@implementation ViewController{
    NSTimer *timer;
    MBProgressHUD *hud;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"initPic.jpg"]];
    [self.view addSubview:self.imageView];
    
    hud = [[MBProgressHUD alloc] init];
    
    //[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"access_token"]; //移除已有 access_token，测试授权流程
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"access_token"] == nil) {
        
        hud.labelText = @"正在加载授权页面...";
        [hud show:YES];
        [self.view addSubview:hud];
        
        self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
        NSString *oauthUrlString = [weiboAPI returnOAuthUrlString];
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:oauthUrlString]];
        self.webView.delegate = self;
        [self.webView loadRequest:request];
        self.webView.alpha = 0.0;
        [self.view addSubview:self.webView];
        
        timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(goWebView) userInfo:nil repeats:NO];
    } else {
        hud.labelText = @"正在加载微博内容...";
        [hud show:YES];
        [self.view addSubview:hud];
        
        timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(goMainView) userInfo:nil repeats:NO];
    }
    
    //    NSLog(@"%@", self.webView); // 检查 webView 的 frame 属性是否为 0
    //    NSLog(@"%@", [request URL]); //打印 oauthUrlString 的值

}

- (void) goWebView {
    
    [UIView animateWithDuration:2.0 animations:^{
        [hud removeFromSuperview];
        self.webView.alpha = 1.0;
        [self.imageView removeFromSuperview];
    }];
}

-(void) goMainView{
    [UIView animateWithDuration:2.0 animations:^{
        [hud removeFromSuperview];
        [self.imageView removeFromSuperview];
        [self.webView removeFromSuperview];
        [self performSegueWithIdentifier:@"MainSegue" sender:nil];
    }];
}

- (void) webViewDidFinishLoad:(UIWebView *)webView {
    [hud removeFromSuperview];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"access_token"] != nil) {
        [UIView animateWithDuration:2.0 animations:^{
            [hud removeFromSuperview];
            [self.imageView removeFromSuperview];
            [self.webView removeFromSuperview];
            [self performSegueWithIdentifier:@"MainSegue" sender:nil];
        }];
    }
}

-(BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    NSURL *returnURL = [request URL];
    
    NSString *returnURLString = [returnURL absoluteString];
    
    // 判断是否是授权成功返回的 URL，取出 code 对应的值
    if ([returnURLString hasPrefix:@"http://weibo.com/?"]){
        NSLog(@"The returnURLString is %@", returnURLString);
        //格式会是:The returnURLString is http://weibo.com/?state=authorize&code=9d73c62a460767c501569230f0b84863
        
        //找到 "code=" 的 range
        NSRange rangeOfcode = [returnURLString rangeOfString:@"code="];
        
        NSRange rangeValueOfcode = NSMakeRange(rangeOfcode.length + rangeOfcode.location, returnURLString.length - (rangeOfcode.location + rangeOfcode.length));
        
        //获取 code 对应的值
        NSString *codeString = [returnURLString substringWithRange:rangeValueOfcode];
        NSLog(@"code = :%@",codeString);
        
        weiboAPI *weiboapi = [[weiboAPI alloc] init]; //这里容易犯一个错误：http://stackoverflow.com/a/11949335/769424
        [weiboapi getAccessToken:codeString];
    }
    
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
