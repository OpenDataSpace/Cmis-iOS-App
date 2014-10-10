//
//  UploadFormViewController.m
//  ODS
//
//  Created by bdt on 9/21/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import "UploadFormViewController.h"
#import "FileUtils.h"

#import <MobileCoreServices/UTCoreTypes.h>
#import <MediaPlayer/MPMoviePlayerController.h>

#import "TextFieldTableViewCell.h"
#import "AudioRecorderTableViewCell.h"
#import "PhotoTableViewCell.h"
#import "VideoTableViewCell.h"

@interface UploadFormViewController ()
@property (nonatomic, copy) NSString    *viewTitle;
@property (nonatomic, strong) NSArray   *tableCells;

@property (nonatomic, weak) IBOutlet UIButton            *recordButton;
@property (nonatomic, weak) IBOutlet UIButton            *playButton;
@property (nonatomic, weak) IBOutlet UITextField         *nameTextField;
@property (nonatomic, strong) AVAudioPlayer     *player;
@property (nonatomic, strong) AVAudioRecorder	*recorder;
@property (nonatomic, assign) BOOL              recorded;

@property (nonatomic, copy) NSString        *recordPath;

@property (nonatomic, strong) MPMoviePlayerController   *videoPlayer;
@property (nonatomic, strong) VideoTableViewCell        *videoViewCell;

@end

