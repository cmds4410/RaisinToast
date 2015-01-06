//
//  RZErrorMessagingViewController.m
//  RaisinToast
//
//  Created by alex.rouse on 8/12/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import "RZErrorMessagingViewController.h"
#import "RZErrorMessenger.h"


NSString * const kRZLevelError       = @"RZLevelError";
NSString * const kRZLevelInfo        = @"RZLevelInfo";
NSString * const kRZLevelWarning     = @"RZLevelWarning";
NSString * const kRZLevelPositive    = @"RZLevelPositive";

static CGFloat const kErrorMessagingViewVisibleHeight = 90.0f;
static CGFloat const kErrorMessagingViewVerticalPadding = 20.0f;

@interface RZErrorMessagingViewController ()

@property (weak, nonatomic) IBOutlet UIView *errorContainer;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;

@property (weak, nonatomic) NSLayoutConstraint *bottomAnimationConstraint;
@property (weak, nonatomic) NSLayoutConstraint *heightConstraint;
@property (weak, nonatomic) NSError *displayedError;

@property (strong, nonatomic) NSDictionary *colorForLevelDictionary;
@property (assign, nonatomic) CGFloat errorMessagingViewVisibleHeight;
@property (assign, nonatomic) CGFloat errorMessagingViewVerticalPadding;

@end

@implementation RZErrorMessagingViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if ( self ) {
        self.colorForLevelDictionary = [self.class defaultColorDictionary];
        self.errorMessagingViewVisibleHeight = kErrorMessagingViewVisibleHeight;
        self.errorMessagingViewVerticalPadding = kErrorMessagingViewVerticalPadding;
    }
    return self;
}

#pragma mark - UIViewController methods

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    // Since we are presented in a different window.  Rotation is handled a bit odd...  May make this better later though.
    CGFloat width = (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) ? self.view.superview.frame.size.width : self.view.superview.frame.size.height;
    width -= 2 * _errorMessagingViewVerticalPadding;
    CGFloat newHeight = [self updatedHeightWithWidth:width];
    self.heightConstraint.constant = newHeight;
    self.bottomAnimationConstraint.constant = newHeight - _errorMessagingViewVerticalPadding;
    [self.view layoutIfNeeded];
}

#pragma mark - RZMessagingViewController Protocol

- (void)rz_configureWithError:(NSError *)error
{
    self.displayedError = error;

    self.titleLabel.text = [error.localizedDescription uppercaseString];
    self.detailLabel.text = error.localizedRecoverySuggestion;
    
    switch ( [error rz_levelFromError] ) {
        case kRZErrorMessengerLevelError:
            self.errorContainer.backgroundColor = self.colorForLevelDictionary[kRZLevelError];
            break;
        case kRZErrorMessengerLevelInfo:
            self.errorContainer.backgroundColor = self.colorForLevelDictionary[kRZLevelInfo];
            break;
        case kRZErrorMessengerLevelWarning:
            self.errorContainer.backgroundColor = self.colorForLevelDictionary[kRZLevelWarning];
            break;
        case kRZErrorMessengerLevelPositive:
            self.errorContainer.backgroundColor = self.colorForLevelDictionary[kRZLevelPositive];
            break;
        default:
            self.errorContainer.backgroundColor = self.colorForLevelDictionary[kRZLevelInfo];
            break;
    }
    CGFloat updatedHeight = [self updatedHeight];
    self.heightConstraint.constant = updatedHeight;
    [self.view layoutIfNeeded];
}

