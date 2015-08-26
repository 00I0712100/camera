//
//  CameraViewController.m
//  camera
//
//  Created by TomokoTakahashi on 2015/08/26.
//  Copyright (c) 2015年 高橋知子. All rights reserved.
//

#import "CameraViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

#define FOCUS_LAYER_RECT_SIZE 73.0
@interface CameraViewController ()<AVCaptureAudioDataOutputSampleBufferDelegate,UIImagePickerControllerDelegate,UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet GPUImageView *previewImage;
@property (weak, nonatomic) IBOutlet GPUImageView *filterImage;
@property (weak, nonatomic) IBOutlet UIView *touchView;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet UIButton *captureButton;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UIButton *flashButton;

@property (weak, nonatomic) CALayer *shutterUpper;
@property (weak, nonatomic) CALayer *shutterLower;

- (IBAction)captureAction:(id)sender;
- (IBAction)closeAction:(id)sender;
- (IBAction)flashAction:(id)sender;
- (IBAction)cameraPositionChangeAction:(id)sender;

@end

@implementation CameraViewController {
    AVCaptureSession *_session;
    AVCaptureStillImageOutput *_dataOutputImage;
    AVCaptureVideoDataOutput *_dataOutputVideo;
    UIView *_focusView;
    BOOL _isShowFlash;
    NSInteger _layerHideCount;
    
    NSString *_albumName;
    ALAssetsLibrary *_library;
    BOOL _albumWasFound;
    NSURL *_groupURL;
    
    GPUImagePicture *sourcePicture;
    GPUImageOutput<GPUImageInput> *sepiaFilter, *sepiaFilter2;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    // ビデオキャプチャデバイスの取得
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // デバイス入力の取得 - input
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:NULL];
    
    // フラッシュをオフ
    NSError *error = nil;
    if ([device lockForConfiguration:&error]) {
        if ([device isFlashModeSupported:AVCaptureFlashModeOff]) {
            device.flashMode = AVCaptureFlashModeOff;
        }
        
        [device unlockForConfiguration];
    }
    
    // イメージデータ出力の作成 - output
    _dataOutputImage = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputImageSettions = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG, AVVideoCodecKey, nil];
    _dataOutputImage.outputSettings = outputImageSettions;
    
    // 写真を撮影する場所を表示させるためにビデオデータを作っている
    // ビデオデータ出力の作成 - output
    _dataOutputVideo = [[AVCaptureVideoDataOutput alloc] init];
    NSMutableDictionary *outputVideoSettings = [NSMutableDictionary dictionary];
    [outputVideoSettings setObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id) kCVPixelBufferPixelFormatTypeKey];
    _dataOutputVideo.videoSettings = outputVideoSettings;
    [_dataOutputVideo setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
    
    // セッションの作成 データの流れを調整
    _session = [[AVCaptureSession alloc] init];
    [_session addInput:deviceInput];
    [_session addOutput:_dataOutputImage];
    [_session addOutput:_dataOutputVideo];
    // 解像度の指定　AVCaptureSessionPreset1280x720だとフロントカメラで落ちる
    _session.sessionPreset = AVCaptureSessionPresetPhoto;
    
    // gestureの登録
    UIGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapGesture:)];
    gesture.delegate = self;
    [self.touchView addGestureRecognizer:gesture];
    
    // フォーカスした時の枠
    _focusView = [[UIView alloc] init];
    CGRect focusViewFrame = _focusView.frame;
    focusViewFrame.size.width = FOCUS_LAYER_RECT_SIZE;
    focusViewFrame.size.height = FOCUS_LAYER_RECT_SIZE;
    _focusView.frame = focusViewFrame;
    _focusView.center = CGPointMake(160, 202);
    CALayer *layer = _focusView.layer;
    layer.shadowOffset = CGSizeMake(2.5, 2.5);
    layer.shadowColor = [UIColor blackColor].CGColor;
    layer.shadowOpacity = 0.5;
    layer.borderWidth = 2;
    layer.borderColor = [UIColor yellowColor].CGColor;
    [self.touchView addSubview:_focusView];
    _focusView.alpha = 0;
    
    // フラッシュしない
    _isShowFlash = NO;
    
    // 各viewを前面に持ってくる
    [self.view bringSubviewToFront:self.touchView];
    [self.view bringSubviewToFront:self.footerView];
    [self.view bringSubviewToFront:self.headerView];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [_session stopRunning];
    
}
-(void)viewWillDisapper:(BOOL)animated{
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarHidden = NO;
    self.navigationController.navigationBar.hidden = NO;
    //    self.navigationController.navigationBar.tintColor = [UIColor colorWithHex:0xa5cacc];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"戻る" style:UIBarButtonItemStyleBordered target:nil action:nil];
}
-(void)viewDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarHidden = NO;
    self.navigationController.navigationBar.hidden = NO;
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"戻る" style:UIBarButtonItemStyleBordered target:nil action:nil];
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [_session stopRunning];
}
-(void)didTapGesture:(UITapGestureRecognizer *)tapGestureRecognizer{
    _layerHideCount++;
    CGPoint point = [tapGestureRecognizer locationInView:tapGestureRecognizer.view];
    [_focusView.layer removeAllAnimations];
    
    _focusView.alpha = 0.1;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView setAnimationDidStopSelector:@selector(startupAnimationCone)];
    _focusView.alpha = 1;
    _focusView.frame = CGRectMake(point.x - FOCUS_LAYER_RECT_SIZE / 2.f,point.y - FOCUS_LAYER_RECT_SIZE / 2.f,FOCUS_LAYER_RECT_SIZE,FOCUS_LAYER_RECT_SIZE);
    [self setPoint:point];
    [UIView commitAnimations];
    
}
-(void)startupAnimationDone{
    if(_layerHideCount > 1){
        _layerHideCount--;
        return;
    }
    [UIView  beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    _focusView.alpha = 0;
    [UIView commitAnimations];
    
    _layerHideCount--;
}


- (void)setPoint:(CGPoint)point
{
    CGSize viewSize = self.view.bounds.size;
    CGPoint pointOfInterest = CGPointMake(point.y / viewSize.height, 1.0 - point.x / viewSize.width);
    
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    NSError *error = nil;
    if ([captureDevice lockForConfiguration:&error]) {
        if ([captureDevice isFocusPointOfInterestSupported] && [captureDevice isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
            captureDevice.focusPointOfInterest = pointOfInterest;
            captureDevice.focusMode = AVCaptureFocusModeAutoFocus;
        }
        
        if ([captureDevice isExposurePointOfInterestSupported] && [captureDevice isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
            captureDevice.exposurePointOfInterest = pointOfInterest;
            captureDevice.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
        }
        
        [captureDevice unlockForConfiguration];
    }
}
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            return device;
        }
    }
    return nil;
}

