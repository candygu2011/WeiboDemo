//
//  WeiboTableViewCell.h
//  WeiboDemo
//
//  Created by Lx JeOam on 14-5-8.
//  Copyright (c) 2014年 JeOam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Status.h"


@interface WeiboTableViewCell : UITableViewCell

// MainTableViewController.m 调用这个方法
-(void) setupWeiboTableViewCell:(Status *)status;
@end
