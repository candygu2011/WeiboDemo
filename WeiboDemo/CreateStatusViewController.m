//
//  CreateStatusViewController.m
//  WeiboDemo
//
//  Created by Lx JeOam on 14-5-10.
//  Copyright (c) 2014年 JeOam. All rights reserved.
//

#import "CreateStatusViewController.h"
#import "MBProgressHUD.h"
#import "weiboAPI.h"
#import "ASIFormDataRequest.h"
#

// UIImagePickerControllerDelegate, UINavigationControllerDelegate 是 UIImagePickerController 要用到的
@interface CreateStatusViewController () <UITextViewDelegate, UIAlertViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@end

@implementation CreateStatusViewController{
    MBProgressHUD *hud;
    // 是否有图片
    BOOL hasImage;
}

-(IBAction)createStatus:(id)sender{
    NSString *content = [[NSString alloc] initWithString:self.textView.text];
//    NSLog(@"%@", content);
    
    // 计算当前微博文字的长度，并做相应处理
    NSInteger contentLength = content.length;
    if (contentLength == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"请输入微博内容"
                                                       delegate:nil
                                              cancelButtonTitle:@"知道了"
                                              otherButtonTitles:nil, nil];
        [alert show];
    } else if (contentLength > 140){
        NSLog(@"超字数了");
        MBProgressHUD *overLengthHub = [[MBProgressHUD alloc] initWithView:self.view];
        overLengthHub.mode = MBProgressHUDModeText;
        overLengthHub.labelText = @"提示信息";
        overLengthHub.detailsLabelText = [NSString stringWithFormat:@"微博字数：%d，超过 140 上限", contentLength];
        [overLengthHub show:YES];
        [overLengthHub hide:YES afterDelay:2];
        [self.view addSubview:overLengthHub];
    } else {
        
        if (!hasImage) {
            [self postWithText:content];
        } else {
            UIImage *image = self.imageView.image;
            [self postWithText:content image:image];
        }
        
        hud = [[MBProgressHUD alloc] init];
        hud.dimBackground = YES;
        hud.labelText = @"正在发送...";
        [hud show:YES];
        [self.view addSubview:hud];
    }
    [self.textView resignFirstResponder];
//    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void) postWithText:(NSString *) text {
    NSURL *url = [NSURL URLWithString:WEIBO_UPDATE];
    ASIFormDataRequest *item =[[ASIFormDataRequest alloc] initWithURL:url];
    [item setPostValue:[weiboAPI returnAccessTokenString] forKey:@"access_token"];
    [item setPostValue:text forKey:@"status"];
    [item setCompletionBlock:^{
        
        self.textView.text = nil;
        
        // 设置 提示框
        [hud removeFromSuperview];
        MBProgressHUD *customHUD = [[MBProgressHUD alloc] initWithView:self.view];
        customHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark.png"]];
        customHUD.mode = MBProgressHUDModeCustomView;
        customHUD.labelText = @"发微博成功";
        [customHUD show:YES];
        [customHUD hide:YES afterDelay:2];
        [self.view addSubview:customHUD];
    }];
    [item startAsynchronous];
}

-(void) postWithText:(NSString *) text image:(UIImage *)image{
    
    NSURL *url = [NSURL URLWithString:WEIBO_UPLOAD];
    ASIFormDataRequest *item = [[ASIFormDataRequest alloc] initWithURL:url];
    
    [item setPostValue:[weiboAPI returnAccessTokenString] forKey:@"access_token"];
    [item setPostValue:text forKey:@"status"];
    [item addData:UIImagePNGRepresentation(image) forKey:@"pic"];
    [item setCompletionBlock:^{
        
        self.imageView.image = nil;
        self.textView.text = nil;
        [hud removeFromSuperview];
        self.cancelButton.hidden = YES;
        MBProgressHUD *customHUD = [[MBProgressHUD alloc] initWithView:self.view];
        customHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark.png"]];
        customHUD.labelText = @"发微博成功";
        customHUD.mode = MBProgressHUDModeCustomView;
        [customHUD show:YES];
        [customHUD hide:YES afterDelay:2];
    }];
    [item startAsynchronous];
}

// 添加图片
-(IBAction)addPhoto:(id)sender{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"添加图片" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"系统相册", @"拍摄", nil];
    [alert show];
}

// UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self addPhoto];
    } else if (buttonIndex == 2){
        [self takePhoto];
    }
}

-(void) addPhoto{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc]init];
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = YES;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

// UIImagePickerControllerDelegate
-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    self.imageView.image = image;
    hasImage = YES;
    self.cancelButton.hidden = NO;
}

-(void) takePhoto{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"本设备不支持拍照功能" delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"知道了", nil];
        [alert show];
    } else {
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePickerController.delegate = self;
        imagePickerController.allowsEditing = YES;
        [self presentViewController:imagePickerController animated:YES completion:nil];
    }
}

//

-(IBAction)cancelImage:(id)sender{
    self.cancelButton.hidden = YES;
    self.imageView.image = nil;
}

// 初始化
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.textView becomeFirstResponder];
    hasImage = NO;
    self.cancelButton.hidden = YES;
    
    // 在输入框加一个 Done 按钮退出键盘
    UIToolbar *topView = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    
    // 这里缺少 Button1，Button2 的话，doneButton 按钮会被放到 toolbar 的左边
    UIBarButtonItem *Button1 = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:nil];
    UIBarButtonItem *Button2 = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(dismissKeyBoard)];
    [topView setItems:@[Button1,Button2,doneButton]];
    [self.textView setInputAccessoryView:topView];
    
    // 设置 textView 属性
    self.textView.backgroundColor = [UIColor colorWithRed:237/255.0  green:237/255.0 blue:237/255.0 alpha:1.0];
}

-(void)dismissKeyBoard{
    [self.textView resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

@end
