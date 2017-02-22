//
//  ViewController.m
//  OSSUploadFileTool
//
//  Created by ZhangZn on 2017/2/22.
//  Copyright © 2017年 Bizvane. All rights reserved.
//

#import "ViewController.h"
#import <AliyunOSSiOS/OSSService.h>
#import "OSSImageUpTools.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController () <UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIActionSheetDelegate>{
    UIButton *uploadBtn;
}
@property (nonatomic, strong) UIImagePickerController *imagePickerController;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setUploadFileBtn];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)setUploadFileBtn {
    if (!uploadBtn) {
        uploadBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 120, 44)];
        uploadBtn.center = CGPointMake([[UIScreen mainScreen] bounds].size.width/2, [[UIScreen mainScreen] bounds].size.height/2);
        uploadBtn.backgroundColor = [UIColor greenColor];
        uploadBtn.layer.masksToBounds = YES;
        uploadBtn.layer.cornerRadius = 5.0f;
        [uploadBtn setTitle:@"上传图片" forState:UIControlStateNormal];
        [uploadBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [uploadBtn addTarget:self action:@selector(selectFile) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:uploadBtn];
    }
}

- (void)selectFile {
    BOOL canCamera;
    
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
        canCamera = NO;
    }
    else{
        canCamera = YES;
    }
    if (!canCamera) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"请前往设置>隐私>相机，开启相机服务" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"设置", nil];
        alertView.tag = 10005;
        [alertView show];
    }
    else{
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] && canCamera) {
            UIActionSheet * imageSheet=[[UIActionSheet alloc]initWithTitle:@"选择" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"手机相册", nil];
            imageSheet.tag = 1005;
            [imageSheet showInView:self.view];
            
        }else{
            UIActionSheet * imageSheet=[[UIActionSheet alloc]initWithTitle:@"选择" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"手机相册", nil];
            imageSheet.tag = 1005;
            [imageSheet showInView:self.view];
        }
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{

    if (actionSheet.tag == 1005) {
        NSUInteger sourceType=0;
        //判断是否支持相机
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            switch (buttonIndex) {
                case 0:
                    //相机
                    sourceType=UIImagePickerControllerSourceTypeCamera;
                    break;
                case 1:
                    //相册
                    sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
                    break;
                case 2:
                    //取消
                    return;
                    break;
            }
        }else{
            if(buttonIndex==0){
                sourceType=UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            }else{
                return;
            }
        }
        //跳转相册或者相机
        _imagePickerController = [[UIImagePickerController alloc]init];
        _imagePickerController.delegate = self;
        _imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
        _imagePickerController.sourceType = sourceType;
        
        NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [UIColor whiteColor],
                                    NSForegroundColorAttributeName, nil];
        [_imagePickerController.navigationBar setTitleTextAttributes:attributes];
        [self presentViewController:_imagePickerController animated:YES completion:nil];
    }
}

#pragma imagePicker delegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [picker dismissViewControllerAnimated:YES completion:^() {
        _imagePickerController = nil;
        _imagePickerController.delegate = nil;
        _imagePickerController.delegate = nil;
        UIImage *portraitImg = info[@"UIImagePickerControllerOriginalImage"];
        
        NSData *imageData = UIImageJPEGRepresentation(portraitImg,1);
        [self upLoadImage:imageData];
    }];
}

#pragma mark 设置imagePickerController导航栏字体颜色
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    // bug fixes: UIIMagePickerController使用中偷换StatusBar颜色的问题
    if ([navigationController isKindOfClass:[UIImagePickerController class]] &&
        ((UIImagePickerController *)navigationController).sourceType ==     UIImagePickerControllerSourceTypePhotoLibrary) {
        navigationController.navigationBar.tintColor = [UIColor whiteColor];
    }
}

//上传图片
- (void)upLoadImage:(NSData *)uploadImageData{
    NSDate *date = [NSDate date];
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc]init];
    [dateformatter setDateFormat:@"yyyy-MM-ddHH:mm:ss"];
    NSString *timeStr = [dateformatter stringFromDate:date];
    NSString *imageName = [NSString stringWithFormat:@"%@.jpg",timeStr];
    OSSImageUpTools *upLoad = [[OSSImageUpTools alloc] initUploadWithCategory:@"image/jpeg" public:NO key:imageName data:uploadImageData];
    [upLoad startUploadWithCallback:^(NSString *path) {
        if (path) {
            NSLog(@"success!");
        }
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
