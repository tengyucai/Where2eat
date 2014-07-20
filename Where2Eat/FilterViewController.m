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
 
    
    NSArray* filterNames;
    
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
                 @"European",
                 @"Cafes",
                 @"African",
                 @"Indian",
                 @"Latin American",
                 @"Middle Eastern",
                 @"Seafood",
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
        filter.alpha=0.4f;
        filter.tag = 0;
        filter.lineBreakMode = NSLineBreakByWordWrapping;
        filter.numberOfLines = 0;
        filter.userInteractionEnabled = YES;
        filter.frame=(CGRect){(i%3)*SVB.size.width/3+2,i/3*SVB.size.height/6+2,SVB.size.width/3-4,SVB.size.height/6-4};
        filter.backgroundColor=[self randomColor];
        filter.autoresizingMask = FLEX_SIZE;
        [self setValue:filter.text withKey:@"filterNames" forObject:filter];
        UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectCategory:)];
        [filter addGestureRecognizer:gr];
        [self.view addSubview:filter];
    }
    for (NSString *text in _selectedFilters) {
        UILabel *selectdLabel = [self getObjectWithKey:@"filterNames" value:text];
        selectdLabel.tag = 1;
        selectdLabel.alpha = 0.85f;
    }
    
}


- (UIColor*)randomColor{
    CGFloat hue;
    do {
        hue=arc4random() % 256 / 256.0 ;
    } while ( !((fabsf(hue-240.0f/256.0f)>0.1f)&&(fabsf(hue+1-240.0f/256.0f)>0.1f)));  //  0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 800.0 ) + 0.4;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 800.0 ) + 0.75;  //  0.5 to 1.0, away from black
    UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
    return color;
}


#pragma mark - data source

- (NSArray*)getFilters
{
    return _selectedFilters;
}

-(void)setSelectedFilters:(NSMutableArray *)selectedFilters
{
    _selectedFilters = selectedFilters;
    
    
}

#pragma mark - Action

- (void)selectCategory:(UIGestureRecognizer*)gr
{
    UILabel *selected = (UILabel*)gr.view;
    if (selected.tag == 0) {
        selected.tag = 1;
        selected.alpha = 0.85f;
        [_selectedFilters addObject:selected.text];
    } else {
        selected.tag = 0;
        selected.alpha = 0.4f;
        [_selectedFilters removeObject:selected.text];
    }
    if ([selected.text isEqualToString:@"All"]) {
        [_selectedFilters removeObject:selected.text];
        for (UIView *filter in self.view.subviews) {
            if ([filter isKindOfClass:[UILabel class]]) {
                UILabel *tmpLabel = (UILabel*)filter;
                if (selected.tag == 0) {
                    tmpLabel.tag = 0;
                    tmpLabel.alpha = 0.4f;
                    
                    [_selectedFilters removeAllObjects];
                } else {
                    tmpLabel.tag = 1;
                    tmpLabel.alpha = 0.85f;
                    
                    [_selectedFilters addObject:tmpLabel.text];
                }
            }
        }
    }
    NSLog(@"%@",_selectedFilters);
}


@end
