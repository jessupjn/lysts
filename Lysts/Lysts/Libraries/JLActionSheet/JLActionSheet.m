//
//  JLActionSheet.m
//  JLActionSheet
//
//  Created by Jason Loewy on 1/31/13.
//  Copyright (c) 2013 Jason Loewy. All rights reserved.
//

#import "JLActionSheet.h"
#import <QuartzCore/QuartzCore.h>

#import "JLActionButton.h"

@interface JLActionSheet ()

/// Action Objects
@property (nonatomic, strong) id<JLActionSheetDelegate> delegate;

/// UI Instance Objects
@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong) NSString* cancelTitle;
@property (nonatomic, strong) NSArray* buttonTitles;

/// Display Containers
@property (nonatomic, strong) UIPopoverController* popoverController;

@end

@implementation JLActionSheet

#define Color(r,g,b,a) [UIColor colorWithRed:(r/(float)255) green:(g/(float)255) blue:(b/(float)255) alpha:a]

/// UI Objects
#define kDefaultStyle JLSTYLE_STEEL
#define kActionButtonHeight 50.0f

/// Display Macros
#define kBGFadeOpacity .3

/// Animation Macros
#define kBGFadeDuration .15

#pragma mark - 
#pragma mark - Initialization Methods

const NSInteger cancelButtonTag      = 9382;
const NSInteger buttonParentsViewTag = 28453;
const NSInteger tapBGViewTag         = 4292;

- (id) initWithTitle:(NSString *)title delegate:(id<JLActionSheetDelegate>)delegate cancelButtonTitle:(NSString *)cancelTitle otherButtonTitles:(NSArray *)buttonTitles
{
    if (self = [super init])
    {
        _title              = title;
        _cancelTitle        = cancelTitle;
        _delegate           = delegate;
        _cancelButtonIndex  = -1;
        
        // Reverse the order of the button titles so the buttons are displayed in the correct order
        NSMutableArray* tempTitles  = [[NSMutableArray alloc] initWithCapacity:buttonTitles.count];
        for (NSString* currentTitle in buttonTitles)
            [tempTitles insertObject:currentTitle atIndex:0];
        _buttonTitles = tempTitles;
        
        [self setBackgroundColor:[UIColor clearColor]];
        [self setStyle:kDefaultStyle];
        [self setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
        [self setAutoresizesSubviews:YES];
        
        // Create the background clear tap responder view
        UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissActionSheet:)];
        UIView* tapBGView                  = [[UIView alloc] initWithFrame:self.frame];
        tapBGView.tag                      = tapBGViewTag;
        
        [tapBGView setBackgroundColor:[UIColor clearColor]];
        [tapBGView addGestureRecognizer:tapGesture];
        [tapBGView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
        [self addSubview:tapBGView];
    }
    
    return self;
}


+ (id) sheetWithTitle:(NSString *)title delegate:(id<JLActionSheetDelegate>)delegate cancelButtonTitle:(NSString *)cancelTitle otherButtonTitles:(NSArray *)buttonTitles
{
    return [[JLActionSheet alloc] initWithTitle:title delegate:delegate cancelButtonTitle:cancelTitle otherButtonTitles:buttonTitles];
}

-(void)addButtonWithTitle:(NSString*)title
{
    NSMutableArray *arr = [NSMutableArray arrayWithArray:self.buttonTitles];
    [arr addObject:title];
    self.buttonTitles = arr;
}

-(void)setTitle:(NSString *)title
{
    _title = title;
}

-(NSString*)getTitle
{
    return _title;
}

#pragma mark - 
#pragma mark - Presentation Methods


