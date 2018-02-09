//
//  AppDelegate.m
//  ffmpegHelper
//
//  Created by Terminator on 2018/01/08.
//  Copyright © 2018年 Terminator. All rights reserved.
//

#include <sys/types.h>
#include <sys/stat.h>

#import "FFHAppDelegate.h"
#import "FFHFileInfo.h"
#import "FFHMetadataEditor.h"
#import "FFHPresetEditor.h"


#define DEFAULTS_KEY @"ffmpegOptions"

#define cmd(x) _ffmpegCmdOptions[x]

#pragma mark - FFDragView Class

@protocol FFHDragViewDelegate <NSObject>

- (void)didRecieveFilename:(NSString *)filename;
- (void)didBeginDraggingSession;
- (void)didEndDraggingSession;

@end

@interface FFHDragView : NSView {
    BOOL _draggingFeedback;
    NSColor *_feedbackColor;
    NSColor *_feedbackLineColor;
    NSColor *_clearColor;
    NSRect _feedbackFrame;
    NSBezierPath *_feedbackPath;
}


@property id <FFHDragViewDelegate> delegate;

@end

@implementation FFHDragView

- (instancetype)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self _setUp];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self _setUp];
    }
    return self;
}

- (void)_setUp {
    [self registerForDraggedTypes:@[NSFilenamesPboardType]];
    [NSBezierPath setDefaultLineWidth:0.32];
    _feedbackColor = [NSColor colorWithCalibratedWhite:0.0 alpha:0.04];
    _feedbackLineColor = [NSColor colorWithCalibratedWhite:0.0 alpha:0.48];
    _clearColor = [NSColor clearColor];
 /*   _feedbackFrame = self.bounds;
    _feedbackFrame.origin.x +=20;
    _feedbackFrame.size.width -= 40;
    _feedbackFrame.origin.y += 4;
    _feedbackFrame.size.height -= 8;
    _feedbackPath = [NSBezierPath bezierPathWithRoundedRect:_feedbackFrame xRadius:4 yRadius:4]; */
}

- (void)drawRect:(NSRect)dirtyRect {
    if (_draggingFeedback) {
        [_feedbackColor setFill];
        [_feedbackLineColor setStroke];
    } else {
        [_clearColor set];
    }

    NSRect bounds = self.bounds;
    bounds.origin.x +=20;
    bounds.size.width -= 40;
    bounds.origin.y += 4;
    bounds.size.height -= 8;
    _feedbackPath = [NSBezierPath bezierPathWithRoundedRect:bounds xRadius:4 yRadius:4];
    [_feedbackPath fill];
    [_feedbackPath stroke];

}


- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender {
    NSPasteboard *pboard;
    NSDragOperation sourceDragMask;
    
    sourceDragMask = [sender draggingSourceOperationMask];
    pboard = [sender draggingPasteboard];
    
    if ([pboard.types containsObject:NSFilenamesPboardType] && sourceDragMask & NSDragOperationGeneric) {
        _draggingFeedback = YES;
        [self setNeedsDisplay:YES];
        [_delegate didBeginDraggingSession];
        return NSDragOperationGeneric;
    }
    return NSDragOperationNone;
}

