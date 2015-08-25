//
//  ArrangeViewController.m
//  camera
//
//  Created by TomokoTakahashi on 2015/08/23.
//  Copyright (c) 2015年 高橋知子. All rights reserved.
//

#import "ArrangeViewController.h"

@interface ArrangeViewController ()

@end

@implementation ArrangeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    showImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 10, 310, 310)];
    showImageView.image = [UIImage imageNamed:@"base.png"];
    [self.view addSubview:showImageView];
    currentStampView = nil;
    _isPressStamp = NO;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch* touch = [touches anyObject];
    CGPoint point = [touch locationInView:showImageView];
    currentStampView = [[UIImageView alloc]
                        initWithFrame:CGRectMake(point.x-30,point.y-30,60,60)];
    currentStampView.image = [UIImage imageNamed:@"orafu.png"];
    [self.view addSubview:currentStampView];
    _isPressStamp = YES;

}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)eventnt {
    UITouch* touch = [touches anyObject];
    CGPoint point = [touch locationInView:showImageView];
    if (_isPressStamp){
        currentStampView.frame = CGRectMake(point.x-30, point.y-30, 60, 60);
        
    }
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    _isPressStamp = NO;
}
-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    _isPressStamp = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
