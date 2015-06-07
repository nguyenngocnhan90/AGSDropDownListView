//
//  DropDownListView.m
//  KDropDownMultipleSelection
//
//  Created by Agilsun on 03/01/14.
//  Copyright (c) 2014 Agilsun. All rights reserved.
//

#import "AGSDropDownListView.h"
#import "AGSDropDownCell.h"

#define DROPDOWNVIEW_SCREENINSET 0
#define DROPDOWNVIEW_HEADER_HEIGHT 44
#define RADIUS 0

#define IMAGE_CHECK_TAG     1000

@interface AGSDropDownListView (private)

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

- (id)initWithTitle:(NSString *)title options:(NSArray *)options frame:(CGRect)rect isMultiple:(BOOL)isMultiple
{
    isMultipleSelection = isMultiple;
    
    if (self = [super initWithFrame:rect])
    {
        self.backgroundColor = [UIColor clearColor];
        _kTitleText = [title copy];
        _kDropDownOptions = [options copy];
        self.selectedIndexes = [[NSMutableArray alloc]init];
        
        _kTableView = [[UITableView alloc] initWithFrame:CGRectMake(DROPDOWNVIEW_SCREENINSET,
                                                                   DROPDOWNVIEW_SCREENINSET + DROPDOWNVIEW_HEADER_HEIGHT,
                                                                   rect.size.width - 2 * DROPDOWNVIEW_SCREENINSET,
                                                                   rect.size.height - 2 * DROPDOWNVIEW_SCREENINSET - DROPDOWNVIEW_HEADER_HEIGHT - RADIUS)];
        
        _kTableView.separatorColor = [UIColor colorWithWhite:1 alpha:.2];
        _kTableView.backgroundColor = [UIColor clearColor];
        _kTableView.dataSource = self;
        _kTableView.delegate = self;
        [self addSubview:_kTableView];
        
        if (isMultipleSelection) {
            UIButton *buttonDone = [UIButton  buttonWithType:UIButtonTypeCustom];
            [buttonDone setFrame:CGRectMake(rect.size.width - 90, 4, 82, 36)];
            [buttonDone setImage:[UIImage imageNamed:@"done@2x.png"]
                        forState:UIControlStateNormal];
            buttonDone.titleLabel.font = [UIFont boldSystemFontOfSize:13];
            [buttonDone addTarget:self
                           action:@selector(buttonDoneClicked:)
                 forControlEvents:UIControlEventTouchUpInside];
            
            [self addSubview:buttonDone];
        }
    }
    
    return self;
}

- (id)initWithTitle:(NSString *)title objects:(NSArray *)objects attributeName:(NSString *)attributeName frame:(CGRect)rect isMultiple:(BOOL)isMultiple
{
    self = [super initWithFrame:rect];
    
    if (self) {
        NSMutableArray *dataStrings = [[NSMutableArray alloc] init];
        
        for (NSObject *obj in objects) {
            NSString *str = [obj valueForKey:attributeName];
            [dataStrings addObject:str];
        }
        
        self = [self initWithTitle:title options:dataStrings frame:rect isMultiple:isMultiple];
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

#pragma mark - Private Methods

- (void)fadeIn
{
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
    return [_kDropDownOptions count];
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
    cell.textLabel.text = [_kDropDownOptions objectAtIndex:row];
    
    /**
     *  Image
     */
    if (self.imageNames && self.imageNames.count > 0) {
        NSString *imageName = [self.imageNames objectAtIndex:indexPath.row];
        cell.imageView.image = [self scaleImage:[UIImage imageNamed:imageName]
                                         toSize:CGSizeMake(30, 30)];
    }
    
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
    CGRect bgRect = CGRectInset(rect, DROPDOWNVIEW_SCREENINSET, DROPDOWNVIEW_SCREENINSET);
    CGRect titleRect = CGRectMake(DROPDOWNVIEW_SCREENINSET + 10, 10,
                                  rect.size.width -  2 * (DROPDOWNVIEW_SCREENINSET + 10), DROPDOWNVIEW_HEADER_HEIGHT);
    CGRect separatorRect = CGRectMake(DROPDOWNVIEW_SCREENINSET, DROPDOWNVIEW_SCREENINSET + DROPDOWNVIEW_HEADER_HEIGHT - 2,
                                      rect.size.width - 2 * DROPDOWNVIEW_SCREENINSET, 2);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    [color setFill];
    
    float x = DROPDOWNVIEW_SCREENINSET;
    float y = DROPDOWNVIEW_SCREENINSET;
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
    
    if (([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)) {
        //TODO : change font in title
        
        UIFont *font = [UIFont boldSystemFontOfSize:15];
        UIColor *aColor = [UIColor whiteColor];
        
        NSDictionary *attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:aColor};
        
        [_kTitleText drawInRect:titleRect withAttributes:attributes];
    }
    
    CGContextFillRect(ctx, separatorRect);
}

- (void)setBackgroundDropDown:(UIColor *)aColor
{
    color = aColor;
}

@end