- (void)swapFrontAndBackCameras
{
    NSArray *inputs = _session.inputs;
    for (AVCaptureDeviceInput *input in inputs) {
        AVCaptureDevice *device = input.device;
        
        if ([device hasMediaType :AVMediaTypeVideo]) {
            AVCaptureDevicePosition position = device.position;
            AVCaptureDevice *newCamera;
            AVCaptureDeviceInput *newInput;
            
            if (position == AVCaptureDevicePositionFront) {
                newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
                newInput = [AVCaptureDeviceInput deviceInputWithDevice:newCamera error:nil];
                self.flashButton.hidden = NO;
            } else {
                newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
                newInput = [AVCaptureDeviceInput deviceInputWithDevice:newCamera error:nil];
                self.flashButton.hidden = YES;
            }
            
            // beginConfiguration ensures that pending changes are not applied immediately
            [_session beginConfiguration];
            
            [_session removeInput :input];
            [_session addInput :newInput];
            
            // Changes take effect once the outermost commitConfiguration is invoked.
            [_session commitConfiguration];
            break;
        }
    }
}

-(void)addAnimation{
    // もし上のシャッターがなかったら
    if (!self.shutterUpper) {
        // shutterUpperを作ります
        CALayer *shutterUpper = [CALayer layer];
        
        // shutterUpperの位置と大きさを決めます
        shutterUpper.frame = CGRectMake(0, 0, self.previewImage.frame.size.width, self.previewImage.frame.size.height / 2);
        
        // 上のシャッターの背景色を黒にします
        shutterUpper.backgroundColor = [UIColor blackColor].CGColor;
        
        // プレビュー画面にshutterUppweを貼り付けます
        [self.previewImage.layer addSublayer:shutterUpper];
        self.shutterUpper = shutterUpper;
        
        // 下のシャッターを作ります
        CALayer *shutterLower = [CALayer layer];
        
        // 位置と大きさを決めます
        shutterLower.frame = CGRectMake(0, 0, self.previewImage.frame.size.width, self.previewImage.frame.size.height / 2);
        // 下のシャッターの背景色を黒にします
        shutterLower.backgroundColor = [UIColor blackColor].CGColor;
        
        // previewImageに下のシャッターを貼り付けます
        [self.previewImage.layer addSublayer:shutterLower];
        self.shutterLower = shutterLower;
    } else {
        self.shutterUpper.hidden = NO;
        self.shutterLower.hidden = NO;
    }
    
    /*************************
     上部シャッターアニメーション
     ************************/
    CABasicAnimation *animation1 = [CABasicAnimation animationWithKeyPath:@"position"];
    animation1.delegate = self;
    
    CGPoint finishPoint1 = CGPointMake(self.previewImage.center.x, self.previewImage.frame.origin.y - self.shutterUpper.frame.size.height);
    self.shutterUpper.position = finishPoint1;  //終了位置をあらかじめセット
    
    animation1.fromValue = [NSValue valueWithCGPoint:CGPointMake(self.previewImage.center.x, self.previewImage.frame.origin.y - self.shutterUpper.frame.size.height)];
    animation1.toValue = [NSValue valueWithCGPoint:CGPointMake(self.previewImage.center.x, self.previewImage.frame.origin.y + (self.shutterUpper.frame.size.height / 2))];
    
    // 0.1秒かけてアニメーションさせます
    animation1.duration = .1;
    // 1回だけ繰り返します
    animation1.repeatCount = 1;
    // 自動でアニメーションを戻します
    animation1.autoreverses = YES;
    // アニメーションの開始時間を0.5秒遅らせます
    animation1.beginTime = CACurrentMediaTime() + 0.5;
    
    // 設定したアニメーションを動作させます
    [self.shutterUpper addAnimation:animation1 forKey:@"move"];
    
    
    /*************************
     下部シャッターアニメーション
     ************************/
    CABasicAnimation *animation2 = [CABasicAnimation animationWithKeyPath:@"position"];
    animation2.autoreverses = YES;
    
    CGPoint finishPoint2 = CGPointMake(self.previewImage.center.x, self.previewImage.frame.size.height + (self.shutterLower.frame.size.height/ 2));
    self.shutterLower.position = finishPoint2;  //終了位置をあらかじめセット
    
    animation2.fromValue = [NSValue valueWithCGPoint:CGPointMake(self.previewImage.center.x, self.previewImage.frame.size.height + (self.shutterLower.frame.size.height/ 2))];
    animation2.toValue = [NSValue valueWithCGPoint:CGPointMake(self.previewImage.center.x, self.previewImage.frame.size.height - (self.shutterLower.frame.size.height/ 2))];
    
    animation2.duration = .1;
    animation2.repeatCount = 1;
    animation2.beginTime = CACurrentMediaTime() + 0.5;
    [self.shutterLower addAnimation:animation2 forKey:@"move"];
}