- (void)draggingExited:(id<NSDraggingInfo>)sender {
    _draggingFeedback = NO;
    [self setNeedsDisplay:YES];
    [_delegate didEndDraggingSession];
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender {
    NSPasteboard *pboard;
    NSDragOperation sourceDragMask;
    BOOL result = NO;
    
    sourceDragMask = [sender draggingSourceOperationMask];
    pboard = [sender draggingPasteboard];
    
    if ([pboard.types containsObject:NSFilenamesPboardType] && sourceDragMask & NSDragOperationGeneric) {
        NSArray *files = [pboard propertyListForType:NSFilenamesPboardType];
        [_delegate didRecieveFilename:files.firstObject];
        result = YES;
    }
    _draggingFeedback = NO;
    [self setNeedsDisplay:YES];
    [_delegate didEndDraggingSession];
    
    
    return result;
}

@end

#pragma mark - FFHAppDelegate Class

const NSString *FFHTwoPassCommandString = @"ffmpeg $START -i \"$INPUT\" $VFLAGS -pass 1 $LENGTH -an -f null -";
const NSString *FFHCommandString = @"ffmpeg $START -i \"$INPUT\" $VFLAGS $AFLAGS $OFLAGS $MFLAGS %@ $TWOPASS $LENGTH \"$OUTPUT\"";

const NSString *FFHPresetNameKey = @"Name";
const NSString *FFHVideoOptionsKey = @"Video";
const NSString *FFHMiscOptionsKey = @"Misc";
const NSString *FFHOtherOptionsKey = @"Other";
const NSString *FFHAudioOptionsKey = @"Audio";
const NSString *FFHStartTimeKey = @"StartTime";
const NSString *FFHEndTimeKey = @"EndTime";
const NSString *FFHLengthTimeKey = @"LengthTime";
const NSString *FFHContainerKey = @"Container";

const NSString *FFHMenuTwoPassKey = @"TwoPassEncoding";

const NSString *FFHUserPresetPath = @"~/Library/Application Support/ffmpegHelper/userPreset.plist";

extern NSString *kFFHPresetsListFilePath;

typedef NS_ENUM(NSUInteger, FFHMenuOptionTag) {
    FFHMenuOption2PassTag,
};


@interface FFHAppDelegate () <FFHDragViewDelegate, FFHMetadaEditorDelegate, NSMenuDelegate> {
    IBOutlet FFHDragView *_dragView;
    IBOutlet NSTextField *_filePathTextField;
    IBOutlet NSTextField *_outputFilePathTextField;
    IBOutlet NSTextField *_videoOptionsTextField;
    IBOutlet NSTextField *_miscOptionsTextField;
    IBOutlet NSTextField *_otherOptionsTextField;
    IBOutlet NSTextField *_audioOptionsTextField;
    IBOutlet NSTextField *_startTimeTextField;
    IBOutlet NSTextField *_endTimeTextField;
    IBOutlet NSTextField *_lengthTimeTextField;
    IBOutlet NSTextView *_commandTextView;
    IBOutlet NSView *_baseView;
    
    IBOutlet NSTextField *_dropFileFeedbackTextField;

    NSMutableDictionary *_ffmpegCmdOptions;
    BOOL _twoPassEncoding;
    
    FFHFileInfo *_fileInfoWindow;
    FFHMetadataEditor *_metadataEditorWindow;
    FFHPresetEditor *_presetEditor;
    
    NSString *_scriptPath;
    NSMutableString *_convertScript;
    NSDictionary *_mpvOptions;
    NSAppleScript *_appleScript;
    NSArray *_defaultMenuItems;
}

- (IBAction)outputFilePathTextFieldChanged:(NSTextField *)sender;
- (IBAction)videoOptionsTextFieldChanged:(NSTextField *)sender;
- (IBAction)miscOptionsTextFieldChanged:(NSTextField *)sender;
- (IBAction)otherOptionsTextFieldChanged:(NSTextField *)sender;
- (IBAction)audioOptionsTextFieldChanged:(NSTextField *)sender;
- (IBAction)startTimeTextFieldChanged:(NSTextField *)sender;
- (IBAction)endTimeTextFieldChanged:(NSTextField *)sender;
- (IBAction)lengthTimeTextFieldChanged:(NSTextField *)sender;
- (IBAction)getInfoMenuItemClicked:(id)sender;
- (IBAction)playInputMenuItemClicked:(id)sender;
- (IBAction)playOutputMenuItemClicked:(id)sender;
- (IBAction)editMetadataMenuItemClicked:(id)sender;


@property (weak) IBOutlet NSWindow *window;
@end

@implementation FFHAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSFileManager *shared = [NSFileManager defaultManager];
    NSURL *appSupp = [shared URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask].firstObject;
    appSupp = [appSupp URLByAppendingPathComponent:@"ffmpegHelper" isDirectory:YES];
    NSString *path = appSupp.path;
    
    if (![shared fileExistsAtPath:path]) {
        
        [shared createDirectoryAtURL:appSupp withIntermediateDirectories:NO attributes:nil error:nil];
    }
    _scriptPath = [path stringByAppendingPathComponent:@"command.sh"];
    if (![shared fileExistsAtPath:_scriptPath]) {
        [shared createFileAtPath:_scriptPath contents:nil attributes:nil];
        chmod(_scriptPath.UTF8String,  S_IRWXU);
    }
    _convertScript = [[NSMutableString alloc] initWithContentsOfFile:_scriptPath encoding:NSUTF8StringEncoding error:nil];
    
    {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"runScript" ofType:@"scpt"];
        NSString *string = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        string = [string stringByReplacingOccurrencesOfString:@"%script%" withString:_scriptPath];
        _appleScript = [[NSAppleScript alloc] initWithSource:string];
    }
    _mpvOptions = @{NSWorkspaceLaunchConfigurationArguments:@[@"--loop=yes", @"--osd-fractions", @"--osd-level=3", path].mutableCopy};
    
    _ffmpegCmdOptions = [[[NSUserDefaults standardUserDefaults] objectForKey:DEFAULTS_KEY] mutableCopy];
    if (!_ffmpegCmdOptions) {
        NSString *other, *nt = [NSString stringWithFormat:@"-threads %lu", [NSProcessInfo processInfo].processorCount];
        other = [NSString stringWithFormat:@"-trellis 1 -me_range 16 -i_qfactor 0.71 -b_strategy 1 -qmax 50 -qmin 0 -qdiff 4 -sn -y %@", nt];
        _ffmpegCmdOptions = @{FFHVideoOptionsKey: @"-c:v libvpx-vp9  -b:v 2100k -bt 1280k -maxrate 5200k -bufsize 3200k",
                              FFHAudioOptionsKey: @"-c:a libvorbis -b:a 128k -aq 9",
                              FFHOtherOptionsKey: other,
                              FFHMiscOptionsKey: @"",
                              FFHStartTimeKey: @"",
                              FFHEndTimeKey: @"",
                              FFHLengthTimeKey: @"",
                              FFHContainerKey: @"webm"}.mutableCopy;
    }
    _videoOptionsTextField.stringValue = cmd(FFHVideoOptionsKey);
    _audioOptionsTextField.stringValue = cmd(FFHAudioOptionsKey);
    _miscOptionsTextField.stringValue = cmd(FFHMiscOptionsKey);
    _otherOptionsTextField.stringValue = cmd(FFHOtherOptionsKey);
    _startTimeTextField.stringValue = cmd(FFHStartTimeKey);
    _endTimeTextField.stringValue = cmd(FFHEndTimeKey);
    _lengthTimeTextField.stringValue = cmd(FFHLengthTimeKey);
    
    {
        SEL action = @selector(optionsMenuItemClicked:);
        NSMenu *menu = [NSApp.mainMenu itemWithTag:1000].submenu;
        NSMenuItem *item;
        item = [[NSMenuItem alloc] initWithTitle:@"Two Pass Encoding" action:action keyEquivalent:@""];
        item.tag = FFHMenuOption2PassTag;
        _twoPassEncoding = [[NSUserDefaults standardUserDefaults] boolForKey:(NSString *)FFHMenuTwoPassKey];
        item.state = _twoPassEncoding;
        [menu addItem:item];
        

        //action = @selector(presetsMenuItemClicked:);
        NSMenu *presetsMenu = [NSApp.mainMenu itemWithTag:1001].submenu;
        presetsMenu.delegate = self;
        
//        for (NSDictionary *obj in presets) {
//            item = [[NSMenuItem alloc] initWithTitle:obj[@"Name"] action:action keyEquivalent:@""];
//            item.target = self;
//            item.representedObject = obj;
//            [presetsMenu addItem:item];
//        }
        [presetsMenu addItem:[NSMenuItem separatorItem]];
        item = [[NSMenuItem alloc] initWithTitle:@"Edit Presets" action:@selector(editPresetsMenuItemClicked:) keyEquivalent:@""];
        item.target = self;
        [presetsMenu addItem:item];
        [presetsMenu addItem:[NSMenuItem separatorItem]];
        item = [[NSMenuItem alloc] initWithTitle:@"Quick Save Preset" action:@selector(saveUserPresetMenuItemClicked:) keyEquivalent:@""];
        item.target = self;
        [presetsMenu addItem:item];
        
        item = [[NSMenuItem alloc] initWithTitle:@"Load Preset" action:@selector(loadUserPresetMenuItemClicked:) keyEquivalent:@""];
        item.target = self;
        [presetsMenu addItem:item];
        _defaultMenuItems = presetsMenu.itemArray;
    }
    
    _dragView.delegate = self;
    _dropFileFeedbackTextField.hidden = YES;
    _fileInfoWindow = [[FFHFileInfo alloc] init];
    _metadataEditorWindow = [[FFHMetadataEditor alloc] init];
    _metadataEditorWindow.delegate = self;
    _presetEditor = [[FFHPresetEditor alloc] init];
    
    NSArray *presets;
    NSString *presetsPath = [kFFHPresetsListFilePath stringByExpandingTildeInPath];
    if ([shared fileExistsAtPath:presetsPath]) {
        presets = [[NSArray alloc] initWithContentsOfFile:presetsPath];
    } else {
        presets = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"presets" ofType:@"plist"]];
        _presetEditor.userPresets = presets;
    }
    
    // IB checkboxes do nothing
    _commandTextView.automaticDataDetectionEnabled = NO;
    _commandTextView.automaticLinkDetectionEnabled = NO;
    _commandTextView.automaticTextReplacementEnabled = NO;
    _commandTextView.automaticDashSubstitutionEnabled = NO;
    _commandTextView.automaticQuoteSubstitutionEnabled = NO;
    _commandTextView.automaticSpellingCorrectionEnabled = NO;
    
    [self _updateCommandTextView];
}

