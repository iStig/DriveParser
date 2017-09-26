//
//  HZCUpLoadPhoto.h
//  huizuche
//
//  Created by liwei on 16/7/5.
//  Copyright © 2016年 EasyTrip. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
typedef void (^ CompleteUrl)(BOOL success,NSDictionary *url);
typedef void (^ SubmitProgress)(float progress);

@interface HZCUpLoadPhoto : NSObject

- (void)subMitPhotoForCdlWithImage:(UIImage *)image CompleteBlock:(CompleteUrl)urlBlock SubmitBlock:(SubmitProgress)progressBlock;
@end
