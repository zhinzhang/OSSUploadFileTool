//
//  OSSImageUpTools.h
//  Ishow
//
//  Created by zhang on 16/5/28.
//  Copyright © 2016年 Burgeon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AliyunOSSiOS/OSSService.h>

@interface OSSImageUpTools : NSObject

//上传方法
- (id)initUploadWithCategory:(NSString *)category public:(BOOL)isPublic key:(NSString *)key data:(NSData *)uploadData;
//上传方法回调
- (void)startUploadWithCallback:(void (^)(NSString *path))uploadCallback;

@end
