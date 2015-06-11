//
//  DropDownListView.m
//  KDropDownMultipleSelection
//
//  Created by Agilsun on 03/01/14.
//  Copyright (c) 2014 Agilsun. All rights reserved.
//

#import "AGSDropDownListView.h"
#import "AGSDropDownCell.h"

#define DROPDOWNVIEW_HEADER_HEIGHT 50
#define RADIUS 0

#define IMAGE_CHECK_TAG     1000

@interface AGSDropDownListView ()

@property (strong, nonatomic) UIButton *buttonDone; // for multiple selection
@property (strong, nonatomic) UILabel *labelTitle;

@property (strong, nonatomic) UIView *viewSearchBar;
@property (strong, nonatomic) UITextField *textFieldSearch;

- (void)fadeIn;
- (void)fadeOut;

@end

@implementation AGSDropDownListView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithTitle:(NSString *)title
            options:(NSArray *)options
              frame:(CGRect)rect
         isMultiple:(BOOL)isMultiple
          canSearch:(BOOL)isSearching
{
    isMultipleSelection = isMultiple;
    canSearch = isSearching;
    
    if (self = [super initWithFrame:rect])
    {
        self.backgroundColor = [UIColor clearColor];
        _kTitleText = [title copy];
        _kDropDownOptions = [options copy];
        _options = _kDropDownOptions;
        self.selectedIndexes = [[NSMutableArray alloc]init];
        
        _kTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,
                                                                   DROPDOWNVIEW_HEADER_HEIGHT,
                                                                   rect.size.width,
                                                                   rect.size.height - DROPDOWNVIEW_HEADER_HEIGHT - RADIUS)];
        
        _kTableView.separatorColor = [UIColor colorWithWhite:1 alpha:.2];
        _kTableView.backgroundColor = [UIColor clearColor];
        _kTableView.dataSource = self;
        _kTableView.delegate = self;
        [self addSubview:_kTableView];
        
        if (isMultipleSelection) {
            [self.buttonDone setFrame:CGRectMake(rect.size.width - 90, 4, 82, 36)];
            [self addSubview:self.buttonDone];
        }
        
        CGFloat offset = isMultipleSelection ? 98 : 0;
        
        if (canSearch) {
            self.viewSearchBar.frame = CGRectMake(10, 8, rect.size.width - 20 - offset, DROPDOWNVIEW_HEADER_HEIGHT - 16);
            [self addSubview:self.viewSearchBar];
            
            self.textFieldSearch.frame = CGRectMake(8, 0, self.viewSearchBar.frame.size.width - 16, DROPDOWNVIEW_HEADER_HEIGHT - 16);
            [self.viewSearchBar addSubview:self.textFieldSearch];
        }
        else {
            self.labelTitle.frame = CGRectMake(10, 0, rect.size.width - 20 - offset, DROPDOWNVIEW_HEADER_HEIGHT);
            [self addSubview:self.labelTitle];
        }
    }
    
    return self;
}

- (id)initWithTitle:(NSString *)title
              objects:(NSArray *)objects
        attributeName:(NSString *)attributeName
       attributeImage:(NSString *)attributeImage
                frame:(CGRect)rect
           isMultiple:(BOOL)isMultiple
            canSearch:(BOOL)isSearching
{
    self = [super initWithFrame:rect];
    self.attributeName = attributeName;
    self.attributeImage = attributeImage;

    isShowFromListObjects = YES;
    
    if (self) {
        self = [self initWithTitle:title options:objects frame:rect isMultiple:isMultiple canSearch:isSearching];
    }
    
    return self;
}

- (void)buttonDoneClicked:(id)sender
{
    if (self.delegate
        && [self.delegate respondsToSelector:@selector(dropDownListView:didSelectIndexList:)]) {
        NSMutableArray *arryResponceData = [[NSMutableArray alloc]init];
        
        for (int k = 0; k < self.selectedIndexes.count; k++) {
            NSNumber *index = [self.selectedIndexes objectAtIndex:k];
            [arryResponceData addObject:index];
        }
        
        arryResponceData = [[arryResponceData sortedArrayUsingComparator:^NSComparisonResult(NSNumber *obj1, NSNumber *obj2) {
            return [obj1 compare:obj2];
        }] mutableCopy];
        
        NSLog(@"%@", arryResponceData);
        
        [self.delegate dropDownListView:self didSelectIndexList:arryResponceData];
    }
    
    // dismiss self
    [self fadeOut];
}

#pragma mark - Constructor

- (UILabel *)labelTitle
{
    if (!_labelTitle) {
        _labelTitle = [[UILabel alloc] init];
        _labelTitle.backgroundColor = [UIColor clearColor];
        _labelTitle.textColor = [UIColor whiteColor];
        _labelTitle.text = _kTitleText;
    }
    
    return _labelTitle;
}