@implementation UploadFormViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[self navigationItem] setTitle:[self viewTitle]];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed)];
    [self.navigationItem setLeftBarButtonItem:cancelButton];
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Upload", @"Upload")
                                                                   style:UIBarButtonItemStyleDone
                                                                  target:self
                                                                  action:@selector(saveButtonPressed)];
    [self.navigationItem setRightBarButtonItem:saveButton];

    if ([self.nameTextField text] == nil || [[self.nameTextField text] length] == 0) {
        [self.navigationItem.rightBarButtonItem setEnabled:NO];
    }
    
    if (self.multiUploadItems) {
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dismissViewControllerWithBlock:(void(^)(void))block
{
    if (self.presentedAsModal)
    {
        [self dismissViewControllerAnimated:YES completion:block];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
        if (block)
        {
            block();
        }
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void) createUpoadSingleItemForm:(UploadInfo*) info uploadType:(UploadFormType) type {
    [self setUploadType:info.uploadType];
    [self setUploadInfo:info];
    
    NSMutableArray *cellArr = [NSMutableArray array];
    
    TextFieldTableViewCell *nameCell =  (TextFieldTableViewCell*)[self createTableViewCellFromNib:@"TextFieldTableViewCell"];
    
    [[nameCell lblTitle] setText:NSLocalizedString(@"uploadview.tablecell.name.label", @"Name")];
    [[nameCell textField] setPlaceholder:NSLocalizedString(@"uploadview.tablecell.name.placeholder", @"Enter a name")];
    
    [self.nameTextField addTarget:self action:@selector(updateValue:) forControlEvents:UIControlEventEditingChanged];
    [self.nameTextField setDelegate:self];
    self.nameTextField = nameCell.textField;
    
    if ([info filename] != nil) {
        [self.nameTextField setText:[info completeFileName]];
    }
    
    [cellArr addObject:nameCell];
    
    if (type == UploadFormTypeAudio) {  //Upload Audio
        self.viewTitle = NSLocalizedString(@"upload.audio.view.title", @"Upload Audio");
        //set file extension
        [self.uploadInfo setExtension:[[self AACTempFileName] pathExtension]];
        AudioRecorderTableViewCell *recorderCell = (AudioRecorderTableViewCell*)[self createTableViewCellFromNib:@"AudioRecorderTableViewCell"];
        
        [[recorderCell lableTitle] setText:NSLocalizedString(@"uploadview.tablecell.audio.label", @"Audio")];
        
        self.recordButton = recorderCell.buttonRecord;
        self.playButton = recorderCell.buttonPlay;
        
        [self.playButton setTitle:NSLocalizedString(@"audiorecord.play", @"Play") forState:UIControlStateNormal];
        [self.recordButton setTitle:NSLocalizedString(@"audiorecord.record", @"Record") forState:UIControlStateNormal];
        [self.recordButton addTarget:self action:@selector(recordButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.playButton addTarget:self action:@selector(playButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        [cellArr addObject:recorderCell];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearAudioSession) name:UIApplicationWillResignActiveNotification object:nil];
    }else if (type == UploadFormTypePhoto) { //Upload Photo
        self.viewTitle = NSLocalizedString(@"upload.photo.view.title", @"Upload Photo");
        
        PhotoTableViewCell *photoCell = (PhotoTableViewCell*)[self createTableViewCellFromNib:@"PhotoTableViewCell"];
        [photoCell.lblTitle setText:NSLocalizedString(@"uploadview.tablecell.photo.label", @"Photo")];
        ALAsset *asset = assetFromURL([[self uploadInfo] uploadFileURL]);
        if (asset == nil) {
            ODSLogError(@"Load alasset with url %@ failed.", [[[self uploadInfo] uploadFileURL] absoluteString]);
        }else {
            [[photoCell imgThumbnal] setImage:[UIImage imageWithCGImage:[[asset defaultRepresentation] fullResolutionImage]]];
        }
        
        [cellArr addObject:photoCell];
    }else if (type == UploadFormTypeDocument) { //Upload Document
        self.viewTitle = NSLocalizedString(@"upload.document.view.title", @"Upload Document");
    }else if (type == UploadFormTypeVideo) { //Upload Video
        self.viewTitle = NSLocalizedString(@"upload.video.view.title", @"Upload Video");
        
        VideoTableViewCell *videoCell = (VideoTableViewCell*)[self createTableViewCellFromNib:@"VideoTableViewCell"];
        
        [videoCell.labelTitle setText:NSLocalizedString(@"uploadview.tablecell.video.label", @"Video")];
        self.videoViewCell = videoCell;
        
        self.videoPlayer = [[MPMoviePlayerController alloc] init];
        self.videoPlayer.controlStyle = MPMovieControlStyleNone;
        self.videoPlayer.contentURL = [self.uploadInfo uploadFileURL];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoNaturalSizeAvailable:) name:MPMoviePlayerLoadStateDidChangeNotification object:self.videoPlayer];
        
        [self.videoPlayer prepareToPlay];
        
        [cellArr addObject:videoCell];
    }
    
    self.tableCells = cellArr;
}

- (void) createUploadMultiItemsForm:(NSArray*) uploadItems uploadType:(UploadFormType) type {
    [self setUploadType:type];
    [self setMultiUploadItems:uploadItems];
    
    NSMutableArray *cellArr = [NSMutableArray array];
    
    TextFieldTableViewCell *nameCell =  (TextFieldTableViewCell*)[self createTableViewCellFromNib:@"TextFieldTableViewCell"];
    
    [[nameCell lblTitle] setText:NSLocalizedString([self uploadTypeCellLabel:self.uploadType], @"")];
    [[nameCell textField] setText:[self multipleItemsDetailLabel]];
    [[nameCell textField] setBorderStyle:UITextBorderStyleNone];
    [[nameCell textField] setEnabled:NO];
    
    [cellArr addObject:nameCell];
    
    self.tableCells = cellArr;
}

- (NSString *)multipleItemsDetailLabel
{
    NSMutableDictionary *counts = [NSMutableDictionary dictionaryWithCapacity:3];
    for(UploadInfo *anUploadInfo in self.multiUploadItems)
    {
        NSInteger count = [[counts objectForKey:[NSNumber numberWithInt:anUploadInfo.uploadType]] intValue];
        count++;
        [counts setObject:[NSNumber numberWithInt:count] forKey:[NSNumber numberWithInt:anUploadInfo.uploadType]];
    }
    
    BOOL first = YES;
    NSString *label = [NSString string];
    for(NSNumber *type in [counts allKeys])
    {
        NSInteger typeCount = [[counts objectForKey:type] intValue];
        NSString *comma = nil;
        if(!first)
        {
            comma = @", ";
        }
        else
        {
            comma = [NSString string];
            first = NO;
        }
        
        
        BOOL plural = typeCount > 1;
        NSString *mediaType = [UploadInfo typeDescription:[type intValue] plural:plural];
        label = [NSString stringWithFormat:@"%@%@%d %@", label, comma, typeCount, mediaType];
    }
    return label;
}

- (NSString *)uploadTypeCellLabel: (UploadFormType) type
{
    NSString *label = nil;
    switch (type)
    {
        case UploadFormTypeDocument:
            label = @"uploadview.tablecell.document.label";
            break;
            
        case UploadFormTypeVideo:
            label = @"uploadview.tablecell.video.label";
            break;
            
        case UploadFormTypeAudio:
            label = @"uploadview.tablecell.audio.label";
            break;
            
        case UploadFormTypeLibrary:
            label = @"uploadview.tablecell.library.label";
            break;
            
        case UploadFormTypeMultipleDocuments:
            label = @"uploadview.tablecell.multiple.label";
            break;
            
        default:
            label = @"uploadview.tablecell.photo.label";
            break;
    }
    return label;
}

#pragma mark - 
#pragma mark UITableView Datasource & Delegate

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.tableCells) {
        return [self.tableCells count];
    }
    
    return 0;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.tableCells) {
        return [self.tableCells objectAtIndex:indexPath.row];
    }
    return nil;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [self.tableCells objectAtIndex:indexPath.row];
    if ([cell isKindOfClass:[PhotoTableViewCell class]] || [cell isKindOfClass:[VideoTableViewCell class]]) {
        return 176.0;
    }    
    
    return 44.0;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableCells objectAtIndex:indexPath.row];
    if ([cell isKindOfClass:[VideoTableViewCell class]]) {
        if ([self.videoPlayer playbackState] == MPMoviePlaybackStatePlaying) {
            [self.videoPlayer pause];
        }
        else {
            [self.videoPlayer play];
        }
    }
}

