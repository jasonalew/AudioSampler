//
//  Constants.swift
//  AudioSampler
//
//  Created by Jason Lew on 12/10/16.
//  Copyright © 2016 Jason Lew. All rights reserved.
//

import Foundation

func dlog(items: Any, filePath: String = #file, function: String = #function) {
    let className = filePath.components(separatedBy: "/").last
    #if DEBUG
        Swift.print("\(className ?? "") - \(function) - \(items)")
    #endif
}
