//
//  RemoteCommand.swift
//  TV Remote
//
//  Created by Bjarne Tvedten on 01/02/2020.
//  Copyright © 2020 Digital Mood. All rights reserved.
//

import Foundation

enum RemoteCommand: String {

    // MARK: - Primary
    case power = "AAAAAQAAAAEAAAAVAw=="
    case powerOff = "AAAAAQAAAAEAAAAvAw=="
    case enter = "AAAAAgAAAJcAAABKAw=="
    case pictureOff = "AAAAAQAAAAEAAAA+Aw=="
    case input = "AAAAAQAAAAEAAAAlAw=="

    // MARK: - Settings
    case options = "AAAAAgAAAJcAAAA2Aw=="
    case actionMenu = "AAAAAgAAAMQAAABLAw=="
    case popUpMenu = "AAAAAgAAABoAAABhAw=="
    case topMenu = "AAAAAgAAABoAAABgAw=="
    case mode3d = "AAAAAgAAAHcAAABNAw=="
    case syncmenu = "AAAAAgAAABoAAABYAw=="

    // MARK: - Numbers
    case numberOne = "AAAAAQAAAAEAAAAAAw=="
    case numberTwo = "AAAAAQAAAAEAAAABAw=="
    case numberThree = "AAAAAQAAAAEAAAACAw=="
    case numberFour = "AAAAAQAAAAEAAAADAw=="
    case numberFive = "AAAAAQAAAAEAAAAEAw=="
    case numberSix = "AAAAAQAAAAEAAAAFAw=="
    case numberSeven = "AAAAAQAAAAEAAAAGAw=="
    case numberEight = "AAAAAQAAAAEAAAAHAw=="
    case numberNine = "AAAAAQAAAAEAAAAIAw=="
    case numberZero = "AAAAAQAAAAEAAAAJAw=="

    case dot = "AAAAAgAAAJcAAAAdAw=="
    case subtitle = "AAAAAgAAAJcAAAAoAw=="

    // MARK: Special
    case red = "AAAAAgAAAJcAAAAlAw=="
    case green = "AAAAAgAAAJcAAAAmAw=="
    case yellow = "AAAAAgAAAJcAAAAnAw=="
    case blue = "AAAAAgAAAJcAAAAkAw=="

    // MARK: Volume Control
    case volumeUp = "AAAAAQAAAAEAAAASAw=="
    case volumeDown = "AAAAAQAAAAEAAAATAw=="
    case mute = "AAAAAQAAAAEAAAAUAw=="

    // MARK: Playback Control
    case play = "AAAAAgAAAJcAAAAaAw=="
    case pause = "AAAAAgAAAJcAAAAZAw=="
    case stop = "AAAAAgAAAJcAAAAYAw=="
    case rewind = "AAAAAgAAAJcAAAAbAw=="
    case fastForward = "AAAAAgAAAJcAAAAcAw=="
    case next = "AAAAAgAAAJcAAAA9Aw=="
    case prev = "AAAAAgAAAJcAAAA8Aw=="

    // MARK: Navigation
    case up = "AAAAAgAAAJcAAABPAw=="
    case down = "AAAAAgAAAJcAAABQAw=="
    case left = "AAAAAgAAAJcAAABNAw=="
    case right = "AAAAAgAAAJcAAABOAw=="
    case netflix = "AAAAAgAAABoAAAB8Aw=="

    // MARK: TV / Channels
    case tv = "AAAAAQAAAAEAAAAkAw=="
    case channelUp = "AAAAAQAAAAEAAAAQAw=="
    case channelDown = "AAAAAQAAAAEAAAARAw=="
    case home = "AAAAAQAAAAEAAABgAw=="
    case back = "AAAAAgAAAJcAAAAjAw=="
    case confirm = "AAAAAQAAAAEAAABlAw=="
    case display = "AAAAAQAAAAEAAAA6Aw=="
    case guide = "AAAAAQAAAAEAAAAOAw=="
    case favorites = "AAAAAgAAAHcAAAB2Aw=="
    case digital = "AAAAAgAAAJcAAAAyAw=="
    case tvSatellite = "AAAAAgAAAMQAAABOAw=="
    case assists = "AAAAAgAAAMQAAAA7Aw=="
    case digitalToggle = "AAAAAgAAAHcAAABSAw=="
    case analog = "AAAAAgAAAHcAAAANAw=="
    case media = "AAAAAgAAAJcAAAA4Aw=="
    case onetouchview = "AAAAAgAAABoAAABlAw=="
    case jump = "AAAAAQAAAAEAAAA7Aw=="

