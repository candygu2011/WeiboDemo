//
//  MainTableViewController.h
//  WeiboDemo
//
//  Created by Lx JeOam on 14-5-8.
//  Copyright (c) 2014年 JeOam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Status.h"
#import "WeiboTableViewCell.h"

@interface MainTableViewController : UITableViewController

//一组微博信息，以 Status 类存放的格式
@property (nonatomic, strong) NSMutableArray *statusArray;

- (IBAction)refreshButton:(id)sender;


@end
