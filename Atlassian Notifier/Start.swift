//
//  Start.swift
//  Atlassian Notifier
//
//  Created by Matthias Bertsch.
//  Copyright © 2020 Matthias Bertsch. All rights reserved.
//

import Cocoa

class Start : NSObject {

    @available(macOS, deprecated: 10.11)
    let items : LSSharedFileList = LSSharedFileListCreate(nil, kLSSharedFileListSessionLoginItems.takeRetainedValue(), nil).takeRetainedValue();

    @available(macOS, deprecated: 10.11)
    func add(_ path: CFURL) -> Bool {
        if self.get(path) != nil {
            return true;
        }
        
        let items : NSArray = LSSharedFileListCopySnapshot(self.items, nil).takeRetainedValue() as NSArray;
        var last : LSSharedFileListItem;
        
        if items.count > 0 {
            last = items.lastObject as! LSSharedFileListItem;
        } else {
            last = kLSSharedFileListItemBeforeFirst.takeRetainedValue();
        }

        if LSSharedFileListInsertItemURL(self.items, last, nil, nil, path, nil, nil) != nil {
            return true;
        } else {
            return false;
        }
    }

    @available(macOS, deprecated: 10.11)
    func remove(_ path: CFURL) -> Bool {
        if let old = get(path) {
            if LSSharedFileListItemRemove(self.items, old) == noErr {
                return true;
            } else {
                return false;
            }
        }
        
        return true;
    }

    @available(macOS, deprecated: 10.11)
    func get(_ path : CFURL) -> LSSharedFileListItem! {
        let items : NSArray = LSSharedFileListCopySnapshot(self.items, nil).takeRetainedValue();
        
        var item : LSSharedFileListItem?;
        var next : Unmanaged<CFURL>?;

        for i in (0 ..< items.count) {
            if LSSharedFileListItemResolve((items.object(at: i) as! LSSharedFileListItem), 0, &next, nil) == noErr {
                if next!.takeRetainedValue() == path {
                    item = (items.object(at: i) as! LSSharedFileListItem);
                }
            }
        }

        return item;
    }

}