#pragma mark -
#pragma mark Audio Record Actions

- (NSString*) AACTempFileName {
    return [NSString stringWithFormat:@"%@.m4a",[[self uploadInfo] uuid]];
}

- (void) clearAudioSession {
    if(self.recorder && self.recorder.isRecording) {
        [self.recorder stop];
        self.recorder = nil;
        
        [[AVAudioSession sharedInstance] setActive: NO error: nil];
        [self.recordButton setTitle:NSLocalizedString(@"audiorecord.record", @"Record") forState:UIControlStateNormal];
        
        self.playButton.enabled = YES;
        
        self.recorded = YES;
    }
    
    if(self.player && self.player.isPlaying) {
        [self.player stop];
        self.player = nil;
        
        [[AVAudioSession sharedInstance] setActive: NO error: nil];
        [self.playButton setTitle:NSLocalizedString(@"audiorecord.play", @"Play") forState:UIControlStateNormal];
        self.recordButton.enabled = YES;
    }
}

-(void)stopRecording {
    //If we try to release the recorder in a background thread we get a memory error
    self.recorder = nil;
    [self.recordButton setTitle:NSLocalizedString(@"audiorecord.record", @"Record") forState:UIControlStateNormal];
    self.playButton.enabled = YES;
    self.recorded = YES;
    
    //update upload information
    [self.uploadInfo setUploadFileURL:[NSURL URLWithString:self.recordPath]];
    [self.uploadInfo setUploadDate:[NSDate date]];
    [self.recordButton setEnabled:YES];
    
    [self checkReadyToUpload];
}

-(void)changeRecordLabel:(NSString *)recordLabel {
    [self.recordButton setTitle:recordLabel forState:UIControlStateNormal];
    [self.recordButton setNeedsDisplay];
}

-(void)changePlayLabel:(NSString *)playLabel {
    [self.playButton setTitle:playLabel forState:UIControlStateNormal];
    [self.playButton setNeedsDisplay];
}

