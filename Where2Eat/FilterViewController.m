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
    filterNames=[[NSArray arrayWithObjects:@"Chinese",
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
                 @"Caribbean",
                 @"Indian",
                 @"Latin American",
                 @"Middle Eastern",
                 @"Seafood",
                 @"Vegetarian",
                  nil] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    NSMutableArray* sortedNames=[NSMutableArray arrayWithArray:filterNames];
    [sortedNames addObject:@"All"];
    filterNames=[NSArray arrayWithArray:sortedNames];
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
        [self selectLabel:filter withBool:NO];
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
         [self selectLabel:selectdLabel withBool:YES];
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
    // gr.view is "All"
    if ([selected.text isEqualToString:@"All"]) {
        // if All is selected, unselected all filters
        if (selected.tag == 1) {
            for (UIView *filter in self.view.subviews) {
                if ([filter isKindOfClass:[UILabel class]]) {
                    UILabel *tmpLabel = (UILabel*)filter;
                    [self selectLabel:tmpLabel withBool:NO];
                    [_selectedFilters removeAllObjects];
                }
            }
        } else {
            for (UIView *filter in self.view.subviews) {
                if ([filter isKindOfClass:[UILabel class]]) {
                    UILabel *tmpLabel = (UILabel*)filter;
                    [self selectLabel:tmpLabel withBool:YES];
                    [_selectedFilters addObject:tmpLabel.text];
                }
            }
            
        }
        //[_selectedFilters removeObject:selected.text];
    } else {
        if (selected.tag == 0) {
            [self selectLabel:selected withBool:YES];
            [_selectedFilters addObject:selected.text];
        } else {
            [self selectLabel:selected withBool:NO];
            [_selectedFilters removeObject:selected.text];
            if ([_selectedFilters containsObject:@"All"]) {
                UILabel *allLabel = [self getObjectWithKey:@"filterNames" value:@"All"];
                [self selectLabel:allLabel withBool:NO];
                [_selectedFilters removeObject:@"All"];
            }
        }
    }
    
    
    
    NSLog(@"%@",_selectedFilters);
}

-(void)selectLabel:(UILabel*)label withBool:(BOOL)select
{
    if (select) {
        label.tag = 1;
        label.alpha = 0.85f;
        label.textColor = [UIColor whiteColor];
    } else {
        label.tag = 0;
        label.alpha = 0.4f;
        label.textColor = [UIColor whiteColor];
    }
}


@end
