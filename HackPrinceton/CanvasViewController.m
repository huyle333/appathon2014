//
//  anvasViewController.m
//  TestPU
//
//  Created by Jeremy_Luo on 3/28/14.
//  Copyright (c) 2014 Tianyou_Luo. All rights reserved.
//

#import "CanvasViewController.h"
#import "ACEDrawingView.h"
#import <MobileCoreServices/MobileCoreServices.h>

#define ActionSheetColor        0
#define ActionSheetTool         1
#define ActionSheetEraser       2
#define ActionSheetCamera       3

@interface CanvasViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate, UIPopoverControllerDelegate, UIActionSheetDelegate, ACEDrawingViewDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate, UITextViewDelegate>
{
@private BOOL recorded;
@private BOOL playing;
@private BOOL editing;
@private UIImage * toolImage;
@private BOOL focusOnEraserButton;
@private ACEDrawingToolType currentTool;
@private UIColor * currentColor;
@private CGFloat currentLineWidth;
@private CGFloat currentLineAlpha;
    // @private int indexOfPage;
    // @private NSMutableArray * book;
    UIImagePickerController * imagePicker;
    UIPopoverController * popoverController;
    BOOL newMedia;
    
    AVAudioRecorder *recorder;
    AVAudioPlayer *player;
    
}


@end

@implementation CanvasViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    
    // set the delegate
    self.drawingView.delegate = self;
    
    // set up a book
    // book = [[NSMutableArray alloc] initWithCapacity:100];
    
    [self initPage];
    imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    
    // Set the audio file
    NSArray *pathComponents = [NSArray arrayWithObjects:
                               [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                               @"audioRecord.m4a",
                               nil];
    
    NSURL *outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
    
    // Setup audio session
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    // Define the recorder setting
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
    
    // Initiate and prepare the recorder
    recorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:recordSetting error:nil];
    recorder.delegate = self;
    recorder.meteringEnabled = YES;
    [recorder prepareToRecord];
    
    self.captionTextView.delegate = self;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(drawingViewTapped)];
    [self.drawingView addGestureRecognizer:tap];
    
}

- (void)drawingViewTapped
{
    self.alphaSlide.hidden = YES;
    self.widthSlide.hidden = YES;
    if (!editing)
        self.captionTextView.hidden = YES;
}