- (IBAction)recordButtonPressed:(id) sender {
    if(self.recorder && self.recorder.isRecording) {
        [self.recorder stop];
        [[AVAudioSession sharedInstance] setActive: NO error: nil];
        [self performSelectorOnMainThread:@selector(stopRecording) withObject:nil waitUntilDone:NO];
    } else {
        NSError *error = nil;
        [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryRecord error: &error];
        if(error) {
            ODSLogDebug(@"Error trying to start audio session: %@", error.localizedDescription);
            return;
        }
        
        self.recordPath = [FileUtils pathToTempFile:[self AACTempFileName]];
        NSDictionary *recordSettings =
        [[NSDictionary alloc] initWithObjectsAndKeys:
         [NSNumber numberWithFloat: 44100.0], AVSampleRateKey,
         [NSNumber numberWithInt: kAudioFormatMPEG4AAC], AVFormatIDKey,
         [NSNumber numberWithInt: 1], AVNumberOfChannelsKey,
         [NSNumber numberWithInt: AVAudioQualityMax],
         AVEncoderAudioQualityKey,
         nil];
        
        AVAudioRecorder *newRecorder =
        [[AVAudioRecorder alloc] initWithURL: [NSURL fileURLWithPath:self.recordPath]
                                    settings: recordSettings
                                       error: &error];
        
        self.recorder = newRecorder;
        
        if(error) {
            //[recordButton useRedDeleteStyle];
            ODSLogDebug(@"Error trying to record audio: %@", error.description);
            [[AVAudioSession sharedInstance] setActive: NO error: nil];
        } else {
            self.recorder.delegate = self;
            [self.recorder prepareToRecord];
            [self.recorder record];
            
            self.playButton.enabled = NO;
            [self performSelectorOnMainThread:@selector(changeRecordLabel:) withObject:NSLocalizedString(@"audiorecord.stop", @"Stop") waitUntilDone:NO];
        }
        
        [self.recordButton setEnabled:YES];
    }
    
}

- (IBAction) playButtonPressed:(id) sender {
    NSURL *audioURL = [NSURL URLWithString:self.recordPath]; //audio url path
    
    if(self.player && self.player.isPlaying) {
        [self.player stop];
        self.player = nil;
        
        [[AVAudioSession sharedInstance] setActive: NO error: nil];
        [self performSelectorOnMainThread:@selector(changePlayLabel:) withObject:NSLocalizedString(@"audiorecord.play", @"Play") waitUntilDone:NO];
        self.recordButton.enabled = YES;
        //[((IFGenericTableViewController *)tableController) updateAndRefresh];
    } else if([[NSFileManager defaultManager] fileExistsAtPath:[audioURL path]]) {
        NSError *error = nil;
        [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: &error];
        if(error) {
            ODSLogDebug(@"Error trying to start audio session: %@", error.localizedDescription);
            [self.playButton setEnabled:YES];
            return;
        }
        
        AVAudioPlayer *newPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audioURL error:&error];
        newPlayer.delegate = self;
        self.player = newPlayer;
        
        if(error) {
            ODSLogDebug(@"Error trying to play audio: %@", error.description);
        } else {
            [self performSelectorOnMainThread:@selector(changePlayLabel:) withObject:NSLocalizedString(@"audiorecord.stop", @"Stop") waitUntilDone:NO];
            self.recordButton.enabled = NO;
            [self.player play];
            [self.recordButton setNeedsDisplay];
        }
    }
    
    [self.playButton setEnabled:YES];
}

#pragma mark - AVAudioPlayerDelegate methods
- (void) audioPlayerDidFinishPlaying: (AVAudioPlayer *) player
                        successfully: (BOOL) completed {
    if (completed == YES) {
        [self.playButton setTitle:NSLocalizedString(@"audiorecord.play", @"Play") forState:UIControlStateNormal];
        [self.playButton setNeedsDisplay];
        self.player = nil;
        self.recordButton.enabled = YES;
    }
}

-(void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player
                                error:(NSError *)error {
    ODSLogDebug(@"Decode Error occurred");
}

#pragma mark - AVAudioRecorderDelegate methods
-(void)audioRecorderDidFinishRecording: (AVAudioRecorder *)recorder successfully:(BOOL)flag{
}

-(void)audioRecorderEncodeErrorDidOccur:
(AVAudioRecorder *)recorder
                                  error:(NSError *)error
{
    ODSLogDebug(@"Encode Error occurred");
}

#pragma mark -
#pragma mark UITextFieldDelegate
- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self resignFirstResponder];
    return YES;
}

- (void)updateValue:(id)sender {
    self.fileName = [sender text];
    
    [self checkReadyToUpload];
}