- (void)editPresetsMenuItemClicked:(id)sender {
    [_presetEditor showPresetsListPanel];
}

#pragma mark - NSMenuDelegate

- (void)menuNeedsUpdate:(NSMenu *)menu {
    [menu removeAllItems];
    SEL action = @selector(presetsMenuItemClicked:);
    NSArray *presets = _presetEditor.userPresets;
    NSMenuItem *item = nil;
    for (NSDictionary *obj in presets) {
        item = [[NSMenuItem alloc] initWithTitle:obj[@"Name"] action:action keyEquivalent:@""];
        item.target = self;
        item.representedObject = obj;
        [menu addItem:item];
    }
    for (NSMenuItem *itm in _defaultMenuItems) {
        [menu addItem:itm];
    }
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    [[NSUserDefaults standardUserDefaults] setBool:_twoPassEncoding forKey:(NSString *)FFHMenuTwoPassKey];
    [[NSUserDefaults standardUserDefaults] setObject:_ffmpegCmdOptions forKey:DEFAULTS_KEY];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

- (void)_updateCommandTextView {
    NSString *string, *twopass = @"";
    if (_twoPassEncoding) {
        twopass = @"-pass 2";
        string = [NSString stringWithFormat:@"%@\n%@\n", FFHTwoPassCommandString, FFHCommandString];
    } else {
        string = [NSString stringWithFormat:@"%@\n", FFHCommandString];
    }
    NSString *command = [NSString stringWithFormat:
                         @"INPUT=\"%@\"\n"
                         @"OUTPUT=\"%@\"\n"
                         @"VFLAGS=\"%@\"\n"
                         @"AFLAGS=\"%@\"\n"
                         @"OFLAGS=\"%@\"\n"
                         @"MFLAGS=\"%@\"\n"
                         @"START=\"%@\"\n"
                         @"LENGTH=\"%@\"\n"
                         @"TWOPASS=\"%@\"\n"
                         @"%@\n",
                         _filePathTextField.stringValue, _outputFilePathTextField.stringValue, cmd(FFHVideoOptionsKey),
                         cmd(FFHAudioOptionsKey),cmd(FFHOtherOptionsKey), cmd(FFHMiscOptionsKey), cmd(FFHStartTimeKey),
                         cmd(FFHLengthTimeKey), twopass, string];
    _commandTextView.string = [NSString stringWithFormat:command, _metadataEditorWindow.metadata];
}

- (void)_updateDraggingFeedback {

    BOOL feedback;
    BOOL textFields;
    if (_dropFileFeedbackTextField.hidden) {
        feedback = NO;
        textFields = YES;
    } else {
        feedback = YES;
        textFields = NO;
    }
    _baseView.hidden = textFields;
    _dropFileFeedbackTextField.hidden = feedback;
}

- (void)_playWithMpv:(NSString *)path {
    NSWorkspace *sharedWorkspace = [NSWorkspace sharedWorkspace];
    NSURL *appURL = [sharedWorkspace URLForApplicationWithBundleIdentifier:@"io.mpv"];
    if (appURL) {
        NSError *error = nil;
        NSMutableArray *args = _mpvOptions[NSWorkspaceLaunchConfigurationArguments];
        args[3] = path;
        [sharedWorkspace launchApplicationAtURL:appURL
                                        options:NSWorkspaceLaunchAsync | NSWorkspaceLaunchNewInstance
                                  configuration:_mpvOptions
                                          error:&error];
        if (error) {
            NSLog(@"%s - App: %@\nError: %@", __PRETTY_FUNCTION__, appURL, error.localizedDescription);
        }
    } else {
        NSString *cmd = [NSString stringWithFormat:@"/usr/local/bin/mpv --loop=yes --osd-fractions --osd-level=3 \"%@\" &", path];
        const char *str = cmd.UTF8String;
        if (str) {
            system(str);
        }
    }
}

#pragma mark - FFHDragViewDelegate

- (void)didRecieveFilename:(NSString *)filename {
    if (filename) {
        _metadataEditorWindow.filepath = filename;
         filename = [filename stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
        _filePathTextField.stringValue = filename;
        NSString *container = cmd(FFHContainerKey);
        time_t t = 0;
        time(&t);
        struct tm  stm;
        struct tm *p = &stm;
        p = localtime(&t);
        stm = *p;
        NSString *suffix = [NSString stringWithFormat:@"-%i%.2i%.2i-%.2i%.2i%.2i",
                            stm.tm_year + 1900, stm.tm_mon + 1, stm.tm_mday, stm.tm_hour, stm.tm_min, stm.tm_sec];
        NSString *ext = filename.pathExtension;
        filename = filename.stringByDeletingPathExtension;
        filename = [filename stringByAppendingString:suffix];
        
        if (container.length) {
            filename = [filename stringByAppendingPathExtension:container];
        } else {
            filename = [filename stringByAppendingPathExtension:ext];
        }
        _outputFilePathTextField.stringValue = filename;
        [[NSDocumentController sharedDocumentController] noteNewRecentDocumentURL:[NSURL fileURLWithPath:filename]];
        
    }
    [self _updateCommandTextView];
}

- (void)didBeginDraggingSession {
    [self _updateDraggingFeedback];
}

- (void)didEndDraggingSession {
    [self _updateDraggingFeedback];
}

#pragma mark - FFHMetadataEditorDelegate

- (void)metadataDidChange {
    [self _updateCommandTextView];
}

#pragma mark - IBActions

- (IBAction)outputFilePathTextFieldChanged:(NSTextField *)sender {
    [self _updateCommandTextView];
}

- (IBAction)videoOptionsTextFieldChanged:(NSTextField *)sender {
    cmd(FFHVideoOptionsKey) = sender.stringValue;
    [self _updateCommandTextView];
}

- (IBAction)miscOptionsTextFieldChanged:(NSTextField *)sender {
    cmd(FFHMiscOptionsKey) = sender.stringValue;
    [self _updateCommandTextView];
}

- (IBAction)otherOptionsTextFieldChanged:(NSTextField *)sender {
    cmd(FFHOtherOptionsKey) = sender.stringValue;
    [self _updateCommandTextView];
}

- (IBAction)audioOptionsTextFieldChanged:(NSTextField *)sender {
    cmd(FFHAudioOptionsKey) = sender.stringValue;
    [self _updateCommandTextView];
}

- (IBAction)startTimeTextFieldChanged:(NSTextField *)sender {
    cmd(FFHStartTimeKey) = sender.stringValue;
    [self _updateCommandTextView];
}

- (IBAction)endTimeTextFieldChanged:(NSTextField *)sender {
    cmd(FFHEndTimeKey) = sender.stringValue;
    double end = sender.floatValue;
    NSString *startString = _startTimeTextField.stringValue;
    NSUInteger length = startString.length;
    if (length > 3) {
        NSRange range = NSMakeRange(3, startString.length - 3);
        double start = [startString substringWithRange:range].floatValue;
        _lengthTimeTextField.stringValue = [NSString stringWithFormat:@"-t %.3f", end - start];
        [self lengthTimeTextFieldChanged:_lengthTimeTextField];
    }
}

- (IBAction)lengthTimeTextFieldChanged:(NSTextField *)sender {
    cmd(FFHLengthTimeKey) = sender.stringValue;
    [self _updateCommandTextView];
}

- (IBAction)getInfoMenuItemClicked:(id)sender {
    
    NSString *path = _filePathTextField.stringValue;
    if (path.length) {
        [_fileInfoWindow.window makeKeyAndOrderFront:nil];
        [_fileInfoWindow showFileInfo:_filePathTextField.stringValue];
    } else {
        NSBeep();
    }
}

- (IBAction)playInputMenuItemClicked:(id)sender {
     NSString *path = _filePathTextField.stringValue;
    if (path.length) {
        [self _playWithMpv:path];
    } else {
        NSBeep();
    }
}

- (IBAction)playOutputMenuItemClicked:(id)sender {
    NSString *path = _outputFilePathTextField.stringValue;
    if (path.length) {
        [self _playWithMpv:path];
    } else {
        NSBeep();
    }
}

- (IBAction)editMetadataMenuItemClicked:(id)sender {
    [_metadataEditorWindow showWindow:sender];
}

- (IBAction)runScriptMenuItemClicked:(id)sender {
    [_convertScript replaceCharactersInRange:NSMakeRange(0, _convertScript.length) withString:_commandTextView.string];
    [_convertScript writeToFile:_scriptPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    [_appleScript executeAndReturnError:nil];
}

#pragma mark - Options Menu Action

- (void)optionsMenuItemClicked:(NSMenuItem *)sender {
    NSUInteger tag = sender.tag;
    BOOL state = sender.state ? NO : YES;
    sender.state = state;
    switch (tag) {
        case FFHMenuOption2PassTag:
            _twoPassEncoding = state;
            
            break;
        default:
            break;
    }
    [self _updateCommandTextView];
}

#pragma mark - Presets Menu Actions

- (void)loadUserPresetMenuItemClicked:(id)sender {
    NSString *path = FFHUserPresetPath.stringByExpandingTildeInPath;
    NSDictionary *obj = [[NSDictionary alloc] initWithContentsOfFile:path];
    if (obj) {
        NSString *outfile = [_outputFilePathTextField.stringValue stringByDeletingPathExtension];
        NSString *temp = obj[FFHContainerKey];
        if (temp.length && outfile.length) {
            _outputFilePathTextField.stringValue = [outfile stringByAppendingPathExtension:temp];
            cmd(FFHContainerKey) = temp;
        }
        temp = obj[FFHVideoOptionsKey];
        _videoOptionsTextField.stringValue = temp;
        cmd(FFHVideoOptionsKey) = temp;
        
        temp = obj[FFHAudioOptionsKey];
        _audioOptionsTextField.stringValue = temp;
        cmd(FFHAudioOptionsKey) = temp;
        
        temp = obj[FFHMiscOptionsKey];
        _miscOptionsTextField.stringValue = temp;
         cmd(FFHMiscOptionsKey) = temp;
        
        temp = obj[FFHOtherOptionsKey];
        _otherOptionsTextField.stringValue = temp;
        cmd(FFHOtherOptionsKey) = temp;
        
        [self _updateCommandTextView];
    } else {
        NSBeep();
    }
}

- (void)saveUserPresetMenuItemClicked:(id)sender {
    NSString *path = FFHUserPresetPath.stringByExpandingTildeInPath;
    NSDictionary *preset = @{FFHVideoOptionsKey: _videoOptionsTextField.stringValue,
                             FFHAudioOptionsKey: _audioOptionsTextField.stringValue,
                             FFHOtherOptionsKey: _otherOptionsTextField.stringValue,
                             FFHMiscOptionsKey: _miscOptionsTextField.stringValue,
                             FFHContainerKey: cmd(FFHContainerKey)};
    [preset writeToFile:path atomically:YES];
}

- (void)presetsMenuItemClicked:(NSMenuItem *)sender {
    NSDictionary *obj = sender.representedObject;
    NSString *outfile = [_outputFilePathTextField.stringValue stringByDeletingPathExtension];
    NSString *temp = obj[FFHContainerKey];
    if (temp.length) {
        _outputFilePathTextField.stringValue = [outfile stringByAppendingPathExtension:temp];
        cmd(FFHContainerKey) = temp;
    }
    
    temp = obj[FFHVideoOptionsKey];
    _videoOptionsTextField.stringValue = temp;
    cmd(FFHVideoOptionsKey) = temp;
    
    temp = obj[FFHAudioOptionsKey];
    _audioOptionsTextField.stringValue = temp;
    cmd(FFHAudioOptionsKey) = temp;
    
    temp = obj[FFHMiscOptionsKey];
    _miscOptionsTextField.stringValue = temp;
    cmd(FFHMiscOptionsKey) = temp;
    
    temp = obj[FFHOtherOptionsKey];
    _otherOptionsTextField.stringValue = temp;
    cmd(FFHOtherOptionsKey) = temp;
    
    [self _updateCommandTextView];
}

#pragma mark - Open File

- (void)openDocument:(id)sender {
    [_window makeKeyAndOrderFront:nil];
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    
    [openPanel beginSheetModalForWindow:_window completionHandler:^(NSInteger result) {
        
        if (result == NSOKButton) {
            
            NSURL *url = openPanel.URL;
            [self didRecieveFilename:url.path];
        }
        
    }];
    openPanel = nil;
}

- (void)newDocument:(id)sender {
    [self openDocument:sender];
}

- (BOOL)application:(NSApplication *)sender openFile:(NSString *)filename {
    [_window makeKeyAndOrderFront:nil];
    [self didRecieveFilename:filename];
    
    return YES;
}


@end