- (void)initPage
{
    // indexOfPage = 0;
    focusOnEraserButton = NO;
    playing = NO;
    
    self.alphaSlide.hidden = TRUE;
    self.widthSlide.hidden = TRUE;
    
    
    toolImage = [UIImage imageNamed:@"pencil.png"];
    currentTool = ACEDrawingToolTypePen;
    self.drawingView.drawTool = currentTool;
    
    currentColor = [UIColor blackColor];
    self.drawingView.lineColor = currentColor;
    
    currentLineWidth = 2.0;
    self.drawingView.lineWidth = currentLineWidth;
    
    currentLineAlpha = 1.0;
    self.drawingView.lineAlpha = currentLineAlpha;
    
    [self initBarButtonItem];
    [self.hiddenButton setImage:[UIImage imageNamed:@"round_minus.png"] forState:UIControlStateNormal];
    [self.headToolBar setBackgroundImage:[[UIImage alloc] init] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    [self.footToolBar setBackgroundImage:[[UIImage alloc] init] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    [self.undoButton setEnabled:FALSE];
    [self.redoButton setEnabled:FALSE];
    // [self.prevPageButton setEnabled:FALSE];
    // [self hidden:self.hiddenButton];
    
    self.captionTextView.textColor = [UIColor blackColor];
    [[self.captionTextView layer] setBorderColor:[[UIColor grayColor] CGColor]];
    [[self.captionTextView layer] setBorderWidth:2];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateButtonStatus
{
    self.undoButton.enabled = [self.drawingView canUndo];
    self.redoButton.enabled = [self.drawingView canRedo];
}

- (IBAction)undo:(UIBarButtonItem *)sender
{
    [self.drawingView undoLatestStep];
    [self updateButtonStatus];
}

- (IBAction)redo:(UIBarButtonItem *)sender
{
    [self.drawingView redoLatestStep];
    [self updateButtonStatus];
}

-(void)initBarButtonItem
{
    [self.undoButton setImage:[UIImage imageNamed:@"undo.png"]];
    [self.redoButton setImage:[UIImage imageNamed:@"redo.png"]];
    [self.toolButton setImage:toolImage];
    [self.colorButton setImage:[UIImage imageNamed:@"colour_picker.png"]];
    [self.eraserButton setImage:[UIImage imageNamed:@"eraser.png"]];
    [self.voiceButton setImage:[UIImage imageNamed:@"gnome_media_record.png"]];
    self.playButton.enabled = NO;
}

- (IBAction)hidden:(UIButton *)sender
{
    if (!self.footToolBar.hidden) /* hidden */
    {
        [sender setImage:[UIImage imageNamed:@"round_checkmark.png"] forState:UIControlStateNormal];
        /*
         [self.undoButton setImage:nil];
         [self.redoButton setImage:nil];
         [self.toolButton setImage:nil];
         [self.colorButton setImage:nil];
         [self.eraserButton setImage:nil];
         [self.voiceButton setImage:nil];
         */
        self.headToolBar.hidden = YES;
        self.footToolBar.hidden = YES;
        
    }
    else
    {
        [sender setImage:[UIImage imageNamed:@"round_minus.png"] forState:UIControlStateNormal];
        self.headToolBar.hidden = NO;
        self.footToolBar.hidden = NO;
        
    }
}

- (IBAction)tool:(UIBarButtonItem *)sender
{
    if (!focusOnEraserButton)   // now focus on toolButton
    {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:@"Cancel"
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:@"Pen", @"Line",
                                      @"Rect (Stroke)", @"Rect (Fill)",
                                      @"Ellipse (Stroke)", @"Ellipse (Fill)",
                                      nil];
        
        [actionSheet setTag:ActionSheetTool];
        [actionSheet showInView:self.view];
    } else {
        focusOnEraserButton = FALSE;
        self.drawingView.drawTool = currentTool;
        self.colorButton.enabled = TRUE;
    }
    
}

- (IBAction)color:(UIBarButtonItem *)sender
{
    if (!focusOnEraserButton)
    {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:@"Cancel"
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:@"Black", @"Red", @"Green", @"Blue", @"Cyan", @"Yellow", @"Orange", @"Purple", @"Brown", @"Gray", nil];
        
        [actionSheet setTag:ActionSheetColor];
        [actionSheet showInView:self.view];
    } else {
        focusOnEraserButton = FALSE;
        self.drawingView.lineColor = currentColor;
    }
    
}

- (IBAction)eraser:(UIBarButtonItem *)sender
{
    if (focusOnEraserButton)  // the second time users click eraserButton
    {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:@"Cancel"
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:@"Clear Page!", nil];
        
        [actionSheet setTag:ActionSheetEraser];
        [actionSheet showInView:self.view];
        
        focusOnEraserButton = FALSE;
        
        // recover to current tool
        self.drawingView.drawTool = currentTool;
        self.colorButton.enabled = TRUE;
        
    } else {
        self.drawingView.drawTool = ACEDrawingToolTypeEraser;
        focusOnEraserButton = YES;
        self.colorButton.enabled = FALSE;
    }
}

- (void)clear
{
    [self.drawingView clear];
    [self updateButtonStatus];
    
}




#pragma mark - ACEDrawing View Delegate

- (void)drawingView:(ACEDrawingView *)view didEndDrawUsingTool:(id<ACEDrawingTool>)tool;
{
    [self updateButtonStatus];
}

