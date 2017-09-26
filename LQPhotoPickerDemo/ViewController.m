//
//  ViewController.m
//  LQPhotoPickerDemo
//
//  Created by 李庆 on 16/3/20.
//  Copyright © 2016年 李庆. All rights reserved.
//

#define SCREENHEIGHT [UIScreen mainScreen].bounds.size.height//获取设备高度
#define SCREENWIDTH [UIScreen mainScreen].bounds.size.width//获取设备宽度
#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;
#define SS(strongSelf)  __strong __typeof(&*self) strongSelf = weakSelf;
#import "ViewController.h"
#import "JKHttpServiceManager.h"
#import "HZCUpLoadPhoto.h"

@interface ViewController ()<LQPhotoPickerViewDelegate>

{
    //备注文本View高度
    float noteTextHeight;
    float pickerViewHeight;
    float allViewHeight;
    

}
@end

@implementation ViewController

#pragma mark - InitUI
- (MBProgressHUD *)HUD{
    if (!_HUD) {
        _HUD = [[MBProgressHUD alloc]initWithView:self.view];
        _HUD.userInteractionEnabled =NO;
        [self.view insertSubview:_HUD atIndex:[self.view.subviews count]];
    }
    return _HUD;
}


- (void)showHud{
    [self.HUD show:YES];
    [self.view bringSubviewToFront:self.HUD];
}

- (void)hiddenHud{
    if (_HUD) {
        [_HUD removeFromSuperview];
        _HUD = nil;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];

    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped)];
    tapGr.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGr];
    
    self.LQPhotoPicker_superView = _scrollView;
    
    self.LQPhotoPicker_imgMaxCount = 1;
    
    [self LQPhotoPicker_initPickerView];
    
    self.LQPhotoPicker_delegate = self;

    [self initViews];
}

- (void)viewTapped{
    [self.view endEditing:YES];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"caseLogNeedRef" object:nil];
}

- (void)initViews{
    _submitBtn = [[UIButton alloc]init];
    [_submitBtn setTitle:@"提交" forState:UIControlStateNormal];
    _submitBtn.frame = CGRectMake(100, 120, SCREENWIDTH-200, 30);
    [_submitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_submitBtn setBackgroundColor:[UIColor colorWithRed:255.0/255.0 green:155.0/255.0 blue:0.0/255.0 alpha:1.0]];
    [_submitBtn addTarget:self action:@selector(submitBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:_submitBtn];
    
    
    
    
    _text = [[UITextView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_submitBtn.frame)+10, SCREENWIDTH, 500)];
    _text.hidden = YES;
    [_scrollView addSubview:_text];
    
    
    _background = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_submitBtn.frame)+10, SCREENWIDTH, 500)];
    _background.hidden = YES;
    [_scrollView addSubview:_background];
    
    [self updateViewsFrame];
}
- (void)updateViewsFrame{
    
    if (!allViewHeight) {
        allViewHeight = 0;
    }
    if (!noteTextHeight) {
        noteTextHeight = 100;
    }

    allViewHeight = noteTextHeight + [self LQPhotoPicker_getPickerViewFrame].size.height + 30 + 100;
    _scrollView.contentSize = self.scrollView.contentSize = CGSizeMake(0,allViewHeight+1000);
}



- (void)submitBtnClicked{
    [self submitToServer];
}


#pragma mark - 上传数据到服务器前将图片转data（上传服务器用form表单：未写）
- (void)submitToServer{
//    //小图数据
    [self uploadImageOne];

}

- (void)LQPhotoPicker_pickerViewFrameChanged{
    [self updateViewsFrame];
}


- (NSString*)dictionaryToJson:(NSDictionary *)dic
{
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}


- (void)layoutOther:(NSDictionary *)dic {
 
   __block float h = 0 ;
    float w = [UIScreen mainScreen].bounds.size.width;
    float height = 25;
    float fontsize =12;
    
    if (dic) {
        NSArray *keys = dic.allKeys;
        NSLog(@"%@",keys);
        
        [keys enumerateObjectsUsingBlock:^(NSString* obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            
            if (![obj isEqualToString:@"Data"]) {
                UITextField *t = [[UITextField alloc] initWithFrame:CGRectMake(0, h, w/5*2, height)];
                t.text = obj;
                t.font = [UIFont systemFontOfSize:fontsize];
                [self.background addSubview:t];
                
                id b = dic[obj];
                if (![b isKindOfClass:[NSString class]]) {
                    b = @"";
                }
                
                UITextField *tr = [[UITextField alloc] initWithFrame:CGRectMake(w/5*2, h, w/5*3, height)];
                tr.text = b;
                tr.textAlignment = NSTextAlignmentRight;
                tr.borderStyle = UITextBorderStyleRoundedRect;
                tr.font = [UIFont systemFontOfSize:fontsize];
                [self.background addSubview:tr];
                h = h + height;
            }
        }];
    }
    
    
    
    
       NSDictionary *a = dic[@"Data"];
    if (a) {
        NSArray *keys = a.allKeys;
        NSLog(@"%@",keys);
        
        [keys enumerateObjectsUsingBlock:^(NSString* obj, NSUInteger idx, BOOL * _Nonnull stop) {
            UITextField *t = [[UITextField alloc] initWithFrame:CGRectMake(0, h, w/5*2, height)];
            t.text = obj;
            t.font = [UIFont systemFontOfSize:fontsize];
            [self.background addSubview:t];
            
            id b = a[obj];
            if (![b isKindOfClass:[NSString class]]) {
                b = @"";
            }
            
            UITextField *tr = [[UITextField alloc] initWithFrame:CGRectMake(w/5*2, h, w/5*3, height)];
            tr.text = b;
            tr.textAlignment = NSTextAlignmentRight;
            tr.borderStyle = UITextBorderStyleRoundedRect;
            tr.font = [UIFont systemFontOfSize:fontsize];
            [self.background addSubview:tr];
            h = h + height;
        }];
        
        
        UIButton* _submitBtna = [[UIButton alloc]init];
        [_submitBtna setTitle:@"修正" forState:UIControlStateNormal];
        _submitBtna.frame = CGRectMake(100, h+20, SCREENWIDTH-200, 30);
        [_submitBtna setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_submitBtna setBackgroundColor:[UIColor colorWithRed:255.0/255.0 green:155.0/255.0 blue:0.0/255.0 alpha:1.0]];
//        [_submitBtna addTarget:self action:@selector(submitBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.background addSubview:_submitBtna];
    }
    
}