# pragma CAAnimation Delegate

// アニメーションが終わった時を取得します
- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
    // シャッターを隠します
    self.shutterUpper.hidden = YES;
    self.shutterLower.hidden = YES;
}

// カメラで撮影するアクション
- (IBAction)captureAction:(id)sender
{
    // 動画をとっている一部を切り取るように、画像を切り取ります
    [self addAnimation];
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in _dataOutputImage.connections) {
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo]) {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) {
            break;
        }
    }
    
    __weak CameraViewController *__self = self;
    [_dataOutputImage captureStillImageAsynchronouslyFromConnection:videoConnection
                                                  completionHandler:^(CMSampleBufferRef imageSampleBuffer, NSError *error){
                                                      if (imageSampleBuffer == NULL) {
                                                          return;
                                                      }
                                                      
                                                      // キャプチャしたデータをとる
                                                      NSData *data = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
                                                      // 押されたボタンにキャプチャした静止画を設定する
                                                      UIImage *originalImage = [[UIImage alloc] initWithData:data];
                                                      UIImage *croppedImage = [self trimmingImage:originalImage.CGImage height:originalImage.size.height width:originalImage.size.width];
                                                      // 反転させる
                                                      // MARK: 反転解除
                                                      UIImage *image = [UIImage imageWithCGImage:croppedImage.CGImage scale:1.0f orientation:UIImageOrientationRight];
                                                      
                                                      //ALAssetLibraryのインスタンス作成
                                                      _library = [[ALAssetsLibrary alloc] init];
                                                      _albumName = @"baby365";
                                                      _albumWasFound = FALSE;
                                                      //アルバムを検索してなかったら新規作成、あったらアルバムのURLを保持
                                                      [_library enumerateGroupsWithTypes:ALAssetsGroupAlbum usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                                                          if (group) {
                                                              if ([_albumName compare:[group valueForProperty:ALAssetsGroupPropertyName]] == NSOrderedSame) {
                                                                  //URLをクラスインスタンスに保持
                                                                  _groupURL = [group valueForProperty:ALAssetsGroupPropertyURL];
                                                                  _albumWasFound = TRUE;
                                                                  // MARK: image -> croppedImage
                                                                  [__self saveAsset:image];
                                                              }
                                                              //アルバムがない場合は新規作成
                                                          } else if (_albumWasFound==FALSE) {
                                                              ALAssetsLibraryGroupResultBlock resultBlock = ^(ALAssetsGroup *group) {
                                                                  _groupURL = [group valueForProperty:ALAssetsGroupPropertyURL];
                                                                  // MARK: image -> croppedImage
                                                                  [__self saveAsset:image];
                                                              };
                                                              
                                                              //新しいアルバムを作成
                                                              [_library addAssetsGroupAlbumWithName:_albumName resultBlock:resultBlock failureBlock: nil];
                                                              _albumWasFound = TRUE;
                                                          }
                                                          
                                                      } failureBlock:nil];
                                                  }];
}

