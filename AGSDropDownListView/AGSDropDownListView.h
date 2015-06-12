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

@interface AGSDropDownListView : UIView<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>{
    UITableView *_kTableView;
    NSString *_kTitleText;
    NSArray *_kDropDownOptions;
    UIColor *color;
    BOOL isMultipleSelection;
    BOOL canSearch;
    BOOL isShowFromListObjects;
}

#define DROPDOWNVIEW_HEADER_HEIGHT 50

@property (strong, nonatomic) NSArray *options;
@property (strong, nonatomic) NSString *attributeName;
@property (strong, nonatomic) NSString *attributeImage;

@property (nonatomic, strong) NSMutableArray *selectedIndexes;
@property (nonatomic, assign) id<AGSDropDownListViewDelegate> delegate;

// reload data
- (void)reloadData;

// fade out to hide drop down
- (void)fadeOut;

// The options is a NSArray, contain some NSDictionaries, the NSDictionary contain 2 keys, one is "img", another is "text".
- (id)initWithTitle:(NSString *)title
            options:(NSArray *)options
              frame:(CGRect)rect
         isMultiple:(BOOL)isMultiple
          canSearch:(BOOL)isSearching;

- (id)initWithTitle:(NSString *)title
            objects:(NSArray *)objects
      attributeName:(NSString *)attributeName
     attributeImage:(NSString *)attributeImage
              frame:(CGRect)rect
         isMultiple:(BOOL)isMultiple
          canSearch:(BOOL)isSearching;

// If animated is YES, PopListView will be appeared with FadeIn effect.
- (void)showInView:(UIView *)aView animated:(BOOL)animated;

// set background color
- (void)setBackgroundDropDown:(UIColor *)aColor;

@end

@protocol AGSDropDownListViewDelegate <NSObject>

- (void)dropDownListView:(AGSDropDownListView *)dropdownListView didSelectedIndex:(NSInteger)anIndex;
- (void)dropDownListView:(AGSDropDownListView *)dropdownListView didSelectIndexList:(NSMutableArray*)indexes;

@end