- (void)removeAllSubviews {
    while (self.background.subviews.count) {
        UIView* child = self.background.subviews.lastObject;
        [child removeFromSuperview];
    }
}

#pragma mark ==单图片上传==
- (void)uploadImageOne {
      self.text.hidden = YES;
      self.background.hidden = YES;
     [self removeAllSubviews];
    
    //大图数据
    [self LQPhotoPicker_getBigImageDataArray];
    UIImage *uploadimage = nil;

    if (self.LQPhotoPicker_bigImageArray.count == 1) {
        uploadimage = self.LQPhotoPicker_bigImageArray[0];
    }else {

        return;
    }


    WS(weakSelf);
    [self showHud];
    HZCUpLoadPhoto *upLoad = [[HZCUpLoadPhoto alloc]init];
    [upLoad subMitPhotoForCdlWithImage:uploadimage CompleteBlock:^(BOOL success,NSDictionary *dic) {
        if (success) {
               weakSelf.background.hidden = NO;
//               weakSelf.text.text = [self dictionaryToJson:dic];
              [weakSelf layoutOther:dic];
        }else {
                weakSelf.text.hidden = NO;
                weakSelf.text.text = [self dictionaryToJson:dic];
            
        }
         [weakSelf hiddenHud];
     } SubmitBlock:^(float progress) {

    }];

//
//    //接口地址随便更改
//    NSString *url = @"http://172.16.102.82:8899/API/OCR/PhotoSubmit";
//    //字典
//    //    NSDictionary *params = @{@"test":@"1"};
//    NSDictionary *params = nil;
//    //图片data
//   UIImage *goodImage = [UIImage imageNamed:@"aaa.jpg"];//随便替换成什么图片
//    NSData *imageData = UIImageJPEGRepresentation(goodImage, 1);//压缩上传
//
//    [JKHttpServiceManager POST:url Params:params NSData:imageData key:@"goods" success:^(id responseObject, BOOL succe, NSDictionary *jsonDic) {
//        NSNumber *IsSuccess = jsonDic[@"IsSuccess"];
//        BOOL suc = IsSuccess.boolValue;
//        NSString *Message = jsonDic[@"Message"];
//        if (suc) {
//            NSLog(@"上传成功");
//            NSLog(@"%@",jsonDic);
//        }else {
//            NSLog(@"%@",jsonDic);
//            NSLog(@"%@",Message);
//        }
//        NSLog(@"%@",jsonDic);
//    } failure:^(NSError *error) {
//        NSLog(@"%@",error);
//
//    } animated:YES];
  
}
//#pragma mark ==多图上传==
//- (void)uploadImageArrary {
//    //接口地址随便更改
//    NSString *url = @"www.baidu.com";
//    //字典
//    NSDictionary *params = @{@"test":@"1"};
//    //图片data数组
//    UIImage *goodImage = [[UIImage alloc]init];//随便替换成什么图片
//    NSData *imageData = UIImageJPEGRepresentation(goodImage, 0.5);//压缩上传
//    NSArray *imageArr = @[imageData,imageData,imageData];
//    [JKHttpServiceManager POST:url Params:params NSArray:imageArr key:@"goods" success:^(id responseObject, BOOL succe, NSDictionary *jsonDic) {
//        if (succe) {
//            NSLog(@"上传成功");
//        }
//    } failure:^(NSError *error) {
//
//    } animated:YES];
//}
//
//#pragma mark ==图片数组使用加密上传==
//- (void)uploadImageChange {
//    //接口地址随便更改
//    NSString *url = @"www.baidu.com";
//
//    UIImage *goodImage = [[UIImage alloc]init];//随便替换成什么图片
//    NSData *imageData = UIImageJPEGRepresentation(goodImage, 0.5);//压缩上传
//    NSArray *imageArr = @[imageData,imageData,imageData];
//    NSMutableArray *list = [NSMutableArray array];
//    for (int i=0; i<imageArr.count; i++) {
//        NSData *image = imageArr[i];
//        NSString *s = [image base64Encoding];
//        [list addObject:s];
//    }
//    NSData *data = [NSJSONSerialization dataWithJSONObject:list options:NSJSONWritingPrettyPrinted error:nil];
//    NSString *imageString = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
//    [JKHttpServiceManager POST:url withParameters:@{@"test":@"1",@"goods":imageString} success:^(id responseObject, BOOL succe, NSDictionary *jsonDic) {
//        if (succe) {
//            NSLog(@"上传成功");
//        }
//    } failure:^(NSError *error) {
//
//    } animated:YES];
//}


@end

