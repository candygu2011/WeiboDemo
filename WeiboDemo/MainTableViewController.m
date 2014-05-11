//
//  MainTableViewController.m
//  WeiboDemo
//
//  Created by Lx JeOam on 14-5-8.
//  Copyright (c) 2014年 JeOam. All rights reserved.
//

#import "MainTableViewController.h"
#import "MBProgressHUD.h"
#import "weiboAPI.h"
#import "JSONKit.h"

#define FONT_SIZE 14.0f
#define CELL_CONTENT_WIDTH 320.0f
#define CELL_CONTENT_MARGIN 10.0f

static NSString *CellIdentifier = @"MainCell";

@interface MainTableViewController ()
@end

@implementation MainTableViewController{
    NSMutableArray *array; // 一组微博的信息，原始的 JSON 数据
    int weiboPage; // 微博的页数
    MBProgressHUD *hud;
    __block NSMutableArray *tempArray;
}


-(void) getWeiboData:(int) page {
    
    NSLog(@"MainTableViewController.m getWeiboData methods was called");
    
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
//            NSLog(@"the weiboStatusDictionary is %@", weiboStatusDictionary); //经验证，能正常获得 JSON 数据
            
            if ([array count] != 0) {
                [array removeAllObjects];
            }
            
            [array addObjectsFromArray:[weiboStatusDictionary objectForKey:@"statuses"]];
//            NSLog(@"the array is %@", array); //正常
            
            for (NSDictionary *dictionary in array) {
                Status *status =[[Status alloc] init];
                status = [status initWithJSONDictionary:dictionary];
//                NSLog(@"the status is %@", status);  // 正常
                [tempArray addObject:status];
            }
            
            
        });
        
        for (id obj in tempArray) {
            [self.statusArray addObject:obj];
        }
        NSLog(@"self.statusArray is %@", self.statusArray);


        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [hud removeFromSuperview];
            // 数据加载好后，刷新 tableView 数据
            [self.tableView reloadData];
            
            // 每次数据重新加载后，回到顶部
            self.tableView.contentOffset = CGPointMake(0, 0 - self.tableView.contentInset.top);
        });
    });
}



- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"MainTableViewController viewDidLoad method was called");
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    weiboPage = 1;
    array = [[NSMutableArray alloc] init];
    self.statusArray = [[NSMutableArray alloc] init];
    tempArray = [[NSMutableArray alloc] init];
    [self getWeiboData:weiboPage];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSLog(@"MainTableViewController numberOfSectionsInTableView method was called");
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    NSLog(@"MainTableViewController numberOfRowsInSection method was called");
    return [self.statusArray count];
}

// 处理tableview滑动到底了
- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGPoint contentOffsetPoint = self.tableView.contentOffset;
    
    CGRect frame = self.tableView.frame;
    
    if (contentOffsetPoint.y == self.tableView.contentSize.height - frame.size.height)
    {
        [self getWeiboData:++weiboPage];
        NSLog(@"getWeiboData ++  method was called");
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"MainTableViewController cellForRowAtIndexPath method was called");
    
    WeiboTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    Status *status = [[Status alloc] init];
    status = [self.statusArray objectAtIndex:[indexPath row]];
    if (cell != nil) {
        [cell removeFromSuperview]; //处理重用
    }
    
    cell = [[WeiboTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    [cell setupWeiboTableViewCell:status];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSLog(@"MainTableViewController heightForRowAtIndexPath method was called");

    Status *status = [[Status alloc] init];
    status = [self.statusArray objectAtIndex:[indexPath row]];
    
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

- (IBAction)refreshButton:(id)sender {
    tempArray = [[NSMutableArray alloc] init];
    self.statusArray = [[NSMutableArray alloc] init];
    
    //重新回到第一页
    weiboPage = 1;
    [self getWeiboData:weiboPage];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
