//
//  OSSImageUpTools.m
//  Ishow
//
//  Created by zhang on 16/5/28.
//  Copyright © 2016年 Burgeon. All rights reserved.
//

#import "OSSImageUpTools.h"

NSString * const AccessKey = @"*********";
NSString * const SecretKey = @"************";
NSString * const endPoint = @"http://oss-cn-hangzhou.aliyuncs.com";
NSString * const multipartUploadKey = @"multipartUploadObject";
NSString * const path = @"http://bucket.oss-cn-hangzhou.aliyuncs.com/";
OSSClient * client;
OSSTask * task;

@implementation OSSImageUpTools{
    NSString *keyString;
}

/*
 *上传对象方法
 */
-(id)initUploadWithCategory:(NSString *)category public:(BOOL)isPublic key:(NSString *)key data:(NSData *)uploadData{
    self = [super init];
    
    //CDDoctorEntity *doctor = [[CDUser userDefaults] currentUser];
    
    id<OSSCredentialProvider> credential;
    OSSClient *client;
    OSSPutObjectRequest *put;
    keyString = nil;
    keyString = key;
    if(self){       //公有访问
        if(isPublic){
            credential = [[OSSPlainTextAKSKPairCredentialProvider alloc] initWithPlainTextAccessKey:AccessKey secretKey:SecretKey];
        }
        else{       //私有访问
            
            //自定义加签
            credential = [[OSSCustomSignerCredentialProvider alloc] initWithImplementedSigner:^NSString *(NSString *contentToSign, NSError *__autoreleasing *error) {
                
                NSString *signature = [OSSUtil calBase64Sha1WithData:contentToSign withSecret:SecretKey]; // 这里是用SDK内的工具函数进行本地加签，建议您通过业务server实现远程加签
                if (signature != nil) {
                    *error = nil;
                } else {
                    //*error = [NSError errorWithDomain:@"<your domain>" code:-1001 userInfo:@"<your error info>"];
                    return nil;
                }
                return [NSString stringWithFormat:@"OSS %@:%@", AccessKey, signature];
            }];
        }
        
        //初始化client
        client = [[OSSClient alloc] initWithEndpoint:endPoint credentialProvider:credential];
        
        //初始化put请求体并设定请求对象属性
        put = [OSSPutObjectRequest new];
        put.bucketName = @"products-image";
        put.objectKey = key;
        put.uploadingData = uploadData;
        
        //执行请求，获取请求结果task
        task = [client putObject:put];
    }
    return self;
}

/*
 *  取得请求结果后的回调方法。用于处理请求完毕后的操作。
 */
- (void)startUploadWithCallback:(void (^)(NSString *path))uploadCallback{
    
    //异步处理返回结果
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [task continueWithBlock:^id(OSSTask *task) {
            if (!task.error) {
                NSLog(@"上传成功");
                NSString *blockPath = [path stringByAppendingString:keyString];
                uploadCallback(blockPath);
            } else {
                NSLog(@"上传失败，错误提示: %@" , task.error);
                NSString *errorString = task.error.domain;
                uploadCallback(errorString);
                //task.error.code
            }
            return nil;
        }];
    });
}


@end