    case dux = "AAAAAgAAABoAAABzAw=="   // TV Menu Under
    case footballMode = "AAAAAgAAABoAAAB2Aw=="
    case epg = "AAAAAgAAAKQAAABbAw=="   // Same as TV-Guide

    case _cs = "AAAAAgAAAJcAAAArAw=="
    case _bs = "AAAAAgAAAJcAAAAsAw=="
    case _ddata = "AAAAAgAAAJcAAAAVAw=="
    case _comp1 = "AAAAAgAAAKQAAAA2Aw=="
    case _comp2 = "AAAAAgAAAKQAAAA3Aw=="
    case _bscs = "AAAAAgAAAJcAAAAQAw=="
    case _ad = "AAAAAgAAABoAAAA7Aw=="
    case _androidMenu = "AAAAAgAAAMQAAABPAw=="

    case sleepTimer = "AAAAAQAAAAEAAAA2Aw=="

    case help = "AAAAAgAAAMQAAABNAw=="
    case pap = "AAAAAgAAAKQAAAB3Aw=="
    case tenKey = "AAAAAgAAAJcAAAAMAw=="

    var name: String {
        get { return String(describing: self) }
    }

}

extension RemoteCommand: CaseIterable {
    // Check Case Names
    init?(name: String) {
        for value in RemoteCommand.allCases where "\(value)" == name {
            self = value
            return
        }
        return nil
    }

    init?(channelNumber: Int?) {
        guard
            let number = channelNumber,
            String(number).count == 1
            else { return nil }

        switch number {
        case 1:
            self = .numberOne
        case 2:
            self = .numberTwo
        case 3:
            self = .numberThree
        case 4:
            self = .numberFour
        case 5:
            self = .numberFive
        case 6:
            self = .numberSix
        case 7:
            self = .numberSeven
        case 8:
            self = .numberEight
        case 9:
            self = .numberNine
        case 0:
            self = .numberZero
        default:
            return nil
        }
    }
}

extension RemoteCommand {
    func returnRemoteCommand(number: Int?) -> RemoteCommand? {
        guard
            let number = number
            else { return nil }

        switch number {
        case 1:
            return .numberOne
        case 2:
            return .numberTwo
        case 3:
            return .numberThree
        case 4:
            return .numberFour
        case 5:
            return .numberFive
        case 6:
            return .numberSix
        case 7:
            return .numberSeven
        case 8:
            return .numberEight
        case 9:
            return .numberNine
        case 0:
            return .numberZero
        default:
            return nil
        }
    }

    func returnRemoteCommand(string: String?) -> RemoteCommand? {
        guard
            let string = string,
            let command = RemoteCommand(name: string)
            else { return nil }

        return command
    }
}