// クロップするメソッド
// via http://qiita.com/items/3ad3aa92024b4f7401cd
- (UIImage *)trimmingImage:(CGImageRef)image height:(float)height width:(float)width {
    // トリミング
    // 高さを幅にすることで正方形にしている
    CGImageRef cgImage = CGImageCreateWithImageInRect(image, CGRectMake(0, 0, width, width));
    float scale = [[UIScreen mainScreen] scale];
    UIImage *trimImg = [UIImage imageWithCGImage:cgImage scale:scale orientation:UIImageOrientationRight];
    CGImageRelease(cgImage);
    
    return trimImg;
}

// 画像を保存するメソッド
- (void)saveAsset:(UIImage *)image
{
    if (image) {
        //カメラロールにUIImageを保存する。保存完了後、completionBlockで「NSURL* assetURL」が取得できる
        [_library writeImageToSavedPhotosAlbum:image.CGImage orientation:(ALAssetOrientation)image.imageOrientation completionBlock:^(NSURL* assetURL, NSError* error) {
            //アルバムにALAssetを追加するメソッド
            [self addAssetURL:assetURL AlbumURL:_groupURL];
            
            //            BACreateDiaryController *controller = [BACreateDiaryController instantiateViewControllerFromMainStoryboard];
            //            controller.editedImage =  image;
            //            [self.navigationController pushViewController:controller animated:YES];
        }];
    }
}

//アルバムにALAssetを追加するメソッド
- (void)addAssetURL:(NSURL*)assetURL AlbumURL:(NSURL *)albumURL{
    
    //URLからGroupを取得
    [_library groupForURL:albumURL resultBlock:^(ALAssetsGroup *group){
        //URLからALAssetを取得
        [_library assetForURL:assetURL resultBlock:^(ALAsset *asset) {
            if (group.editable) {
                //GroupにAssetを追加
                [group addAsset:asset];
            }
            
        } failureBlock: nil];
    } failureBlock:nil];
}


- (IBAction)closeAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

