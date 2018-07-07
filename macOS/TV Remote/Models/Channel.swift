//
//  Channel.swift
//  TV Remote
//
//  Created by Bjarne Tvedten on 07.07.2018.
//  Copyright © 2018 Bjarne Tvedten. All rights reserved.
//

import Foundation

public enum Rating: Int {
    case exellent = 5
    case great = 4
    case good = 3
    case ok = 2
    case bad = 1
    case horrible = 0
}

struct Channel {
    private (set) public var _channelName: String
    private (set) public var _channelNumber: Int
    private (set) public var _channelImageName: String?
    private (set) public var _channelCategory: String?
    private (set) public var _channelURL: String?
    
    public var programGuide: [String:String]?
    public var programRunning: String?
    
    public var viewCount: Int?
    public var viewDate: Date?
    public var channelRating: Int?
    
    init(channelName: String, channelNumber: Int, channelImageName: String?, channelCategory: String?, channelURL: String?) {
        self._channelName = channelName
        self._channelNumber = channelNumber
        self._channelImageName = channelImageName
        self._channelCategory = channelCategory
        self._channelURL = channelURL
    }
    
}