#pragma mark - Action Sheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.cancelButtonIndex != buttonIndex) {
        if (actionSheet.tag == ActionSheetColor) {
            
            self.colorButton.title = [actionSheet buttonTitleAtIndex:buttonIndex];
            switch (buttonIndex) {
                case 0:
                    currentColor = [UIColor blackColor];
                    break;
                    
                case 1:
                    currentColor = [UIColor redColor];
                    break;
                    
                case 2:
                    currentColor = [UIColor greenColor];
                    break;
                    
                case 3:
                    currentColor = [UIColor blueColor];
                    break;
                case 4:
                    currentColor = [UIColor cyanColor];
                    break;
                case 5:
                    currentColor = [UIColor yellowColor];
                    break;
                case 6:
                    currentColor = [UIColor orangeColor];
                    break;
                case 7:
                    currentColor = [UIColor purpleColor];
                    break;
                case 8:
                    currentColor = [UIColor brownColor];
                    break;
                case 9:
                    currentColor = [UIColor grayColor];
                    break;
                    
            }
            self.drawingView.lineColor = currentColor;
            self.colorButton.tintColor = currentColor;
            
        } else if (actionSheet.tag == ActionSheetTool){
            
            self.toolButton.title = [actionSheet buttonTitleAtIndex:buttonIndex];
            switch (buttonIndex) {
                case 0:
                    currentTool = ACEDrawingToolTypePen;
                    toolImage = [UIImage imageNamed:@"pencil.png"];
                    break;
                    
                case 1:
                    currentTool = ACEDrawingToolTypeLine;
                    toolImage = [UIImage imageNamed:@"line.png"];
                    break;
                    
                case 2:
                    currentTool = ACEDrawingToolTypeRectagleStroke;
                    toolImage = [UIImage imageNamed:@"rectangle_unfilled.png"];
                    break;
                    
                case 3:
                    currentTool = ACEDrawingToolTypeRectagleFill;
                    toolImage = [UIImage imageNamed:@"rectangle.png"];
                    break;
                    
                case 4:
                    currentTool = ACEDrawingToolTypeEllipseStroke;
                    toolImage = [UIImage imageNamed:@"ellipse_unfilled.png"];
                    break;
                    
                case 5:
                    currentTool = ACEDrawingToolTypeEllipseFill;
                    toolImage = [UIImage imageNamed:@"ellipse.png"];
                    break;
                    
            }
            self.drawingView.drawTool = currentTool;
            [self.toolButton setImage:toolImage];
            
        } else if (actionSheet.tag == ActionSheetEraser){
            self.eraserButton.title = [actionSheet buttonTitleAtIndex:buttonIndex];
            switch (buttonIndex) {
                case 0:
                    [self clear];
                    break;
            }
            
        } else if (actionSheet.tag == ActionSheetCamera)
        {
            self.cameraButton.title = [actionSheet buttonTitleAtIndex:buttonIndex];
            switch (buttonIndex) {
                case 0:
                    [self useCamera:nil];
                    break;
                    
                case 1:
                    [self useCameraRoll:self.cameraButton];
                    break;
            }
        }
    }
}

/*
 - (void)addNewPage
 {
 CGFloat x = self.drawingView.frame.origin.x;
 CGFloat y = self.drawingView.frame.origin.y;
 CGFloat w = self.drawingView.frame.size.width;
 CGFloat h = self.drawingView.frame.size.height;
 NSLog(@"%f,%f,%f,%f", x, y, w, h);
 
 self.drawingView = [[ACEDrawingView alloc] initWithFrame:CGRectMake(x, y, w, h)];
 }
 
 - (void)saveCurrentPage
 {
 [book addObject:self.drawingView];
 }
 
 - (ACEDrawingView *)getNextPage
 {
 return [book objectAtIndex:indexOfPage];
 }
 
 - (IBAction)prevPage:(id)sender
 {
 if (indexOfPage > 0)
 {
 indexOfPage--;
 }
 
 if (indexOfPage <= 0)
 {
 self.prevPageButton.enabled = FALSE;
 }
 NSLog(@"%d", indexOfPage);
 }
 - (IBAction)nextPage:(id)sender
 {
 indexOfPage++;
 
 if (indexOfPage >= [book count])
 {
 [self saveCurrentPage];
 [self initPage];
 [self addNewPage];
 } else {
 ACEDrawingView * tmp = (ACEDrawingView *)[self getNextPage];
 self.drawingView = tmp;
 }
 
 self.prevPageButton.enabled = TRUE;
 NSLog(@"%d", indexOfPage);
 }
 */