- (void)rz_configureLayoutForContainer:(UIView *)container
{
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    // Setup all the needed constraints for the view.
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:self.view
                                                         attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:nil
                                                         attribute:NSLayoutAttributeNotAnAttribute
                                                        multiplier:1.0f
                                                          constant:self.errorMessagingViewVisibleHeight];
    [container addConstraint:heightConstraint];
    self.heightConstraint = heightConstraint;

    NSLayoutConstraint *errorBottomConstraint = [NSLayoutConstraint constraintWithItem:self.view
                                                                             attribute:NSLayoutAttributeBottom
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:container
                                                                             attribute:NSLayoutAttributeTop
                                                                            multiplier:1.0f
                                                                              constant:0.0f];
    [container addConstraint:errorBottomConstraint];
    self.bottomAnimationConstraint = errorBottomConstraint;
    
    NSLayoutConstraint *leftSpaceConstraint = [NSLayoutConstraint constraintWithItem:self.view
                                                         attribute:NSLayoutAttributeLeft
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.view.superview
                                                         attribute:NSLayoutAttributeLeft
                                                        multiplier:1.0f
                                                          constant:0.0f];
    [self.view.superview addConstraint:leftSpaceConstraint];
    
    NSLayoutConstraint *rightSpaceConstraint = [NSLayoutConstraint constraintWithItem:self.view
                                                         attribute:NSLayoutAttributeRight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.view.superview
                                                         attribute:NSLayoutAttributeRight
                                                        multiplier:1.0f
                                                          constant:-0.0f];
    [self.view.superview addConstraint:rightSpaceConstraint];

    self.view.alpha = 0.0f;
    [self.view setNeedsLayout];
    
}

- (void)rz_presentAnimated:(BOOL)animated completion:(RZMessagingWindowAnimationCompletionBlock)completion
{
    CGFloat updatedHeight = [self updatedHeight];
    self.bottomAnimationConstraint.constant = updatedHeight - self.errorMessagingViewVerticalPadding;
    self.heightConstraint.constant = updatedHeight;
    [self.view setNeedsLayout];
    if ( animated ) {
        [UIView animateWithDuration:0.7f delay:0.0f usingSpringWithDamping:0.65f initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [self.view.superview layoutIfNeeded];
            self.view.alpha = 1.0f;
        } completion:^(BOOL finished) {
            if (completion != nil) {
                completion(finished);
            }
        }];
    }
    else {
        [self.view.superview layoutIfNeeded];
        self.view.alpha = 1.0f;
        if (completion != nil) {
            completion(YES);
        }
    }
}

- (void)rz_dismissAnimated:(BOOL)animated completion:(RZMessagingWindowAnimationCompletionBlock)completion
{
    self.bottomAnimationConstraint.constant = 0.0f;
    if ( animated ) {
        [UIView animateWithDuration:0.7f delay:0.0f usingSpringWithDamping:0.65f initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [self.view.superview layoutIfNeeded];
            self.view.alpha = 0.0f;
        } completion:^(BOOL finished) {
            if (completion != nil) {
                completion(finished);
            }
        }];
    }
    else {
        [self.view.superview layoutIfNeeded];
        self.view.alpha = 0.0f;
        if (completion != nil) {
            completion(YES);
        }
    }
}

#pragma mark - Private Methods
+ (NSDictionary *)defaultColorDictionary
{
    static NSDictionary *colorDictionary = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        colorDictionary = @{
                            kRZLevelError :[UIColor colorWithRed:191.0f/255.0f green:56.0f/255.0f blue:54.0f/255.0f alpha:1.0f],
                            kRZLevelInfo : [UIColor colorWithRed:66.0f/255.0f green:151.0f/255.0f blue:237.0f/255.0f alpha:1.0f],
                            kRZLevelWarning : [UIColor colorWithRed:255.0f/255.0f green:172.0f/255.0f blue:0.0f/255.0f alpha:1.0f],
                            kRZLevelPositive : [UIColor colorWithRed:0.0f/255.0f green:172.0f/255.0f blue:0.0f/255.0f alpha:1.0f]
                            };
    });
    return colorDictionary;
}

- (CGFloat)updatedHeight
{
    return [self updatedHeightWithWidth:(self.view.frame.size.width - (2 * _errorMessagingViewVerticalPadding))];
}

- (CGFloat)updatedHeightWithWidth:(CGFloat)width
{
    CGFloat height = _errorMessagingViewVisibleHeight;
    
    
    
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:self.detailLabel.text attributes:@{ NSFontAttributeName : self.detailLabel.font }];
    CGRect rect = [attributedText boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
    
    CGSize size = rect.size;
    
    height += size.height;
    return height;
}

@end
