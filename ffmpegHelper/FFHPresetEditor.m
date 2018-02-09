//
//  FFHPresetEditor.m
//  ffmpegHelper
//
//  Created by Terminator on 2018/02/06.
//  Copyright © 2018年 Terminator. All rights reserved.
//

#import "FFHPresetEditor.h"

extern NSString *FFHPresetNameKey;
extern NSString *FFHVideoOptionsKey;
extern NSString *FFHMiscOptionsKey;
extern NSString *FFHOtherOptionsKey;
extern NSString *FFHAudioOptionsKey;
extern NSString *FFHContainerKey;

const NSString *kFFHPresetsListFilePath = @"~/Library/ffmpegHelper/customPresets.plist";
const NSString *kFFHLocalReorderPboardType = @"FFHLocalPboardType";

#define cmd(x) _selectedPreset[x]

@interface FFHPresetEditor () <NSTableViewDelegate, NSTableViewDataSource> {
    IBOutlet NSTableView *_tableView;
    IBOutlet NSTextField *_nameTextField;
    IBOutlet NSTextField *_containerTextField;
    IBOutlet NSTextField *_videoTextField;
    IBOutlet NSTextField *_otherTextField;
    IBOutlet NSTextField *_audioTextField;
    IBOutlet NSTextField *_miscTextField;
    
    IBOutlet NSPanel *_presetsPanel;
    NSMutableArray *_presetsArray;
    NSDictionary *_selectedPreset;
    NSString *_presetsFilePath;
    
    NSIndexSet *_draggedRows;
}
- (IBAction)tableViewDoubleClickAction:(id)sender;
- (IBAction)duplicateButtonClicked:(id)sender;
- (IBAction)editButtonClicked:(id)sender;
- (IBAction)addPresetButtonClicked:(id)sender;
- (IBAction)removePresetButtonClicked:(id)sender;

- (IBAction)presetEditorOKButtonClicked:(id)sender;
- (IBAction)presetEditorCancelButtonClicked:(id)sender;
@end

@implementation FFHPresetEditor

- (instancetype)init {
    self = [super init];
    if (self) {
        _presetsFilePath = [kFFHPresetsListFilePath stringByExpandingTildeInPath];
        NSFileManager *fm = [NSFileManager defaultManager];
        if ([fm fileExistsAtPath:_presetsFilePath]) {
            _presetsArray = [[NSMutableArray alloc] initWithContentsOfFile:_presetsFilePath];
        } else {
            _presetsArray = [NSMutableArray new];
        }
    }
    return self;
}

- (NSString *)windowNibName {
    return self.className;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    [_tableView setDataSource:self];
    [_tableView registerForDraggedTypes:@[kFFHLocalReorderPboardType]];
    [_tableView setDraggingSourceOperationMask:NSDragOperationEvery forLocal:YES];
    _presetsPanel.floatingPanel = NO;
    //[_tableView setDraggingSourceOperationMask:NSDragOperationEvery forLocal:NO];
}

- (void)showPresetsListPanel {
    if (![self isWindowLoaded]) {
        (void)self.window;
    }
    [_presetsPanel makeKeyAndOrderFront:nil];
    [_tableView reloadData];
}

- (void)setUserPresets:(NSArray *)userPresets {
    _presetsArray = userPresets.mutableCopy;
}

- (NSArray *)userPresets {
    return _presetsArray;
}

- (void)showPresetEditor {
    if (_selectedPreset) {
        [self.window makeKeyAndOrderFront:nil];
        _nameTextField.stringValue = cmd(FFHPresetNameKey);
        _containerTextField.stringValue = cmd(FFHContainerKey);
        _videoTextField.stringValue = cmd(FFHVideoOptionsKey);
        _audioTextField.stringValue = cmd(FFHAudioOptionsKey);
        _miscTextField.stringValue = cmd(FFHMiscOptionsKey);
        _otherTextField.stringValue = cmd(FFHOtherOptionsKey);
    }
}

