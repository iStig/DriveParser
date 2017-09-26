//
//  ViewController.h
//  LQPhotoPickerDemo
//
//  Created by 李庆 on 16/3/20.
//  Copyright © 2016年 李庆. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LQPhotoPickerViewController.h"
#import "MBProgressHUD.h"

@interface ViewController : LQPhotoPickerViewController<UITextViewDelegate>

@property (strong, nonatomic)MBProgressHUD *HUD;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

//提交按钮
@property (nonatomic,strong) UIButton *submitBtn;
@property (nonatomic,strong) UITextView *text;
@property (nonatomic, strong) UIView *background;
@end

