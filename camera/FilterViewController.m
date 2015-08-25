//
//  FilterViewController.m
//  camera
//
//  Created by TomokoTakahashi on 2015/06/17.
//  Copyright (c) 2015年 高橋知子. All rights reserved.
//

#import "FilterViewController.h"

@interface FilterViewController ()

@end

@implementation FilterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    imageView.image = self.image;
    imageView.userInteractionEnabled = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(IBAction)panImage:(UIPanGestureRecognizer *)sender{
    CGPoint posNow = sender.view.center;
    CGPoint posMow = [sender translationInView:self.view];
    sender.view.center = CGPointMake(posNow.x + posMow.x,
                                     posNow.y + posMow.y);
    [sender setTranslation:CGPointZero inView:self.view];
}

-(IBAction)PinchImage:(UIPinchGestureRecognizer *)sender{
    sender.view.transform =
    CGAffineTransformMakeScale(sender.scale, sender.scale);
}

-(IBAction)RotationImage:(UIRotationGestureRecognizer *)sender {
    sender.view.transform =
    CGAffineTransformMakeRotation(sender.rotation);
}

-(IBAction)getScreenshotImage{
    CGRect rect = [[UIScreen mainScreen] bounds];
    UIGraphicsBeginImageContext(rect.size);
    
    UIApplication *app = [UIApplication sharedApplication];
    [app.keyWindow.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    CGRect trimArea = CGRectMake(1, boarderView.frame.origin.y + 1, boarderView.frame.size.width - 2, boarderView.frame.size.height - 2);
    CGImageRef srcImageRef = [img CGImage];
    CGImageRef trimmedImageRef = CGImageCreateWithImageInRect(srcImageRef, trimArea);
    UIImage *trimmedImage = [UIImage imageWithCGImage:trimmedImageRef];
    
    UIGraphicsGetImageFromCurrentImageContext();
    UIImageWriteToSavedPhotosAlbum(trimmedImage, self, @selector(onCompleate:didFinishSavingWithError:contextInfo:), nil);
}

-(void)onCompleate:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void*)contextInfo{
    NSLog(@"画面キャプチャー完了");
}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