- (UIButton *)buttonDone
{
    if (!_buttonDone) {
        _buttonDone = [UIButton  buttonWithType:UIButtonTypeCustom];
        
        [_buttonDone setImage:[UIImage imageNamed:@"done@2x.png"]
                     forState:UIControlStateNormal];
        _buttonDone.titleLabel.font = [UIFont boldSystemFontOfSize:13];
        [_buttonDone addTarget:self
                        action:@selector(buttonDoneClicked:)
              forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _buttonDone;
}

- (UIView *)viewSearchBar
{
    if (!_viewSearchBar) {
        _viewSearchBar = [[UIView alloc] init];
        _viewSearchBar.backgroundColor = [UIColor whiteColor];
        
        _viewSearchBar.layer.cornerRadius = 3;
        _viewSearchBar.layer.masksToBounds = YES;
    }
    
    return _viewSearchBar;
}

- (UITextField *)textFieldSearch
{
    if (!_textFieldSearch) {
        _textFieldSearch = [[UITextField alloc] init];
        _textFieldSearch.backgroundColor = [UIColor clearColor];
        _textFieldSearch.placeholder = @"Search";
        _textFieldSearch.delegate = self;
        
        [_textFieldSearch addTarget:self action:@selector(textFieldSearchEditingChanged:) forControlEvents:UIControlEventEditingChanged];
    }
    
    return _textFieldSearch;
}

#pragma mark - Text field delegate

- (void)textFieldSearchEditingChanged:(UITextField *)textField
{
    if (textField.text.length > 0) {
        self.options = [self filtOptionsByKeywork:textField.text];
    }
    else {
        self.options = _kDropDownOptions;
    }
    
    [self reloadData];
}

- (NSArray *)filtOptionsByKeywork:(NSString *)keyword
{
    NSMutableArray *result = [@[] mutableCopy];
    
    for (id object in _kDropDownOptions) {
        NSString *value = object;
        if (isShowFromListObjects) {
            value = [object valueForKeyPath:_attributeName];
        }
        
        if ([[value lowercaseString] containsString:[keyword lowercaseString]]) {
            [result addObject:object];
        }
    }
    
    return [NSArray arrayWithArray:result];
}

#pragma mark - Fade in / Fade out

- (void)fadeIn
{
    self.textFieldSearch.text = @"";
    self.options = _kDropDownOptions;
    [self reloadData];
    
    self.transform = CGAffineTransformMakeScale(1.3, 1.3);
    self.alpha = 0;
    [UIView animateWithDuration:.35 animations:^{
        self.alpha = 1;
        self.transform = CGAffineTransformMakeScale(1, 1);
    }];
}

- (void)fadeOut
{
    [UIView animateWithDuration:.35 animations:^{
        self.transform = CGAffineTransformMakeScale(1.3, 1.3);
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (finished) {
            [self removeFromSuperview];
        }
    }];
}

#pragma mark - Instance Methods

- (void)showInView:(UIView *)aView animated:(BOOL)animated
{
    [aView addSubview:self];
    if (animated) {
        [self fadeIn];
    }
}

#pragma mark - Tableview datasource & delegates

- (void)reloadData
{
    [_kTableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_options count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentity = @"DropDownViewCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentity];
    cell = [[AGSDropDownCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentity];
    
    UIView *view = [cell.contentView viewWithTag:IMAGE_CHECK_TAG];
    [view removeFromSuperview];
    
    NSInteger row = [indexPath row];
    UIImageView *imgarrow = [[UIImageView alloc]init ];
    imgarrow.tag = IMAGE_CHECK_TAG;
    
    if([self.selectedIndexes containsObject:@(row)]){
        imgarrow.frame = CGRectMake(self.frame.size.width - 35,15, 20, 20);
        imgarrow.image = [UIImage imageNamed:@"check_mark@2x.png"];
    }
    else {
        imgarrow.image = nil;
    }
    
    [cell.contentView addSubview:imgarrow];
    
    if (isShowFromListObjects) {
        id object = [_options objectAtIndex:row];
        cell.textLabel.text = [object valueForKeyPath:_attributeName];
        
        NSString *imageName = [object valueForKeyPath:_attributeImage];
        cell.imageView.image = [self scaleImage:[UIImage imageNamed:imageName] toSize:CGSizeMake(30, 30)];
    }
    else {
        cell.textLabel.text = [_options objectAtIndex:row];
        cell.imageView.image = nil;
    }
    
    /**
     *  Image
     */
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSNumber *row = [NSNumber numberWithInteger:indexPath.row];
    
    if (isMultipleSelection) {
        if([self.selectedIndexes containsObject:row]) {
            [self.selectedIndexes removeObject:row];
        } else {
            [self.selectedIndexes addObject:row];
        }
        [tableView reloadData];
    }
    else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(dropDownListView:didSelectedIndex:)]) {
            [self.delegate dropDownListView:self didSelectedIndex:[indexPath row]];
        }
        // dismiss self
        [self fadeOut];
    }
	
}

- (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)newSize
{
    UIGraphicsBeginImageContextWithOptions(newSize, NO, [UIScreen mainScreen].scale);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark - TouchTouchTouch
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    // tell the delegate the cancellation
    
}

#pragma mark - DrawDrawDraw

- (void)drawRect:(CGRect)rect
{
    CGRect bgRect = CGRectInset(rect, 0, 0);
    CGRect separatorRect = CGRectMake(0, DROPDOWNVIEW_HEADER_HEIGHT - 2,
                                      rect.size.width, 2);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    [color setFill];
    
    float x = 0;
    float y = 0;
    float width = bgRect.size.width;
    float height = bgRect.size.height;
    CGMutablePathRef path = CGPathCreateMutable();
	CGPathMoveToPoint(path, NULL, x, y + RADIUS);
	CGPathAddArcToPoint(path, NULL, x, y, x + RADIUS, y, RADIUS);
	CGPathAddArcToPoint(path, NULL, x + width, y, x + width, y + RADIUS, RADIUS);
	CGPathAddArcToPoint(path, NULL, x + width, y + height, x + width - RADIUS, y + height, RADIUS);
	CGPathAddArcToPoint(path, NULL, x, y + height, x, y + height - RADIUS, RADIUS);
	CGPathCloseSubpath(path);
	CGContextAddPath(ctx, path);
    CGContextFillPath(ctx);
    CGPathRelease(path);
    
    [[UIColor colorWithWhite:1 alpha:1.] setFill];
    CGContextFillRect(ctx, separatorRect);
}

- (void)setBackgroundDropDown:(UIColor *)aColor
{
    color = aColor;
}

@end
