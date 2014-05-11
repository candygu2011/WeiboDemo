//
//  WeiboTableViewCell.m
//  WeiboDemo
//
//  Created by Lx JeOam on 14-5-8.
//  Copyright (c) 2014年 JeOam. All rights reserved.
//

#import "WeiboTableViewCell.h"

#define FONT_SIZE 14.0f
#define CELL_CONTENT_WIDTH 320.0f
#define CELL_CONTENT_MARGIN 5.0f

@implementation WeiboTableViewCell

-(void) setupWeiboTableViewCell:(Status *)status{
    
    NSLog(@"WeiboTableViewCell setupWeiboTableViewCell Methods Works");
    
    __block UIImageView *profileImageView = [[UIImageView  alloc] initWithFrame:CGRectZero];
    [profileImageView setFrame:CGRectMake(CELL_CONTENT_MARGIN, CELL_CONTENT_MARGIN, 50, 50)];
    
    // 设置头像圆角
    CALayer *layer = [profileImageView layer];
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:6.0];
    
    __block UIImage *profileImage = [[UIImage alloc] init];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        profileImage = [self getImageFromURL:status.profileImageURL];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [profileImageView setImage:profileImage];
            [[self contentView] addSubview:profileImageView];
        });
    });

    
    // 微博作者名称
    UILabel *authorNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 10, 160, 28)];
    [authorNameLabel setFont:[UIFont boldSystemFontOfSize:17.0f]];
    [authorNameLabel setText:status.screenName];
    authorNameLabel.adjustsFontSizeToFitWidth = YES;
    [[self contentView] addSubview:authorNameLabel];
    
    
    // 评论与转发
    UILabel *commentLabel = [[UILabel alloc] initWithFrame:CGRectMake(200, 13, 100, 28)];
    [commentLabel setText:[NSString stringWithFormat:@"评论：%d  转发：%d   ", status.commentsCount ,status.repostsCount]];
    commentLabel.adjustsFontSizeToFitWidth = YES;
    [commentLabel setTextAlignment:NSTextAlignmentRight];
    [[self contentView] addSubview:commentLabel];
    
    
    // 微博的内容
    UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [contentLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [contentLabel setNumberOfLines:0];
    [contentLabel setFont:[UIFont systemFontOfSize:FONT_SIZE]];
    [contentLabel setText:status.text];
    [[self contentView] addSubview:contentLabel];
    
    // 用于标记空白地方的高度（x，y）中的 y
    CGFloat Height = 0.0;
    CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), MAXFLOAT); //(width, height)
    
    
    NSDictionary *attribute = @{NSFontAttributeName: [UIFont systemFontOfSize:FONT_SIZE]};
    
    CGSize textSize = [status.text boundingRectWithSize:constraint
                                                options:NSStringDrawingUsesLineFragmentOrigin
                                             attributes:attribute
                                                context:nil].size;
    [contentLabel setFrame:CGRectMake(CELL_CONTENT_MARGIN,
                                      profileImageView.frame.origin.y + profileImageView.frame.size.height + CELL_CONTENT_MARGIN,
                                      CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2),
                                      textSize.height)];
    
    Height =contentLabel.frame.origin.y + contentLabel.frame.size.height;
    
    // 转发的微博，可能为空
    Status *retweetStatus = status.retweetedStatus;
    if (retweetStatus) {
        NSString *retweetContent =[NSString stringWithFormat:@"%@ : %@", retweetStatus.screenName, retweetStatus.text];
        
        UILabel *retweetContentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [retweetContentLabel setBackgroundColor:[UIColor grayColor]];
        [retweetContentLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [retweetContentLabel setNumberOfLines:0];
        [retweetContentLabel setFont:[UIFont systemFontOfSize:FONT_SIZE]];
        [retweetContentLabel setText:retweetContent];
        [[self contentView] addSubview:retweetContentLabel];
         
        
        CGSize retweetConstraint = CGSizeMake(CELL_CONTENT_WIDTH - CELL_CONTENT_MARGIN * 2, MAXFLOAT);
        NSDictionary *retweetAttribute = @{NSFontAttributeName: [UIFont systemFontOfSize:FONT_SIZE]};
        CGSize retweetTextSize = [retweetContent boundingRectWithSize:retweetConstraint
                                                              options:NSStringDrawingUsesLineFragmentOrigin
                                                           attributes:retweetAttribute
                                                              context:nil].size;
        [retweetContentLabel setFrame:CGRectMake(6,
                                                 contentLabel.frame.origin.y + contentLabel.frame.size.height + CELL_CONTENT_MARGIN,
                                                 CELL_CONTENT_WIDTH - CELL_CONTENT_MARGIN * 2,
                                                 retweetTextSize.height)];
        
        // 加上转为的微博内容所占的高度
        Height +=retweetContentLabel.frame.size.height;
        
        // 如果转发的微博有图像
        if (status.retweetedStatus.hasForwardedPic) {
            __block UIImageView *retweetImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
            __block UIImage *retweetImage = [[UIImage alloc] init];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                retweetImage = [self getImageFromURL:status.retweetedStatus.thumbnailPic];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    CGSize retweetImageSize = CGSizeMake(retweetImage.size.width, retweetImage.size.height);
                    
                    [retweetImageView setFrame:CGRectMake((CELL_CONTENT_WIDTH - CELL_CONTENT_MARGIN * 2 - retweetImageSize.width) / 2,
                                                          retweetContentLabel.frame.origin.y + retweetContentLabel.frame.size.height + CELL_CONTENT_MARGIN,
                                                          retweetImageSize.width,
                                                          retweetImageSize.height)];
                    [retweetImageView setImage:retweetImage];
                    [[self contentView] addSubview:retweetImageView];
                });
            });
            
            Height = +120;
        }
    } else {
        if (status.hasPic) {
            __block UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
            __block UIImage *image = [[UIImage alloc] init];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                image = [self getImageFromURL:status.thumbnailPic];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    CGSize imageSize = CGSizeMake(image.size.width, image.size.height);
                    
                    [imageView setFrame:CGRectMake((CELL_CONTENT_WIDTH - CELL_CONTENT_MARGIN * 2 - imageSize.width) / 2,
                                                          contentLabel.frame.origin.y + contentLabel.frame.size.height + CELL_CONTENT_MARGIN,
                                                          imageSize.width,
                                                          imageSize.height)];
                    [imageView setImage:image];
                    [[self contentView] addSubview:imageView];
                });
            });
            
            
            Height += 120;
        }
    }
    
    Height += CELL_CONTENT_MARGIN;
    
    UILabel *fromLabel = [[UILabel alloc] initWithFrame:CGRectMake(CELL_CONTENT_MARGIN,
                                                                   Height,
                                                                   140,
                                                                   21)];
    [fromLabel setText:[NSString stringWithFormat:@"来自：%@", status.source]];
    [fromLabel setFont:[UIFont systemFontOfSize:FONT_SIZE]];
    [fromLabel setTextAlignment:NSTextAlignmentLeft];
    fromLabel.adjustsFontSizeToFitWidth = YES;
    [[self contentView] addSubview:fromLabel];
    
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(170, Height, 140, 21)];
    [timeLabel setFont:[UIFont systemFontOfSize:FONT_SIZE]];
    [timeLabel setText:status.createdAt];
    [timeLabel setTextAlignment:NSTextAlignmentRight];
    timeLabel.adjustsFontSizeToFitWidth = YES;
    [[self contentView] addSubview:timeLabel];
}

-(UIImage *) getImageFromURL:(NSString *) imageURL {
    UIImage *resultImage = [[UIImage alloc] init];
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
    resultImage = [UIImage imageWithData:data];
    return resultImage;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    NSLog(@"WeiboTableViewCell was inited");
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
