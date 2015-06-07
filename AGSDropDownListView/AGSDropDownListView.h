//
//  DropDownListView.h
//  KDropDownMultipleSelection
//
//  Created by Agilsun on 03/01/14.
//  Copyright (c) 2014 Agilsun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol AGSDropDownListViewDelegate;

@interface AGSDropDownListView : UIView<UITableViewDataSource,UITableViewDelegate>{
    UITableView *_kTableView;
    NSString *_kTitleText;
    NSArray *_kDropDownOptions;
    UIColor *color;
    BOOL isMultipleSelection;
}

@property (nonatomic, strong) NSMutableArray *selectedIndexes;
@property (nonatomic, strong) NSArray *imageNames;
@property (nonatomic, assign) id<AGSDropDownListViewDelegate> delegate;

// reload data
- (void)reloadData;

// fade out to hide drop down
- (void)fadeOut;

// The options is a NSArray, contain some NSDictionaries, the NSDictionary contain 2 keys, one is "img", another is "text".
- (id)initWithTitle:(NSString *)title
            options:(NSArray *)options
              frame:(CGRect)rect
         isMultiple:(BOOL)isMultiple;

- (id)initWithTitle:(NSString *)title
            objects:(NSArray *)objects
      attributeName:(NSString *)attributeName
              frame:(CGRect)rect
         isMultiple:(BOOL)isMultiple;

// If animated is YES, PopListView will be appeared with FadeIn effect.
- (void)showInView:(UIView *)aView animated:(BOOL)animated;

// set background color
- (void)setBackgroundDropDown:(UIColor *)aColor;

@end

@protocol AGSDropDownListViewDelegate <NSObject>

- (void)dropDownListView:(AGSDropDownListView *)dropdownListView didSelectedIndex:(NSInteger)anIndex;
- (void)dropDownListView:(AGSDropDownListView *)dropdownListView didSelectIndexList:(NSMutableArray*)indexes;

@optional
- (void)dropDownListViewDidCancel;

@end
