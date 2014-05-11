//
//  MainViewController.m
//  WeiboDemo
//
//  Created by Lx JeOam on 14-5-9.
//  Copyright (c) 2014年 JeOam. All rights reserved.
//

#import "MainViewController.h"
#import "WeiboTableViewCell.h"
#import "MBProgressHUD.h"
#import "JSONKit.h"
#import "weiboAPI.h"

#define FONT_SIZE 14.0f
#define CELL_CONTENT_WIDTH 320.0f
#define CELL_CONTENT_MARGIN 10.0f

static NSString *MyCellIdentifier = @"My Cell";

@interface MainViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *myTableView;

@end

@implementation MainViewController{
    NSMutableArray *JSONarray; // 一组微博的信息，原始的 JSON 数据
    NSMutableArray *statusArray; ////一组微博信息，以 Status 类存放的格式
    int weiboPage; // 微博的页数
    MBProgressHUD *hud;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.myTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [self.myTableView registerClass:[WeiboTableViewCell  class] forCellReuseIdentifier:MyCellIdentifier];
    self.myTableView.dataSource = self;
    self.myTableView.delegate = self;
    self.myTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.myTableView];
    
    statusArray = [[NSMutableArray alloc] init];
    JSONarray = [[NSMutableArray alloc] init];
    weiboPage = 1;
    [self getWeiboData:weiboPage];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [statusArray count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    WeiboTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyCellIdentifier forIndexPath:indexPath];
    
    Status *status = [[Status alloc] init];
    status = [statusArray objectAtIndex:[indexPath row]];
    if (cell != nil) {
        [cell removeFromSuperview]; //处理重用
    }
    
    cell = [[WeiboTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyCellIdentifier];
    [cell setupWeiboTableViewCell:status];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    Status *status = [[Status alloc] init];
    status = [statusArray objectAtIndex:[indexPath row]];
    
    // 高度设置
    CGFloat Height = 70.0;
    CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), MAXFLOAT); //(width, height)
    
    // 计算微博内容需要的位置（宽，高），但这个方法已经在 iOS 7 中被废弃了
    //CGSize sizeOne = [status.text sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
    
    NSDictionary *attribute = @{NSFontAttributeName: [UIFont systemFontOfSize:FONT_SIZE]};
    
    CGSize textSize = [status.text boundingRectWithSize:constraint
                                                options:NSStringDrawingUsesLineFragmentOrigin
                                             attributes:attribute
                                                context:nil].size;
    Height +=(textSize.height + CELL_CONTENT_MARGIN);
    
    // 转发的微博，可能为空
    Status *retweetStatus = status.retweetedStatus;
    
    // 是否有转发的微博
    if (retweetStatus) {
        NSString *retweetContent =[NSString stringWithFormat:@"%@ : %@", retweetStatus.screenName, retweetStatus.text];
        CGSize retweetConstraint = CGSizeMake(CELL_CONTENT_WIDTH - CELL_CONTENT_MARGIN * 2, MAXFLOAT);
        NSDictionary *retweetAttribute = @{NSFontAttributeName: [UIFont systemFontOfSize:FONT_SIZE]};
        CGSize retweetTextSize = [retweetContent boundingRectWithSize:retweetConstraint
                                                              options:NSStringDrawingUsesLineFragmentOrigin
                                                           attributes:retweetAttribute
                                                              context:nil].size;
        Height +=(retweetTextSize.height + CELL_CONTENT_MARGIN);
        
        if (status.retweetedStatus.hasForwardedPic) {
            Height += (120 + CELL_CONTENT_MARGIN);
        }
    } else {
        if (status.hasPic) {
            Height += (120 + CELL_CONTENT_MARGIN);
        }
    }
    
    Height += 20;
    return Height;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void) getWeiboData:(int) page {
    
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(globalQueue, ^{
        
        hud = [[MBProgressHUD alloc] init];
        hud.labelText = @"正在加载数据...";
        [hud show:YES];
        [self.view addSubview:hud];
        
        dispatch_sync(globalQueue, ^{
            
            NSURL *url = [NSURL URLWithString:[weiboAPI returnFriendsTimelintURLString:page]];
            NSLog(@"the FriendsTimelintURLString is %@", url);
            
            NSURLRequest *request = [NSURLRequest requestWithURL:url];
            NSData *weiboData = [NSURLConnection sendSynchronousRequest:request
                                                      returningResponse:nil
                                                                  error:nil];
            NSString *weiboString = [[NSString alloc] initWithData:weiboData encoding:NSUTF8StringEncoding];
            NSDictionary *weiboStatusDictionary = [weiboString objectFromJSONString];
            
            if ([JSONarray count] != 0) {
                [JSONarray removeAllObjects];
            }
            
            [JSONarray addObjectsFromArray:[weiboStatusDictionary objectForKey:@"statuses"]];
            
            for (NSDictionary *dictionary in JSONarray) {
                Status *status =[[Status alloc] init];
                status = [status initWithJSONDictionary:dictionary];
                [statusArray addObject:status];
            }
            
        });
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [hud removeFromSuperview];
        });
        
    });
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