/* Sony Bravia
{"result":[{"bundled":true,"type":"IR_REMOTE_BUNDLE_TYPE_AEP_N"},[{"name":"Num1","value":"AAAAAQAAAAEAAAAAAw=="},{"name":"Num2","value":"AAAAAQAAAAEAAAABAw=="},{"name":"Num3","value":"AAAAAQAAAAEAAAACAw=="},{"name":"Num4","value":"AAAAAQAAAAEAAAADAw=="},{"name":"Num5","value":"AAAAAQAAAAEAAAAEAw=="},{"name":"Num6","value":"AAAAAQAAAAEAAAAFAw=="},{"name":"Num7","value":"AAAAAQAAAAEAAAAGAw=="},{"name":"Num8","value":"AAAAAQAAAAEAAAAHAw=="},{"name":"Num9","value":"AAAAAQAAAAEAAAAIAw=="},{"name":"Num0","value":"AAAAAQAAAAEAAAAJAw=="},{"name":"Num11","value":"AAAAAQAAAAEAAAAKAw=="},{"name":"Num12","value":"AAAAAQAAAAEAAAALAw=="},{"name":"Enter","value":"AAAAAQAAAAEAAAALAw=="},{"name":"GGuide","value":"AAAAAQAAAAEAAAAOAw=="},{"name":"ChannelUp","value":"AAAAAQAAAAEAAAAQAw=="},{"name":"ChannelDown","value":"AAAAAQAAAAEAAAARAw=="},{"name":"VolumeUp","value":"AAAAAQAAAAEAAAASAw=="},{"name":"VolumeDown","value":"AAAAAQAAAAEAAAATAw=="},{"name":"Mute","value":"AAAAAQAAAAEAAAAUAw=="},{"name":"TvPower","value":"AAAAAQAAAAEAAAAVAw=="},{"name":"Audio","value":"AAAAAQAAAAEAAAAXAw=="},{"name":"MediaAudioTrack","value":"AAAAAQAAAAEAAAAXAw=="},{"name":"Tv","value":"AAAAAQAAAAEAAAAkAw=="},{"name":"Input","value":"AAAAAQAAAAEAAAAlAw=="},{"name":"TvInput","value":"AAAAAQAAAAEAAAAlAw=="},{"name":"TvAntennaCable","value":"AAAAAQAAAAEAAAAqAw=="},{"name":"WakeUp","value":"AAAAAQAAAAEAAAAuAw=="},{"name":"PowerOff","value":"AAAAAQAAAAEAAAAvAw=="},{"name":"Sleep","value":"AAAAAQAAAAEAAAAvAw=="},{"name":"Right","value":"AAAAAQAAAAEAAAAzAw=="},{"name":"Left","value":"AAAAAQAAAAEAAAA0Aw=="},{"name":"SleepTimer","value":"AAAAAQAAAAEAAAA2Aw=="},{"name":"Analog2","value":"AAAAAQAAAAEAAAA4Aw=="},{"name":"TvAnalog","value":"AAAAAQAAAAEAAAA4Aw=="},{"name":"Display","value":"AAAAAQAAAAEAAAA6Aw=="},{"name":"Jump","value":"AAAAAQAAAAEAAAA7Aw=="},{"name":"PicOff","value":"AAAAAQAAAAEAAAA+Aw=="},{"name":"PictureOff","value":"AAAAAQAAAAEAAAA+Aw=="},{"name":"Teletext","value":"AAAAAQAAAAEAAAA\/Aw=="},{"name":"Video1","value":"AAAAAQAAAAEAAABAAw=="},{"name":"Video2","value":"AAAAAQAAAAEAAABBAw=="},{"name":"AnalogRgb1","value":"AAAAAQAAAAEAAABDAw=="},{"name":"Home","value":"AAAAAQAAAAEAAABgAw=="},{"name":"Exit","value":"AAAAAQAAAAEAAABjAw=="},{"name":"PictureMode","value":"AAAAAQAAAAEAAABkAw=="},{"name":"Confirm","value":"AAAAAQAAAAEAAABlAw=="},{"name":"Up","value":"AAAAAQAAAAEAAAB0Aw=="},{"name":"Down","value":"AAAAAQAAAAEAAAB1Aw=="},{"name":"ClosedCaption","value":"AAAAAgAAAKQAAAAQAw=="},{"name":"Component1","value":"AAAAAgAAAKQAAAA2Aw=="},{"name":"Component2","value":"AAAAAgAAAKQAAAA3Aw=="},{"name":"Wide","value":"AAAAAgAAAKQAAAA9Aw=="},{"name":"EPG","value":"AAAAAgAAAKQAAABbAw=="},{"name":"PAP","value":"AAAAAgAAAKQAAAB3Aw=="},{"name":"TenKey","value":"AAAAAgAAAJcAAAAMAw=="},{"name":"BSCS","value":"AAAAAgAAAJcAAAAQAw=="},{"name":"Ddata","value":"AAAAAgAAAJcAAAAVAw=="},{"name":"Stop","value":"AAAAAgAAAJcAAAAYAw=="},{"name":"Pause","value":"AAAAAgAAAJcAAAAZAw=="},{"name":"Play","value":"AAAAAgAAAJcAAAAaAw=="},{"name":"Rewind","value":"AAAAAgAAAJcAAAAbAw=="},{"name":"Forward","value":"AAAAAgAAAJcAAAAcAw=="},{"name":"DOT","value":"AAAAAgAAAJcAAAAdAw=="},{"name":"Rec","value":"AAAAAgAAAJcAAAAgAw=="},{"name":"Return","value":"AAAAAgAAAJcAAAAjAw=="},{"name":"Blue","value":"AAAAAgAAAJcAAAAkAw=="},{"name":"Red","value":"AAAAAgAAAJcAAAAlAw=="},{"name":"Green","value":"AAAAAgAAAJcAAAAmAw=="},{"name":"Yellow","value":"AAAAAgAAAJcAAAAnAw=="},{"name":"SubTitle","value":"AAAAAgAAAJcAAAAoAw=="},{"name":"CS","value":"AAAAAgAAAJcAAAArAw=="},{"name":"BS","value":"AAAAAgAAAJcAAAAsAw=="},{"name":"Digital","value":"AAAAAgAAAJcAAAAyAw=="},{"name":"Options","value":"AAAAAgAAAJcAAAA2Aw=="},{"name":"Media","value":"AAAAAgAAAJcAAAA4Aw=="},{"name":"Prev","value":"AAAAAgAAAJcAAAA8Aw=="},{"name":"Next","value":"AAAAAgAAAJcAAAA9Aw=="},{"name":"DpadCenter","value":"AAAAAgAAAJcAAABKAw=="},{"name":"CursorUp","value":"AAAAAgAAAJcAAABPAw=="},{"name":"CursorDown","value":"AAAAAgAAAJcAAABQAw=="},{"name":"CursorLeft","value":"AAAAAgAAAJcAAABNAw=="},{"name":"CursorRight","value":"AAAAAgAAAJcAAABOAw=="},{"name":"ShopRemoteControlForcedDynamic","value":"AAAAAgAAAJcAAABqAw=="},{"name":"FlashPlus","value":"AAAAAgAAAJcAAAB4Aw=="},{"name":"FlashMinus","value":"AAAAAgAAAJcAAAB5Aw=="},{"name":"DemoMode","value":"AAAAAgAAAJcAAAB8Aw=="},{"name":"Analog","value":"AAAAAgAAAHcAAAANAw=="},{"name":"Mode3D","value":"AAAAAgAAAHcAAABNAw=="},{"name":"DigitalToggle","value":"AAAAAgAAAHcAAABSAw=="},{"name":"DemoSurround","value":"AAAAAgAAAHcAAAB7Aw=="},{"name":"*AD","value":"AAAAAgAAABoAAAA7Aw=="},{"name":"AudioMixUp","value":"AAAAAgAAABoAAAA8Aw=="},{"name":"AudioMixDown","value":"AAAAAgAAABoAAAA9Aw=="},{"name":"PhotoFrame","value":"AAAAAgAAABoAAABVAw=="},{"name":"Tv_Radio","value":"AAAAAgAAABoAAABXAw=="},{"name":"SyncMenu","value":"AAAAAgAAABoAAABYAw=="},{"name":"Hdmi1","value":"AAAAAgAAABoAAABaAw=="},{"name":"Hdmi2","value":"AAAAAgAAABoAAABbAw=="},{"name":"Hdmi3","value":"AAAAAgAAABoAAABcAw=="},{"name":"Hdmi4","value":"AAAAAgAAABoAAABdAw=="},{"name":"TopMenu","value":"AAAAAgAAABoAAABgAw=="},{"name":"PopUpMenu","value":"AAAAAgAAABoAAABhAw=="},{"name":"OneTouchTimeRec","value":"AAAAAgAAABoAAABkAw=="},{"name":"OneTouchView","value":"AAAAAgAAABoAAABlAw=="},{"name":"DUX","value":"AAAAAgAAABoAAABzAw=="},{"name":"FootballMode","value":"AAAAAgAAABoAAAB2Aw=="},{"name":"iManual","value":"AAAAAgAAABoAAAB7Aw=="},{"name":"Netflix","value":"AAAAAgAAABoAAAB8Aw=="},{"name":"Assists","value":"AAAAAgAAAMQAAAA7Aw=="},{"name":"FeaturedApp","value":"AAAAAgAAAMQAAABEAw=="},{"name":"FeaturedAppVOD","value":"AAAAAgAAAMQAAABFAw=="},{"name":"GooglePlay","value":"AAAAAgAAAMQAAABGAw=="},{"name":"ActionMenu","value":"AAAAAgAAAMQAAABLAw=="},{"name":"Help","value":"AAAAAgAAAMQAAABNAw=="},{"name":"TvSatellite","value":"AAAAAgAAAMQAAABOAw=="},{"name":"WirelessSubwoofer","value":"AAAAAgAAAMQAAAB+Aw=="},{"name":"AndroidMenu","value":"AAAAAgAAAMQAAABPAw=="}]],"id":20}
*/

/**
 * Extend all enums with a simple method to derive their names.
 */

/*
extension RawRepresentable where RawValue: Any {
    /**
     * The name of the enumeration (as written in case).
     */
    var name: String {
        get { return String(describing: self) }
    }

    /**
     * The full name of the enumeration
     * (the name of the enum plus dot plus the name as written in case).
     */
    var description: String {
        get { return String(reflecting: self) }
        // get { return self.rawValue as! String }
    }
}
*/
