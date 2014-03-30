//
//  ViewController.h
//  TestPU
//
//  Created by Jeremy_Luo on 3/28/14.
//  Copyright (c) 2014 Tianyou_Luo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>
#import "sendgrid.h"

@class ACEDrawingView;

@interface CanvasViewController : UIViewController
@property (strong, nonatomic) IBOutlet ACEDrawingView *drawingView;
@property (weak, nonatomic) IBOutlet UIToolbar *headToolBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *undoButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *redoButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *alphaButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *widthButton;
@property (weak, nonatomic) IBOutlet UIButton *hiddenButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *toolButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *colorButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *eraserButton;
@property (weak, nonatomic) IBOutlet UIToolbar *footToolBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *voiceButton;
// @property (weak, nonatomic) IBOutlet UIBarButtonItem *prevPageButton;
// @property (weak, nonatomic) IBOutlet UIBarButtonItem *nextPageButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cameraButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveFileButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *emailButton;
@property (weak, nonatomic) IBOutlet UISlider *alphaSlide;
@property (weak, nonatomic) IBOutlet UISlider *widthSlide;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *captionButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *playButton;
@property (weak, nonatomic) IBOutlet UITextView *captionTextView;

/* actions */
- (IBAction)undo:(UIBarButtonItem *)sender;
- (IBAction)redo:(UIBarButtonItem *)sender;
- (IBAction)hidden:(UIButton *)sender;
- (IBAction)tool:(UIBarButtonItem *)sender;
- (IBAction)color:(UIBarButtonItem *)sender;
- (IBAction)eraser:(UIBarButtonItem *)sender;
- (IBAction)recordVoice:(UIBarButtonItem *)sender;
// - (IBAction)prevPage:(id)sender;
// - (IBAction)nextPage:(id)sender;
- (IBAction)camera:(UIBarButtonItem *)sender;
- (IBAction)useCamera:(id)sender;
- (IBAction)useCameraRoll:(id)sender;
- (IBAction)saveFile:(UIBarButtonItem *)sender;
- (IBAction)email:(UIBarButtonItem *)sender;
- (IBAction)toggleAlphaSlide:(UIBarButtonItem *)sender;
- (IBAction)toggleWidthSlide:(UIBarButtonItem *)sender;
- (IBAction)changeAlpha:(UISlider *)sender;
- (IBAction)changeWidth:(UISlider *)sender;
- (IBAction)caption:(UIBarButtonItem *)sender;
- (IBAction)playRecord:(UIBarButtonItem *)sender;


// for sending email
@property (weak, nonatomic) UIImage * imageForSendingEmail;
@property NSString * pathOfAudioRecord;
@property NSString * captionForEmail;

@end
