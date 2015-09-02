//
//  KaouViewController.m
//  camera
//
//  Created by TomokoTakahashi on 2015/08/24.
//  Copyright (c) 2015年 高橋知子. All rights reserved.
//

#import "KaouViewController.h"

@interface KaouViewController ()

@end

@implementation KaouViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    imageView.image = self.passedImage;
    imageView.userInteractionEnabled = YES;
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panImage:)];
    [imageView addGestureRecognizer:panGestureRecognizer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)panImage:(UIPanGestureRecognizer *)sender {
    CGPoint posNow = sender.view.center;
    CGPoint posMow = [sender translationInView:self.view];
    sender.view.center = CGPointMake(posNow.x + posMow.x, posNow.y + posMow.y);
    [sender setTranslation:CGPointZero inView:self.view];
}

- (IBAction)pinchImage:(UIPinchGestureRecognizer *)sender {
    sender.view.transform = CGAffineTransformMakeScale(sender.scale, sender.scale);
}

- (IBAction)rotationImage:(UIRotationGestureRecognizer *)sender {
    sender.view.transform = CGAffineTransformMakeRotation(sender.rotation);
}
#import "KaouViewController.h"




@synthesize sl, lb;

//- (void)dealloc {
//    [sl release];
//    [lb release];
//    [super dealloc];
//}

- (IBAction)SliderChanged:(id)sender {
    
    NSLog(@"スライダーの値が変わりました");
    
    //スライダーの現在値を取得
    float v = 0;
    v = sl.value;
    
    //ラベルに現在値を表示
    lb.text = [NSString stringWithFormat:@"%2.f",v];
}


@end