- (IBAction)camera:(UIBarButtonItem *)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Take Photo", @"Camera Roll", nil];
    
    [actionSheet setTag:ActionSheetCamera];
    [actionSheet showInView:self.view];
}

- (IBAction)saveFile:(UIBarButtonItem *)sender
{
    UIImageWriteToSavedPhotosAlbum(self.drawingView.image, nil, nil, nil);
    self.saveFileButton.image = [UIImage imageNamed:@"floppy_disk.png"];
    // change it back 2 second
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_current_queue(), ^{
        self.saveFileButton.image = [UIImage imageNamed:@"save_file.png"];
    });
}

- (IBAction)email:(UIBarButtonItem *)sender
{
    // prepare for sending email
    self.imageForSendingEmail = self.drawingView.image;
    self.captionForEmail = self.captionTextView.text;

    //*******************load locally store audio file********************//
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *audioUrl = [NSString stringWithFormat:@"%@/audioRecord.m4a", documentsDirectory];
    self.pathOfAudioRecord = audioUrl;
    NSLog(@"%@", audioUrl);
    
    // get the audio data from main bundle directly into NSData object
    NSData *audioData;
    audioData = [[NSData alloc] initWithContentsOfFile:audioUrl];
    
    
    // hard code send email
    [self sendMsg];
}

- (IBAction)toggleAlphaSlide:(UIBarButtonItem *)sender
{
    self.widthSlide.hidden = YES;
    self.alphaSlide.hidden = !self.alphaSlide.hidden;
    
}

- (IBAction)toggleWidthSlide:(UIBarButtonItem *)sender
{
    self.alphaSlide.hidden = YES;
    self.widthSlide.hidden = !self.widthSlide.hidden;
}

- (IBAction)changeAlpha:(UISlider *)sender
{
    self.drawingView.lineAlpha = sender.value;
}

- (IBAction)changeWidth:(UISlider *)sender
{
    self.drawingView.lineWidth = sender.value;
}

- (IBAction)caption:(UIBarButtonItem *)sender
{
    self.captionTextView.hidden = !self.captionTextView.hidden;
}



-(IBAction) useCamera:(id)sender{
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.mediaTypes = [NSArray arrayWithObjects:(NSString *) kUTTypeImage, nil];
        imagePicker.allowsEditing = NO;
        [self presentViewController:imagePicker animated:YES completion:nil];
        newMedia = YES;
        
        // NSLog(@"ok");
    }
}

-(IBAction) useCameraRoll:(id)sender{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picker animated:YES completion:NULL];
    
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if([mediaType isEqualToString:(NSString *)kUTTypeImage]){
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        if([popoverController isPopoverVisible]){
            [popoverController dismissPopoverAnimated:YES];
            [self.drawingView loadImage:image];
        } else {
            if(newMedia)
                UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:finishSavingWithError:contextInfo: ), nil);
            [self dismissViewControllerAnimated:YES completion: nil];
            [self.drawingView loadImage:image];
            
        }
    }
}

-(void)image:(UIImage *)image finishSavingWithError:(NSError *)error contextInfo:(void *) contextInfo {
    if(error) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Save Failed"
                              message: @"Failed to save"
                              delegate: nil
                              cancelButtonTitle:@"ok"
                              otherButtonTitles: nil];
        // NSLog(@"ok");
        [self.drawingView loadImage:image];
        [alert show];
    }
    
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion: nil];
}