- (void)setPresetsFilePath:(NSString *)presetsFilePath {
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:presetsFilePath]) {
        _presetsArray = [[NSMutableArray alloc] initWithContentsOfFile:presetsFilePath];
    } else {
        _presetsArray = [NSMutableArray new];
    }
    _presetsFilePath = presetsFilePath;
    [_tableView reloadData];
}
- (NSString *)presetsFilePath {
    return _presetsFilePath;
}

#pragma mark - NSTableView DataSource

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row {
    NSDictionary *obj = nil;
    if (row < _presetsArray.count) {
        obj = _presetsArray[row];
    }
    return obj[FFHPresetNameKey];
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(nullable id)object forTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row {
    if (row < _presetsArray.count && object) {
        NSMutableDictionary *obj = [_presetsArray[row] mutableCopy];
        obj[FFHPresetNameKey] = object;
        [_presetsArray replaceObjectAtIndex:row withObject:obj.copy];
    }
}
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return _presetsArray.count;
}

#pragma mark - NSTableView Drag n Drop

- (BOOL)_dragIsLocalReorder:(id <NSDraggingInfo>)info {
    // It is a local drag if the following conditions are met:
    if ([info draggingSource] == _tableView) {
        // We were the source
        if (_draggedRows != nil) {
            // Our nodes were saved off
            if ([[info draggingPasteboard] availableTypeFromArray:@[kFFHLocalReorderPboardType]] != nil) {
                // Our pasteboard marker is on the pasteboard
                return YES;
            }
        }
    }
    return NO;
}

- (nullable id <NSPasteboardWriting>)tableView:(NSTableView *)tableView pasteboardWriterForRow:(NSInteger)row {
    if (row < _presetsArray.count) {
        return [_presetsArray objectAtIndex:row];
    }
    return nil;
}


- (void)tableView:(NSTableView *)tableView draggingSession:(NSDraggingSession *)session willBeginAtPoint:(NSPoint)screenPoint forRowIndexes:(NSIndexSet *)rowIndexes {
    _draggedRows = rowIndexes;
    [session.draggingPasteboard setData:[NSData data] forType:(NSString *)kFFHLocalReorderPboardType];
}

- (void)tableView:(NSTableView *)tableView draggingSession:(NSDraggingSession *)session endedAtPoint:(NSPoint)screenPoint operation:(NSDragOperation)operation {
    // If the session ended in the trash, then delete all the items
    if (operation == NSDragOperationDelete) {
        [_tableView beginUpdates];
        [_presetsArray.copy enumerateObjectsAtIndexes:_draggedRows options:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [_presetsArray removeObject:obj];
        }];
        [_tableView removeRowsAtIndexes:_draggedRows withAnimation:NSTableViewAnimationEffectFade];
        [_tableView endUpdates];
    }
    _draggedRows = nil;
}

- (NSDragOperation)tableView:(NSTableView *)tableView validateDrop:(id <NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)dropOperation {
     return NSDragOperationGeneric;
}

- (void)_performDragReorderWithDragInfo:(id <NSDraggingInfo>)info row:(NSInteger)row {
    // We will use the dragged nodes we saved off earlier for the objects we are actually moving
    NSAssert(_draggedRows != nil, @"_draggedRows should be valid");
    // We want to enumerate all things in the pasteboard. To do that, we use a generic NSPasteboardItem class
    NSArray *classes = @[[NSPasteboardItem class]];
    __block NSInteger insertionIndex = row;
    NSArray *draggedData = [_presetsArray objectsAtIndexes:_draggedRows];
    //[_presetsArray removeObjectsAtIndexes:_draggedRows];
    [info enumerateDraggingItemsWithOptions:0 forView:_tableView classes:classes searchOptions:@{} usingBlock:^(NSDraggingItem *draggingItem, NSInteger index, BOOL *stop) {
        
        id data = [draggedData objectAtIndex:index];
        [_presetsArray removeObject:data];
        
        if (insertionIndex > _presetsArray.count) {
            insertionIndex--; // account for the remove
        }
        [_presetsArray insertObject:data atIndex:insertionIndex];
        
        // Tell NSOutlineView about the insertion; let it leave a gap for the drop animation to come into place
        [_tableView insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:insertionIndex] withAnimation:NSTableViewAnimationEffectGap];
        insertionIndex++;
    }];
    [_tableView reloadData];
}

