//
//  FFHPresetItem.m
//  ffmpegHelper
//
//  Created by Terminator on 2018/02/21.
//  Copyright © 2018年 Terminator. All rights reserved.
//

#import "FFHPresetItem.h"

@implementation FFHPresetItem

- (instancetype)init {
    self = [super init];
    if (self) {
        _name = @"Empty";
        _videoOptions = @"";
        _audioOptions = @"";
        _miscOptions = @"";
        _otherOptions = @"";
        _container = @"";
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    FFHPresetItem *itm = [[FFHPresetItem alloc] init];
    itm.name = _name.copy;
    itm.videoOptions = _videoOptions.copy;
    itm.audioOptions = _audioOptions.copy;
    itm.miscOptions = _miscOptions.copy;
    itm.otherOptions = _otherOptions.copy;
    itm.container = _container.copy;
    return itm;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@: \n"
                                    @"        Name: %@\n"
                                    @"VideoOptions: %@\n"
                                    @"AudioOptions: %@\n"
                                    @"OtherOptions: %@\n"
                                    @" MiscOptions: %@\n"
                                    @"   Container: %@",
                                    super.description, _name, _videoOptions, _audioOptions, _otherOptions, _miscOptions, _container];
}

- (NSDictionary *)dictionary {
#ifdef DEBUG
    NSLog(@"%s\nDescription: %@", __PRETTY_FUNCTION__, self.description);
    NSString *s = @"";
    return @{FFHPresetNameKey: (_name) ? _name : s,
             FFHVideoOptionsKey: (_videoOptions) ? _videoOptions : s,
             FFHMiscOptionsKey: (_miscOptions) ? _miscOptions : s,
             FFHOtherOptionsKey: (_otherOptions) ? _otherOptions : s,
             FFHAudioOptionsKey: (_audioOptions) ? _audioOptions : s,
             FFHContainerKey: (_container) ? _container : s};
#else
    return @{FFHPresetNameKey: _name,
             FFHVideoOptionsKey: _videoOptions,
             FFHMiscOptionsKey:_miscOptions,
             FFHOtherOptionsKey:_otherOptions,
             FFHAudioOptionsKey: _audioOptions,
             FFHContainerKey: _container};
#endif
}

- (void)setDictionary:(NSDictionary *)d {
    _name = d[FFHPresetNameKey];
    _videoOptions = d[FFHVideoOptionsKey];
    _audioOptions = d[FFHAudioOptionsKey];
    _miscOptions = d[FFHMiscOptionsKey];
    _otherOptions = d[FFHOtherOptionsKey];
    _container = d[FFHContainerKey];
#ifdef DEBUG
     NSLog(@"%s\nDescription: %@", __PRETTY_FUNCTION__, self.description);
#endif
}

#pragma mark - NSPasteboardWriting support


- (NSArray *)writableTypesForPasteboard:(NSPasteboard *)pasteboard {
    NSArray *ourTypes = @[NSPasteboardTypeString];
    return ourTypes;
}

- (NSPasteboardWritingOptions)writingOptionsForType:(NSString *)type pasteboard:(NSPasteboard *)pasteboard {
    return 0;
}

- (id)pasteboardPropertyListForType:(NSString *)type {
    if ([type isEqualToString:NSPasteboardTypeString]) {
        return _name;
    } else {
        return nil;
    }
}


#pragma mark - NSPasteboardReading support

+ (NSArray *)readableTypesForPasteboard:(NSPasteboard *)pasteboard {
    // We allow creation from URLs so Finder items can be dragged to us
    return @[(id)kUTTypeURL, NSPasteboardTypeString];
}

+ (NSPasteboardReadingOptions)readingOptionsForType:(NSString *)type pasteboard:(NSPasteboard *)pasteboard {
    if ([type isEqualToString:NSPasteboardTypeString] || UTTypeConformsTo((__bridge CFStringRef)type, kUTTypeURL)) {
        return NSPasteboardReadingAsString;
    } else {
        return NSPasteboardReadingAsData;
    }
}

- (instancetype)initWithPasteboardPropertyList:(id)propertyList ofType:(NSString *)type {
    // See if an NSURL can be created from this type
    if (UTTypeConformsTo((__bridge CFStringRef)type, kUTTypeURL)) {
        // It does, so create a URL and use that to initialize our properties
        NSURL *url = [[NSURL alloc] initWithPasteboardPropertyList:propertyList ofType:type];
        self = [self init];
        _name = [url lastPathComponent];
        // Make sure we have a name
        if (_name == nil) {
            _name = [url path];
            if (_name == nil) {
                _name = @"Untitled";
            }
        }
        
        // See if the URL was a container; if so, make us marked as a container too
        //        NSNumber *value;
        //        if ([url getResourceValue:&value forKey:NSURLIsDirectoryKey error:NULL] && [value boolValue]) {
        //            _list = YES;
        //            _children = @[];
        //        } else {
        //
        //            _address = [url absoluteString];
        //
        //        }
        
    } else if ([type isEqualToString:NSPasteboardTypeString]) {
        self = [self init];
        _name = propertyList;
        
        // self.selectable = YES;
    } else {
        NSAssert(NO, @"internal error: type not supported");
    }
    return self;
}

@end
