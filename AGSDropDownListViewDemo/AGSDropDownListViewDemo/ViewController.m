//
//  ViewController.m
//  AGSDropDownListViewDemo
//
//  Created by Ngoc Nhan Nguyen on 6/7/15.
//  Copyright (c) 2015 Ngoc Nhan Nguyen. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIButton *buttonShowDropDown;
@property (weak, nonatomic) IBOutlet UILabel *labelResult;

@property (strong, nonatomic) AGSDropDownListView *dropDownListView;
@property (nonatomic) BOOL isShowingDropDown;

@property (strong, nonatomic) NSArray *options;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.options = @[@"Apple",
                     @"Google",
                     @"Samsung",
                     @"Sony",
                     @"LG",
                     @"HTC"];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];

    if (self.isShowingDropDown) {
        [self.dropDownListView fadeOut];
        self.isShowingDropDown = NO;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (AGSDropDownListView *)dropDownListView
{
    if (!_dropDownListView) {
        CGFloat height = self.options.count * 50 + 44;
        
        CGRect frameButton = self.buttonShowDropDown.frame;
        CGRect frame = CGRectMake(frameButton.origin.x, frameButton.origin.y + frameButton.size.height + 20, frameButton.size.width, height);
        
        _dropDownListView = [[AGSDropDownListView alloc] initWithTitle:@"Choose brand" options:self.options frame:frame isMultiple:NO];
        _dropDownListView.delegate = self;
    }
    
    return _dropDownListView;
}

- (IBAction)buttonShowDropDownClicked:(id)sender
{
    if (self.isShowingDropDown) {
        [self.dropDownListView fadeOut];
        self.isShowingDropDown = NO;
        return;
    }
    else {
        [self.dropDownListView showInView:self.view animated:YES];
        self.isShowingDropDown = YES;
    }
}

#pragma mark - Drop down list delegate

- (void)dropDownListView:(AGSDropDownListView *)dropdownListView didSelectedIndex:(NSInteger)anIndex
{
    self.isShowingDropDown = NO;

    NSString *resultString = [self.options objectAtIndex:anIndex];
    self.labelResult.text = resultString;
}

- (void)dropDownListView:(AGSDropDownListView *)dropdownListView didSelectIndexList:(NSMutableArray *)indexes
{
    
}

@end