- (void) checkReadyToUpload {
    BOOL bInvalid = YES;
    
    if (self.uploadType == UploadFormTypeAudio && !self.recorded) {
        bInvalid = NO;
    }
    
    if (![self validateName:self.fileName]) {
        bInvalid = NO;
    }
    
    [self.navigationItem.rightBarButtonItem setEnabled:bInvalid];
}

#pragma mark -
#pragma mark Upload Utility

- (BOOL)isMultiUpload
{
    return self.uploadType == UploadFormTypeMultipleDocuments || self.uploadType == UploadFormTypeLibrary;
}

- (BOOL)validateName:(NSString *)name
{
    name = [name trimWhiteSpace];
    NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"?/\\:*?\"<>|#"];
    
    return [self isMultiUpload] || (![name isEqualToString:[NSString string]] && [name rangeOfCharacterFromSet:set].location == NSNotFound);
}

- (BOOL)saveSingleUpload
{
    if(![self validateName:self.fileName])
    {
        displayErrorMessageWithTitle(NSLocalizedString(@"uploadview.name.invalid.message", @"Invalid characters in name"), NSLocalizedString(@"uploadview.name.invalid.title", @""));
        
        return NO;
    }
    
    //If have no file name or source file url
    if (!self.uploadInfo.uploadFileURL || (self.fileName == nil || [self.fileName length] == 0))
    {
        displayErrorMessageWithTitle(NSLocalizedString(@"uploadview.required.fields.missing.dialog.message", @"Please fill in all required fields"), NSLocalizedString(@"uploadview.required.fields.missing.dialog.title", @""));
        
        return NO;
    }
    
    [self startHUD];
    
    // Need to determine the final filename before calling the update action
    // We remove the extension if the user typed it
    if ([[self.fileName pathExtension] isEqualToString:self.uploadInfo.extension])
    {
        self.fileName = [self.fileName stringByDeletingPathExtension];
    }
    [self.uploadInfo setFilename:self.fileName];
    
    void (^uploadBlock)(void) = ^
    {
        [[UploadsManager sharedManager] queueUpload:self.uploadInfo];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self stopHUD];
        });
    };
    
    //Async experience when uploading any document
    [self dismissViewControllerWithBlock:^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), uploadBlock);
    }];
    
    return YES;
}

- (BOOL)saveMultipleUpload {
    [self startHUD];
    
    [self dismissViewControllerWithBlock:^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[UploadsManager sharedManager] queueUploadArray:self.multiUploadItems];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self stopHUD];
            });
        });
    }];
    
    return YES;
}

#pragma mark - 
#pragma mark MovieControllerInternal
CGFloat const kVGutter = 20.0f;
CGFloat const kVideoHeight = 176.0f;

- (void)videoNaturalSizeAvailable:(NSNotification *)notification
{
    MPMoviePlayerController *notifyingPlayer = notification.object;
    
    // Query the video's size
    CGSize videoSize = [notifyingPlayer naturalSize];
    CGFloat aspectRatio = videoSize.width / (videoSize.height + 0.1f);
    
    // Resize frame to fit
    CGFloat height = kVideoHeight - kVGutter;
    CGFloat offsetX = self.videoViewCell.videoView.frame.size.width - height * aspectRatio;
    CGFloat videoViewPosX = offsetX > 0?offsetX:0;
    CGRect newFrame = CGRectMake(videoViewPosX, 0.0f, height * aspectRatio, height);
    
    [notifyingPlayer.view setFrame:newFrame];
    
    [self.videoViewCell.videoView addSubview:notifyingPlayer.view];
}


#pragma mark -
#pragma mark Button Handler

- (void)cancelButtonPressed
{
    ODSLogDebug(@"UploadFormTableViewController: Cancelled");
    
    if([self.uploadInfo uploadStatus] == UploadInfoStatusFailed)
    {
        [[UploadsManager sharedManager] clearUpload:[self.uploadInfo uuid]];
    }
    [self dismissViewControllerWithBlock:NULL];
}

- (void)saveButtonPressed
{
    ODSLogDebug(@"UploadFormTableViewController: Upload");
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    if ([self isMultiUpload])
    {
        [self saveMultipleUpload];
    }
    else
    {
        if (self.nameTextField.text && [self.nameTextField.text length] > 0) {
            [self setFileName:self.nameTextField.text];
        }
        [self saveSingleUpload];
    }
}

@end