- (IBAction)flashAction:(id)sender {
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    NSError *error = nil;
    if ([captureDevice lockForConfiguration:&error]) {
        
        // ライト
        if (_isShowFlash) {
            if ([captureDevice isFlashModeSupported:AVCaptureFlashModeOff]) {
                [captureDevice setTorchMode:AVCaptureTorchModeOff];
                [captureDevice setFlashMode:AVCaptureFlashModeOff];
            }
            
            // 画像を切替えるなどの処理
            [self.flashButton setTitle:@"オフ" forState:UIControlStateNormal];
            
            
            [sender setSelected:NO];
            
            _isShowFlash = NO;
        } else {
            if ([captureDevice isFlashModeSupported:AVCaptureFlashModeAuto]) {
                [captureDevice setTorchMode:AVCaptureTorchModeOn];
                [captureDevice setFlashMode:AVCaptureFlashModeOn];
            }
            
            // 画像を切替えるなどの処理
            [self.flashButton setTitle:@"オン" forState:UIControlStateNormal];
            
            [sender setSelected:YES];
            
            _isShowFlash = YES;
        }
        
        [captureDevice unlockForConfiguration];
    }
}

- (IBAction)cameraPositionChangeAction:(id)sender {
    [self swapFrontAndBackCameras];
}


# pragma GestureDelegate

// ここでtouchしたのがViewなのかUIControlなのか判定している
// これをしないとUIViewに配置したUIButtonなどが反応しなくなる
// via http://stackoverflow.com/questions/3344341/uibutton-inside-a-view-that-has-a-uitapgesturerecognizer
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    // via http://stackoverflow.com/questions/3344341/uibutton-inside-a-view-that-has-a-uitapgesturerecognizer
    if ([touch.view isKindOfClass:[UIControl class]]) {
        // we touched a button, slider, or other UIControl
        return NO; // ignore the touch
    }
    return YES; // handle the touch
}


# pragma ImagePickerDelegate


# pragma AVCaptureDelegate

// AVCaptureStillImageOutput delegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    // イメージバッファの取得
    CVImageBufferRef buffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    
    // イメージバッファのロック
    CVPixelBufferLockBaseAddress(buffer, 0);
    
    // イメージバッファ情報取得
    uint8_t *base = CVPixelBufferGetBaseAddress(buffer);
    size_t width = CVPixelBufferGetWidth(buffer);
    size_t height = CVPixelBufferGetHeight(buffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(buffer);
    
    
    // ビットマップコンテキストの作成
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef cgContext = CGBitmapContextCreate(base, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    
    // 画像の作成
    CGImageRef cgImage = CGBitmapContextCreateImage(cgContext);
    
    // 反転させる
    UIImage *image = [UIImage imageWithCGImage:cgImage scale:1.f orientation:UIImageOrientationRight];
    image = [self trimmingImage:image.CGImage height:image.size.height width:image.size.width];
    
    // イメージバッファのアンロック
    CVPixelBufferUnlockBaseAddress(buffer, 0);
    
    
    sourcePicture = [[GPUImagePicture alloc] initWithImage:image smoothlyScaleOutput:YES];
    //    sepiaFilter = [[GPUImageTiltShiftFilter alloc] init];
    sepiaFilter = [[GPUImageSobelEdgeDetectionFilter alloc] init];
    
    GPUImageView *imageView = (GPUImageView *)self.previewImage;
    //    [sepiaFilter forceProcessingAtSize:imageView.sizeInPixels]; // This is now needed to make the filter run at the smaller output size
    
    [sourcePicture addTarget:sepiaFilter];
    [sepiaFilter addTarget:imageView];
    
    [sourcePicture processImage];
    
    
    
    //    // 画像の表示
    //    GPUImagePicture *imagePicture = [[GPUImagePicture alloc] initWithImage:image];
    //
    //    // コントラストフィルター
    //    GPUImageContrastFilter *contrastFilter = [[GPUImageContrastFilter alloc] init];
    //    // コントラストを設定する。コントラストは0~4の間の値で、1が普通
    //    [contrastFilter setContrast:4];
    //
    //    // 画像 → コントラストフィルターをつなげる
    //    [imagePicture addTarget:contrastFilter];
    //
    //    // コントラストフィルター → imageViewをつなげる
    //    [contrastFilter addTarget:self.filterImage];
    //
    //    // フィルター実行！
    //    [imagePicture processImage];
    
    //    self.previewImage.image = image;
    
    
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(cgImage);
    CGContextRelease(cgContext);
}
@end