- (UIView*) layoutButtonsWithTitle:(BOOL) allowTitle
{
    CGFloat titleOffset                 = (_title == nil || !allowTitle) ? 0 : 20;
    JLActionSheetStyle* currentStlye    = [[JLActionSheetStyle alloc] initWithStyle:_style];
    CGFloat buttonHeight                = kActionButtonHeight;
    NSInteger buttonCount               = _cancelTitle ? (_buttonTitles.count + 1) : _buttonTitles.count;
    
    // buttonheight (to make cancel button offset)
    // + (buttonheight-5) for each button
    CGFloat parentViewHeight            = ((buttonHeight) + ((buttonHeight-5) * (buttonCount-1)) + 15 + titleOffset);
    UIView* buttonParentView            = [[UIView alloc] initWithFrame:CGRectMake(0, (CGRectGetHeight(self.bounds) - parentViewHeight), CGRectGetWidth(self.bounds), parentViewHeight)];
    CGFloat currentButtonTop            = buttonParentView.bounds.size.height - buttonHeight;
    CGFloat currentButtonTag            = 0;
    
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:17];
    [buttonParentView setBackgroundColor:Color(220,220,220,1)];
    if (_cancelTitle)
    {
        JLActionButton* cancelButton    = [JLActionButton buttonWithStyle:currentStlye andTitle:_cancelTitle isCancel:YES];
        cancelButton.tag                = currentButtonTag++;
        _cancelButtonIndex              = cancelButton.tag;
        
        [cancelButton.titleLabel setFont:font];
        [cancelButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        
        [cancelButton.layer setCornerRadius:3];
        [cancelButton setClipsToBounds:YES];
        [cancelButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cancelButton setFrame:CGRectMake(10, currentButtonTop, CGRectGetWidth(buttonParentView.bounds)-20, buttonHeight-5)];
        [buttonParentView addSubview:cancelButton];
        
        currentButtonTop -= buttonHeight;
    }
    
    for (NSString* currentButtonTitle in _buttonTitles)
    {
        
        JLActionButton* currentActionButton = [JLActionButton buttonWithStyle:currentStlye andTitle:currentButtonTitle isCancel:NO];
        currentActionButton.tag             = currentButtonTag++;
        [currentActionButton.titleLabel setFont:font];
        [currentActionButton setClipsToBounds:YES];
        
        [currentActionButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [currentActionButton setFrame:CGRectMake(10, currentButtonTop, CGRectGetWidth(buttonParentView.bounds)-20, buttonHeight-5)];
        
        // ROUND CORNERS IF NEEDED
        if([currentButtonTitle isEqualToString:[_buttonTitles firstObject]] || [currentButtonTitle isEqualToString:[_buttonTitles lastObject]])
        {
            UIBezierPath *maskPath;
            if([currentButtonTitle isEqualToString:[_buttonTitles lastObject]])
            {
                // ROUND TOP CORNERS
                maskPath = [UIBezierPath bezierPathWithRoundedRect:currentActionButton.bounds
                                                 byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight)
                                                       cornerRadii:CGSizeMake(3.0, 3.0)];
            }
            else
            {
                // ROUND BOTTOM CORNERS
                maskPath = [UIBezierPath bezierPathWithRoundedRect:currentActionButton.bounds
                                                 byRoundingCorners:(UIRectCornerBottomLeft | UIRectCornerBottomRight)
                                                       cornerRadii:CGSizeMake(3.0, 3.0)];
            }
        
            CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
            maskLayer.frame = self.bounds;
            maskLayer.path = maskPath.CGPath;
            currentActionButton.layer.mask = maskLayer;
        }
      
//        [currentActionButton.layer setCornerRadius:3];
        
        [buttonParentView addSubview:currentActionButton];
        currentButtonTop -= buttonHeight-5;
    }
    
    // Handle creating the title object if there is a title provided
    if (_title.length > 0 && allowTitle)
    {
        [buttonParentView setBackgroundColor:Color(220,220,220,1)];
        [((JLActionButton*)[buttonParentView.subviews lastObject]) configureForTitle];
        
        UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(buttonParentView.bounds), titleOffset)];        
        [titleLabel setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin)];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        [titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [titleLabel setTextColor:[currentStlye getTextColor:NO]];
        [titleLabel setShadowOffset:CGSizeMake(0, -1.0)];
        [titleLabel setShadowColor:[currentStlye getTextShadowColor:NO]];
        [titleLabel setTextAlignment:NSTextAlignmentCenter];
        [titleLabel setText:_title];
        
        [buttonParentView addSubview:titleLabel];
    }
    [buttonParentView setAutoresizingMask:(UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth)];
    [buttonParentView.layer setShadowColor:[UIColor blackColor].CGColor];
    [buttonParentView.layer setShadowOffset:CGSizeMake(0, -3.0f)];
    [buttonParentView.layer setShadowOpacity:.3f];
    [buttonParentView.layer setShadowRadius:4.0f];
    CGPathRef path = [UIBezierPath bezierPathWithRect:buttonParentView.bounds].CGPath;
    [buttonParentView.layer setShadowPath:path];
    return buttonParentView;
}

