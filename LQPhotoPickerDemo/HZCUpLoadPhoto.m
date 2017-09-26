//
//  HZCUpLoadPhoto.m
//  huizuche
//
//  Created by liwei on 16/7/5.
//  Copyright © 2016年 EasyTrip. All rights reserved.
//

#import "HZCUpLoadPhoto.h"

@interface HZCUpLoadPhoto ()<NSURLSessionDelegate>
@property (copy,nonatomic)SubmitProgress submitProgress;
@end

@implementation HZCUpLoadPhoto
- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}
- (void)subMitPhotoForCdlWithImage:(UIImage *)image CompleteBlock:(CompleteUrl)urlBlock SubmitBlock:(SubmitProgress)progressBlock {
    
    _submitProgress = progressBlock;
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
    NSInteger random = arc4random()%1000+9999;
    NSString *time =[NSString stringWithFormat:@"%lld%ld",(long long)timeInterval,(long)random];
    NSString *filename = [NSString stringWithFormat:@"%@.jpg",time];
    NSData *imageData = UIImageJPEGRepresentation(image,1);
    
    NSString *Boundary = @"----WebKitFormBoundaryRBZmc7X8WyiGmc7p";
    NSMutableData *bodyData =  [self generateRequestWithPhotoData:imageData FileName:filename];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://172.16.102.82:8899/API/OCR/PhotoSubmit"]];
    
    NSString *content=[[NSString alloc]initWithFormat:@"multipart/form-data; boundary=%@",Boundary];
    [request setValue:content forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[bodyData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPMethod:@"POST"];
    
    NSURLSessionConfiguration * configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionUploadTask * uploadtask = [session uploadTaskWithRequest:request fromData:bodyData completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data) {
            NSDictionary *jsonObject =[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            
            NSNumber *IsSuccess = jsonObject[@"IsSuccess"];
            BOOL suc = IsSuccess.boolValue;
            if (suc) {
                urlBlock(suc,jsonObject);
            }
            else{
               urlBlock(suc,jsonObject);
            }
        }
        else{
            NSDictionary *dic = @{@"Data":@"上传失败"};
             urlBlock(NO,dic);
        }
    }];
    [uploadtask resume];
}

- (NSMutableData *)generateRequestWithPhotoData:(NSData *)photoData FileName:(NSString *)fileName{
    NSString *Boundary =@"----WebKitFormBoundaryRBZmc7X8WyiGmc7p";
    NSString *MPboundary=[[NSString alloc]initWithFormat:@"--%@",Boundary];
    NSString *endMPboundary=[[NSString alloc]initWithFormat:@"%@--",MPboundary];
    NSData *data = photoData;
    NSMutableString *body=[[NSMutableString alloc]init];
    
    [body appendFormat:@"%@\r\n",MPboundary];
    [body appendFormat:@"Content-Disposition: form-data; name=\"photo\"; filename=\"%@\"\r\n",fileName];
    [body appendFormat:@"Content-Type: image/jpeg\r\n\r\n"];
    
    NSString *end=[[NSString alloc]initWithFormat:@"\r\n%@",endMPboundary];
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    [myRequestData appendData:data];
    [myRequestData appendData:[end dataUsingEncoding:NSUTF8StringEncoding]];
    return myRequestData;
}


-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend{
    if (_submitProgress) {
        _submitProgress(totalBytesSent/(float)totalBytesExpectedToSend);
    }
}
@end
