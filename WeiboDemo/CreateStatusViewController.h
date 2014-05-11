//
//  CreateStatusViewController.h
//  WeiboDemo
//
//  Created by Lx JeOam on 14-5-10.
//  Copyright (c) 2014年 JeOam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CreateStatusViewController : UIViewController

-(IBAction)createStatus:(id)sender;
-(IBAction)addPhoto:(id)sender;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

-(IBAction)cancelImage:(id)sender;

@end