/*
 Repsonsible for presenting the JLActionSheet from the parentview specified
 Must first make sure that the sizing and origin of the JLActionSheet is correct
 PARAMETERS:
 parentView -> The view that the JLActionSheet is being presented on
 */
- (void) showInView:(UIView *)parentView
{
    UIView* viewToAddTo = [UIApplication sharedApplication].keyWindow.subviews[0];
    [self setFrame:viewToAddTo.bounds];
    
    // Create the parent UIView that houses the JLActionButtons
    UIView* buttonsParentView   = [self layoutButtonsWithTitle:YES];
    buttonsParentView.tag       = buttonParentsViewTag;
    CGPoint originalCenter      = buttonsParentView.center;
    [buttonsParentView setCenter:CGPointMake(buttonsParentView.center.x, (CGRectGetHeight(self.bounds) + (CGRectGetHeight(buttonsParentView.bounds) / 2)))];
    [self addSubview:buttonsParentView];
    
    [self setAlpha:0.0f];
    [viewToAddTo addSubview:self];
    [UIView animateWithDuration:kBGFadeDuration delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        [self setBackgroundColor:Color(0, 0, 0, 0.5)];
        [self setAlpha:1.0f];
        [buttonsParentView setCenter:originalCenter];
    }completion:nil];
}

/*
 Convienence method for displaying on the view of a UIViewController
 Calls showInView: with the view controllers main view
 PARAMETERS:
 parentViewController -> The ViewController that the JLActionSheet will be presented on
 */
- (void) showOnViewController:(UIViewController *)parentViewController { [self showInView:parentViewController.view]; }


- (void) showFromBarItem:(UIBarButtonItem *)barButton onView:(UIView *)parentView
{
    
    // Only show from bar button item in a popover if coming from iPad
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)
        [self showInView:parentView];
    else
    {
        BOOL allowTitle                 = (_title.length > 0) ? NO : YES;
        UIView* buttonsParentView       = [self layoutButtonsWithTitle:allowTitle];
        UIViewController* actionSheetVC = [[UIViewController alloc] init];
        actionSheetVC.view              = buttonsParentView;
        
        if (_title.length > 0)
        {
            // Enter here if there is a title for this actionsheet
            UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:actionSheetVC];
            _popoverController = [[UIPopoverController alloc] initWithContentViewController:navController];
            [_popoverController setPopoverContentSize:CGSizeMake(_popoverController.popoverContentSize.width, buttonsParentView.bounds.size.height + (navController.navigationBar.bounds.size.height - 10))];
            
            // Initialize and configure the navigation title item
            UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _popoverController.popoverContentSize.width, 34)];
            [titleLabel setBackgroundColor:[UIColor clearColor]];
            [titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
            [titleLabel setTextColor:[UIColor whiteColor]];
            [titleLabel setTextAlignment:NSTextAlignmentCenter];
            [titleLabel setShadowColor:[UIColor blackColor]];
            [titleLabel setShadowOffset:CGSizeMake(0, -.5)];
            
            [titleLabel setText:_title];
            [actionSheetVC.navigationItem setTitleView:titleLabel];
        }
        else
        {
            _popoverController = [[UIPopoverController alloc] initWithContentViewController:actionSheetVC];
            [_popoverController setPopoverContentSize:CGSizeMake(_popoverController.popoverContentSize.width, buttonsParentView.bounds.size.height)];
        }
        
        [_popoverController presentPopoverFromBarButtonItem:barButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}

- (void) showFromBarItem:(UIBarButtonItem *)barButton onViewController:(UIViewController *)parentViewController { [self showFromBarItem:barButton onView:parentViewController.view]; }

#pragma mark - 
#pragma mark - Dismissal Methods

/*
 Repsonsible for hiding the action sheet
 This is the final method that is called in the lifecycle of the JLAction sheet
 PARAMETERS:
 id -> The object that is triggering the closing of the JLActionsheet
 */