- (BOOL)tableView:(NSTableView *)tableView acceptDrop:(id <NSDraggingInfo>)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)dropOperation {
    // Group all insert or move animations together
    [_tableView beginUpdates];
    // If the source was ourselves, we use our dragged nodes and do a reorder
    if ([self _dragIsLocalReorder:info]) {
        [self _performDragReorderWithDragInfo:info row:row];
    } else {
        //[self _performInsertWithDragInfo:info row:row];
    }
    [_tableView endUpdates];
    // Return YES to indicate we were successful with the drop. Otherwise, it would slide back the drag image.
    return YES;
}

#pragma mark - IBAction methods

- (IBAction)tableViewDoubleClickAction:(id)sender {
    NSUInteger row = [_tableView clickedRow];
    if (row < _presetsArray.count) {
        _selectedPreset = _presetsArray[row];
        [self showPresetEditor];
    }
}

- (IBAction)duplicateButtonClicked:(id)sender {
    NSUInteger row = [_tableView selectedRow];
    if (row < _presetsArray.count) {
        NSMutableDictionary *obj = [_presetsArray[row] mutableCopy];
        NSString *name = obj[FFHPresetNameKey];
        obj[FFHPresetNameKey] = [NSString stringWithFormat:@"%@ (Copy)", name];
        [_presetsArray insertObject:obj.copy atIndex:row + 1];
        [_tableView reloadData];
    }
}

- (IBAction)editButtonClicked:(id)sender {
    NSUInteger row = [_tableView selectedRow];
    if (row < _presetsArray.count) {
        _selectedPreset = _presetsArray[row];
        [self showPresetEditor];
    }
}

- (IBAction)addPresetButtonClicked:(id)sender {
    NSDictionary *obj = @{FFHPresetNameKey: @"Empty Preset",
                          FFHContainerKey: @"",
                          FFHVideoOptionsKey: @"",
                          FFHAudioOptionsKey: @"",
                          FFHMiscOptionsKey: @"",
                          FFHOtherOptionsKey: @"", };
    NSUInteger row = [_tableView selectedRow];
    if (row < _presetsArray.count) {
        [_presetsArray insertObject:obj.copy atIndex:row + 1];
    } else {
       [_presetsArray addObject:obj];
    }
    [_tableView reloadData];
}

- (IBAction)removePresetButtonClicked:(id)sender {
     NSUInteger row = [_tableView selectedRow];
    if (row < _presetsArray.count) {
        [_presetsArray removeObjectAtIndex:row];
        [_tableView reloadData];
    }
}

- (IBAction)presetEditorOKButtonClicked:(id)sender {
    NSDictionary *obj = @{FFHPresetNameKey: _nameTextField.stringValue,
                          FFHContainerKey: _containerTextField.stringValue,
                          FFHVideoOptionsKey: _videoTextField.stringValue,
                          FFHAudioOptionsKey: _audioTextField.stringValue,
                          FFHMiscOptionsKey: _miscTextField.stringValue,
                          FFHOtherOptionsKey: _otherTextField.stringValue, };
    NSUInteger idx = [_presetsArray indexOfObject:_selectedPreset];
    if (idx != NSNotFound) {
        [_presetsArray replaceObjectAtIndex:idx withObject:obj];
    } else {
        [_presetsArray addObject:obj];
    }
    _selectedPreset = nil;
    [_tableView reloadData];
    [self.window close];
    [_presetsArray writeToFile:_presetsFilePath atomically:YES];
}

- (IBAction)presetEditorCancelButtonClicked:(id)sender {
    _selectedPreset = nil;
    [self.window close];
}
@end
