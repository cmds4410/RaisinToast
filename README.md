# RaisinToast

[![CI Status](http://img.shields.io/travis/adamhrz/RaisinToast.svg?style=flat)](https://travis-ci.org/adamhrz/RaisinToast)
[![Version](https://img.shields.io/cocoapods/v/RaisinToast.svg?style=flat)](http://cocoadocs.org/docsets/RaisinToast)
[![License](https://img.shields.io/cocoapods/l/RaisinToast.svg?style=flat)](http://cocoadocs.org/docsets/RaisinToast)
[![Platform](https://img.shields.io/cocoapods/p/RaisinToast.svg?style=flat)](http://cocoadocs.org/docsets/RaisinToast)

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

RaisinToast is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "RaisinToast"

## Configuration options
### Out of the box configuration

In app delegate add to imports:

    @class RZMessagingWindow;

Add new property:

    @property (strong, nonatomic) RZMessagingWindow *errorWindow;

In implementation add private method:

    - (void)setupMessagingWindow
    {
        self.errorWindow = [RZMessagingWindow defaultMessagingWindow];
        [RZErrorMessenger setDefaultMessagingWindow:self.errorWindow];
        [RZErrorMessenger setDefaultErrorDomain:[NSString stringWithFormat:@"%@.error",[[NSBundle mainBundle] bundleIdentifier]]];
    }

### Style override

Subclass RZErrorMessagingViewController 

    @interface MyErrorMessagingViewController : RZErrorMessagingViewController <RZMessagingViewController>

Override init and provide an alternative color definition for each level of error

    - (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
    {
        self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
        if ( self ) {
            self.colorForLevelDictionary = @{
                kRZLevelError :[UIColor redColor],
                kRZLevelInfo : [UIColor blueColor],
                kRZLevelWarning : [UIColor orangeColor],
                kRZLevelPositive : [UIColor greenColor]
            };
            self.errorMessagingViewVerticalPadding = -200.0f;
        }
        return self;
    }

In app delegate use your custom class

    self.errorWindow = [RZMessagingWindow messagingWindow];
    self.errorWindow.messageViewControllerClass = [MyErrorMessagingViewController class];	


### Custom View Controller 
Implement protocol RZMessagingViewController

    - (void)rz_configureWithError:(NSError *)error;
    - (void)rz_presentAnimated:(BOOL)animated completion:(RZMessagingWindowAnimationCompletionBlock)completion;
    - (void)rz_dismissAnimated:(BOOL)animated completion:(RZMessagingWindowAnimationCompletionBlock)completion;

## Demo 

## Author

adamhrz, adam.howitt@raizlabs.com

## License

RaisinToast is available under the MIT license. See the LICENSE file for more info.