- (void) dismissActionSheet:(id) sender
{
    if (!_popoverController)
    {
        UIView* buttonsParentView = [self viewWithTag:buttonParentsViewTag];
        [UIView animateWithDuration:(kBGFadeDuration + .05) delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
            [[self viewWithTag:tapBGViewTag] setAlpha:0.0f];
            [self setBackgroundColor:[UIColor clearColor]];
            [buttonsParentView setCenter:CGPointMake(buttonsParentView.center.x, (CGRectGetHeight(self.bounds) + (CGRectGetHeight(buttonsParentView.bounds) / 2)))];
        }completion:^(BOOL finished)
        {
            [self removeFromSuperview];
            
            //----
            // If a didDismissBLock has been provided fire that
            // If not check if the delegate responds to the didDismiss action and fire that
            // blocks take precedence over delegate since they must be explicitely provided
            //----
            if (didDismissBlock)
                didDismissBlock(self, ((JLActionButton*)sender).tag);
            else if ([sender isKindOfClass:[JLActionButton class]] && [_delegate respondsToSelector:@selector(actionSheet:didDismissButtonAtIndex:)])
                    [_delegate actionSheet:self didDismissButtonAtIndex:((JLActionButton*)sender).tag];
        }];
    }
    else
    {
        [_popoverController dismissPopoverAnimated:YES];
        
        //----
        // If a didDismissBLock has been provided fire that
        // If not check if the delegate responds to the didDismiss action and fire that
        // blocks take precedence over delegate since they must be explicitely provided
        //----
        if (didDismissBlock)
            didDismissBlock(self, ((JLActionButton*)sender).tag);
        else if ([_delegate respondsToSelector:@selector(actionSheet:didDismissButtonAtIndex:)])
                [_delegate actionSheet:self didDismissButtonAtIndex:((JLActionButton*)sender).tag];
    }
}

/*
 Responsible for reacting to when one of the JLActionButtons are clicked
 Calls the delegate method so the delegate can react and starts the dismissal process
 PARAMETERS:
 sender -> The JLActionButton that was clicked
 */
- (void) buttonClicked:(JLActionButton*) sender
{
    //----
    // If a clickedButtonBlock has been provided fire that
    // If not check if the delegate responds to the clickedButton action and fire that
    // blocks take precedence over delegate since they must be explicitely provided
    //----
    if (clickedButtonBlock)
        clickedButtonBlock(self, sender.tag);
    else if ([_delegate respondsToSelector:@selector(actionSheet:clickedButtonAtIndex:)])
            [_delegate actionSheet:self clickedButtonAtIndex:sender.tag];
    
    [self dismissActionSheet:sender];
}

#pragma mark -
#pragma mark - Accessor Methods

- (NSString*) titleAtIndex:(NSInteger)buttonIndex
{
    NSString* title;
    if (!_cancelTitle)
        title = _buttonTitles[buttonIndex];
    else
        title = (buttonIndex == _cancelButtonIndex) ? _cancelTitle : _buttonTitles[buttonIndex - 1];
    
    return title;
}

/*
 Responsible for determining if the JLActionsheet is currently being presented or not
 */
- (BOOL) isVisible
{
    if (_popoverController)
        return [_popoverController isPopoverVisible] ? YES : NO;
    
    return (self.superview == nil) ? NO : YES;
}

#pragma mark - 
#pragma mark - UI Mutator Methods

/*
 Responsible for configuring if the tap to dismiss is permitted on the background view
 PARAMETERS:
 allowTap -> The flag that determines if the tap to dismiss is allowed or not
 */
- (void) allowTapToDismiss:(BOOL)allowTap
{
    UIView* tapBGView = [self viewWithTag:tapBGViewTag];
    tapBGView.gestureRecognizers = @[];
    
    if (allowTap)
    {
        UITapGestureRecognizer* tapGesture  = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissActionSheet:)];
        [tapBGView addGestureRecognizer:tapGesture];        
    }
}

#pragma mark -
#pragma mark - Action Mutator Methods

/*
 Responsible for setting the functionality of the clickedButtonBlock
 This will then be used in place over a delegate call when it is set
 PARAMETERS
 actionBlock -> The block of code that will be used for the clickedButtonBlock
 */
- (void) setClickedButtonBlock:(JLActionBlock)actionBlock
{
    clickedButtonBlock = actionBlock;
}

/*
 Responsible for setting the functionality of teh didDismissBlock
 This will then be used in place over a delegate call when it is set
 PARAMETER:
 actionBlock -> The block of code that will be used for the didDismissBlock
 */
- (void) setDidDismissBlock:(JLActionBlock)actionBlock
{
    didDismissBlock = actionBlock;
}

@end
