//
//  RemoteHandler.swift
//  TV Remote
//
//  Created by Bjarne Tvedten on 01/02/2020.
//  Copyright © 2020 Digital Mood. All rights reserved.
//

import Foundation
import Alamofire

class RemoteHandler {

    var remote: Remote

    init(remote: Remote) {
        self.remote = remote
    }

    func send(keyString: String) {
        guard
            let command = RemoteCommand(name: keyString)
            else { return }

        send(command: command)
    }

    func send(channelNumber: Int) {
        // Break up channelNumber into charaters
        let channelNumberString = String(channelNumber)

        for (idx, channel) in channelNumberString.enumerated() {
            let channelDigit = "\(channel)"

            if let keyCommand = RemoteCommand(channelNumber: Int(channelDigit)) {

                let delay = (Double(idx) * 0.065) + Double(0.15)
                let lastAction = {
                    DispatchQueue.main.asyncAfter(deadline: .now() + delay + 0.15, execute: {
                        self.send(command: .enter)
                    })
                }

                switch idx {
                case 0:
                    send(command: keyCommand)
                    if channelNumberString.count == 1 {
                        lastAction()
                    }
                case 1..<(channelNumberString.count - 1):
                    DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
                        self.send(command: keyCommand)
                    })
                default:
                    DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
                        self.send(command: keyCommand)
                    })
                    lastAction()
                }
            }
        }
    }

    func send() {
        let url = "http://\(remote.remoteIP)/system"
        let headers: HTTPHeaders = [
            "Content-Type": "text/xml; charset=UTF-8",
            "SOAPACTION": "\"urn:schemas-sony-com:service:IRCC:1#X_SendIRCC\"",
            "X-Auth-PSK": remote.remoteKey
        ]
        guard let body = "{\"id\":13,\"method\":\"actRegister\",\"version\":\"1.0\",\"params\":[{\"clientid\":\"$my_nickk:$my_uuidd\",nickname:\"$my_nick ($my_devicee)\"},[{\"clientidd\":\"$my_nickk:$my_uuidd\",\"value\":\"yes\",\"nickname\":\"$my_nick ($my_devicee)\",\"function\":\"WOL\"}]]}".data(using: .utf8)?.base64EncodedString() else { return }

        Alamofire.request(url, method: .post, parameters: nil, encoding: body, headers: headers).validate().response { responseObject in

            guard
                responseObject.response?.statusCode == 200,
                responseObject.error == nil
                else
            {
                print("An error occurred: \(responseObject.error!)")
                return
            }
            print("succeeded!")
            print(responseObject.response)
        }
    }

    /*
     curl -S -i -k -X POST http://192.168.1.7/sony/system -H \"Content-Type: application/json\" -H \"Accept: application/json\" -d @requestFile.json | grep token | cut -d, -f1 | cut -d\\" -f4

     curl -v -XPOST http://192.168.1.7/sony/system -d '{"method":"getRemoteControllerInfo","params":[""],"id":20,"version":"1.0"}'

     http://192.168.1.7/sony/system
     */

    func send(command: RemoteCommand) {
        let url = "http://\(remote.remoteIP)/sony/IRCC"
        let headers: HTTPHeaders = [
            "Content-Type": "text/xml; charset=UTF-8",
            "SOAPACTION": "\"urn:schemas-sony-com:service:IRCC:1#X_SendIRCC\"",
            "X-Auth-PSK": remote.remoteKey
        ]
        let body =
            "<?xml version=\"1.0\"?>" +
                "<s:Envelope xmlns:s=\"http://schemas.xmlsoap.org/soap/envelope/\" s:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">" +
                "<s:Body>" +
                "<u:X_SendIRCC xmlns:u=\"urn:schemas-sony-com:service:IRCC:1\">" +
                "<IRCCCode>\(command.rawValue)</IRCCCode>" +
                "</u:X_SendIRCC>" +
                "</s:Body>" +
        "</s:Envelope>"

        Alamofire.request(url, method: .post, parameters: nil, encoding: body, headers: headers).validate().response { responseObject in

            guard
                responseObject.response?.statusCode == 200,
                responseObject.error == nil
                else
            {
                print("An error occurred: \(responseObject.error!)")
                return
            }
            print("\"\(String(describing: command))\" succeeded!")
        }
    }

}

extension String: ParameterEncoding {
    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var request = try urlRequest.asURLRequest()
        request.httpBody = data(using: .utf8, allowLossyConversion: false)
        return request
    }
}