- (IBAction)recordVoice:(UIBarButtonItem *)sender
{
    recorded = YES;
    /*
     if (!recording)
     {
     [sender setImage:[UIImage imageNamed:@"media_stop.png"]];
     recording = TRUE;
     self.playButton.enabled = NO;
     
     }
     else
     {
     [sender setImage:[UIImage imageNamed:@"gnome_media_record.png"]];
     recording = FALSE;
     self.playButton.enabled = YES;
     }
     */
    
    // Stop the audio player before recording
    if (player.playing) {
        [player stop];
    }
    
    if (!recorder.recording) {
        [sender setImage:[UIImage imageNamed:@"media_stop.png"]];
        self.playButton.enabled = NO;
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setActive:YES error:nil];
        
        // Start recording
        [recorder record];
        // [recordPauseButton setTitle:@"Pause" forState:UIControlStateNormal];
        
    } else {
        
        // stop recording
        [self stopRecord];
        // [recordPauseButton setTitle:@"Record" forState:UIControlStateNormal];
        
        [sender setImage:[UIImage imageNamed:@"gnome_media_record.png"]];
        self.playButton.enabled = YES;
    }
    
    //[stopButton setEnabled:YES];
    //[playButton setEnabled:NO];
}

- (void)stopRecord
{
    [recorder stop];
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];
}


- (IBAction)playRecord:(UIBarButtonItem *)sender
{
    if (playing)
    {
        self.playButton.image = [UIImage imageNamed:@"media_play.png"];
        // stop playing record
        [player stop];
        playing = NO;
    }
    else
    {
        self.playButton.image = [UIImage imageNamed:@"pause.png"];
        
        // play record
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:recorder.url error:nil];
        [player setDelegate:self];
        [player play];
        
        playing = YES;
    }
    
    
}

#pragma mark - AVAudioRecorderDelegate

- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)avrecorder successfully:(BOOL)flag
{
}

#pragma mark - AVAudioPlayerDelegate

- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    self.playButton.image = [UIImage imageNamed:@"media_play.png"];
    playing = NO;
}


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
    
    if ([text isEqualToString:@"\n"]) {
        
        [textView resignFirstResponder];
        // self.captionTextView.hidden = YES;
        // Return FALSE so that the final '\n' character doesn't get added
        return NO;
    }
    // For any other character return TRUE so that the text gets added to the view
    return YES;
}


- (void)textViewDidBeginEditing:(UITextView *)textView
{
    editing = YES;
    //NSLog(@"%f", self.captionTextView.center.x);
    //NSLog(@"%f", self.captionTextView.center.y);
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.4];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    
    CGAffineTransform scalTrans = CGAffineTransformMakeScale(1, 1);
    CGAffineTransform rotateTrans = CGAffineTransformMakeRotation(0);
    
    self.captionTextView.transform = CGAffineTransformConcat(scalTrans, rotateTrans);
    
    self.captionTextView.center = CGPointMake(160, 200);
    
    [UIView commitAnimations];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    editing = NO;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.4];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    
    CGAffineTransform scalTrans = CGAffineTransformMakeScale(1, 1);
    CGAffineTransform rotateTrans = CGAffineTransformMakeRotation(0);
    
    self.captionTextView.transform = CGAffineTransformConcat(scalTrans, rotateTrans);
    
    self.captionTextView.center = CGPointMake(160, 394);
    
    [UIView commitAnimations];
}

- (void)sendMsg
{
    //create Email Object
    sendgrid *msg = [sendgrid user:@"cprak" andPass:@"abcd1234"];
    
    //set parameters
    msg.subject = @"testing format";
    msg.to = @"huyle333@gmail.com";
    
    msg.from = @"bar@foo.com";
    msg.text = @"hello world";
    msg.html = @"<h1>hello world</h1>";
    if (recorded)
        msg.audioPath = self.pathOfAudioRecord;
    else
        msg.audioPath = nil;
    
    //**html message to use when setting inline photos as true**
    //msg.inlinePhoto = true;
    //msg.html = @"<img src =\"cid:image.png\"><h1>hello world</h1>";
    
    //adding unique arguments
    NSDictionary *uarg = @{@"customerAccountNumber":@"55555",
                           @"activationAttempt": @"1"};
    
    //adding categories
    NSString *replyto = @"billing_notifications";
    
    [msg addCustomHeader:uarg withKey:@"unique_args"];
    [msg addCustomHeader:replyto withKey:@"category"];
    
    //Image attachment
    [msg attachImage:self.imageForSendingEmail];
    
    
    //Send email through Web API Transport
    [msg sendWithWeb];
    // NSLog(@"OK");
}

@end
