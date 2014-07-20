//
//  FilterViewController.m
//  Where2Eat
//
//  Created by Alex Wang on 7/19/2014.
//
//

#import "FilterViewController.h"

@interface FilterViewController ()



@end

@implementation FilterViewController {
 
    NSMutableArray *selectedFilters;
    NSArray* filterNames;
    
}


- (UIColor*)randomColor{
    CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
    return color;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    filterNames=[NSArray arrayWithObjects:@"Chinese",
                 @"Korean",
                 @"Taiwanese",
                 @"Japanese",
                 @"Italian",
                 @"French",
                 @"Fast Food",
                 @"American",
                 @"Viet/Thai",
                 @"Asian Fusion",
                 @"Cafes",
                 @"Canadian",
                 @"Indian",
                 @"Mexican",
                 @"Middle Eastern",
                 @"Spanish",
                 @"Vegetarian",
                 @"All", nil];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.view.frame=(CGRect){0,-(self.parentViewController.view.bounds.size.height-150),320,self.parentViewController.view.bounds.size.height-150};

    self.view.autoresizingMask = FLEX_SIZE;
    
    for (int i=0;i<18;i++){
        UILabel* filter=[[UILabel alloc]init];
        filter.text=filterNames[i];
        filter.textAlignment=NSTextAlignmentCenter;
        filter.textColor=[UIColor whiteColor];
        filter.font=[UIFont fontWithName:@"HiraKakuProN-W3-Bold" size:15];
        filter.alpha=0.2f;
        filter.tag = 0;
        filter.lineBreakMode = NSLineBreakByWordWrapping;
        filter.numberOfLines = 0;
        filter.userInteractionEnabled = YES;
        filter.frame=(CGRect){(i%3)*SVB.size.width/3+2,i/3*SVB.size.height/6+2,SVB.size.width/3-4,SVB.size.height/6-4};
        filter.backgroundColor=[self randomColor];
        filter.autoresizingMask = FLEX_SIZE;
        UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectCategory:)];
        [filter addGestureRecognizer:gr];
        [self.view addSubview:filter];
    }
}

#pragma mark - data source

- (NSArray*)getFilters
{
    return selectedFilters;
}

#pragma mark - Action

- (void)selectCategory:(UIGestureRecognizer*)gr
{
    UILabel *selected = (UILabel*)gr.view;
    if (selected.tag == 0) {
        selected.tag = 1;
        selected.alpha = 0.85f;
        [selectedFilters addObject:selected.text];
    } else {
        selected.tag = 0;
        selected.alpha = 0.4f;
        [selectedFilters removeObject:selected.text];
    }
    if ([selected.text isEqualToString:@"All"]) {
        for (UIView *filter in self.view.subviews) {
            if ([filter isKindOfClass:[UILabel class]]) {
                UILabel *tmpLabel = (UILabel*)filter;
                if (selected.tag == 0) {
                    tmpLabel.tag = 0;
                    tmpLabel.alpha = 0.4f;
                    [selectedFilters addObject:tmpLabel.text];
                } else {
                    tmpLabel.tag = 1;
                    tmpLabel.alpha = 0.85f;
                    [selectedFilters removeObject:tmpLabel.text];
                }
            }
        }
    }
    
}


@end
