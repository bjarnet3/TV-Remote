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
    func sendTheNeighboursToTheHell(kattedamen: String, dansken: Bool) -> Bool {
        return true
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
        let my_nick = "bjarnet3"
        let my_device = UIDevice.current.name
        let my_uuid = UUID().uuidString.lowercased()

        // let url = "http://\(remote.remoteIP)/system"
        let url = "http://\(remote.remoteIP)/sony/accessControl"

        let body = "{\"id\":13,\"method\":\"actRegister\",\"version\":\"1.0\",\"params\":[{\"clientid\":\"\(my_nick):\(my_uuid)\",nickname:\"\(my_nick) (\(my_device))\"},[{\"clientid\":\"\(my_nick):\(my_uuid)\",\"value\":\"yes\",\"nickname\":\"\(my_nick) (\(my_device))\",\"function\":\"WOL\"}]]}"
        guard let bodyBase64String = body.data(using: .utf8)?.base64EncodedString() else { return }

        let headers: HTTPHeaders = [
            "Authorization" : "Basic \(bodyBase64String)"
            // "Content-Type": "text/xml; charset=UTF-8",
            // "SOAPACTION": "\"urn:schemas-sony-com:service:IRCC:1#X_SendIRCC\"",
            // "X-Auth-PSK": remote.remotePin
        ]

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

    func request() {
        let my_nick = "bjarnet3"
        let my_device = UIDevice.current.name
        let my_uuid = UUID().uuidString.lowercased()

        let url = "http://\(remote.remoteIP)/sony/accessControl"
        guard let body = "{\"id\":1,\"method\":\"actRegister\",\"version\":\"1.0\",\"params\":[{\"clientid\":\"\(my_nick):\(my_uuid)\",nickname:\"\(my_nick) (\(my_device))\"},[{\"clientid\":\"\(my_nick):\(my_uuid)\",\"value\":\"yes\",\"nickname\":\"\(my_nick) (\(my_device))\",\"function\":\"WOL\"}]]}".data(using: .utf8) else { return }

        let bodyEncoding = body.base64EncodedString()

        Alamofire.request(url, method: .connect, parameters: nil, encoding: bodyEncoding, headers: nil).validate().response { responseObject in

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

    func request1() {

    }

    func request2() {

    }

    /*
     curl -S -i -k -X POST http://192.168.50.7/sony/system -H \"Content-Type: application/json\" -H \"Accept: application/json\" -d @requestFile.json | grep token | cut -d, -f1 | cut -d\\" -f4

     curl -v -XPOST http://192.168.50.7/sony/system -d '{"method":"getRemoteControllerInfo","params":[""],"id":20,"version":"1.0"}'

     curl -v -XPOST http://192.168.50.7/sony/system -d '{"method":"getPublicKey","params":[""],"id":1,"version":"1.0"}'

     // Auth / Pin
     // https://github.com/breunigs/bravia-auth-and-remote/issues/4

     curl --include --silent -XPOST http://192.168.50.7/sony/accessControl --header "Authorization: Basic OTM0MA==" -d "{\"method\":\"actRegister\",\"params\":[{\"clientid\":\"xun:5514F62F-46DD-4AC4-B985-D5E9C4C22987\",\"nickname\":\"xun (bravia)\",\"level\":\"private\"},[{\"value\":\"yes\",\"function\":\"WOL\"}]],\"id\":8,\"version\":\"1.0\"}" | grep -o -E 'auth_cookie=([a-z0-9]+)'
       http://192.168.50.7/sony/system

     curl -v -XPOST http://$tv_ip/sony/accessControl --header "$tv_auth_header" -d '{"id":13,"method":"actRegister","version":"1.0","params":[{"clientid":"$my_nick:$my_uuid",nickname:"$my_nick ($my_device)"},[{"clientid":"$my_nick:$my_uuid","value":"yes","nickname":"$my_nick ($my_device)","function":"WOL"}]]}'

     curl -v -XPOST http://192.168.50.7/sony/accessControl -d '{"method":"actRegister","params":[{"clientid":"TVSideView:4e6b4a7a-aa52-416e-bfad-6aac6f560f9d","nickname":"Nexus 5 (TV SideView)","level":"private"},[{"value":"yes","function":"WOL"}]],"id":8,"version":"1.0"}'

     curl "http://192.168.50.7/sony/accessControl/actRegister"

     curl -v -XPOST http://192.168.50.7/sony/encryption -d '{"method":"getPublicKey","params":[""],"id":3,"version":"1.0"}'

     http://192.168.50.7/sony/system
     */

    func send(command: RemoteCommand) {
        let url = "http://\(remote.remoteIP)/sony/IRCC"
        let headers: HTTPHeaders = [
            "Content-Type": "text/xml; charset=UTF-8",
            "SOAPACTION": "\"urn:schemas-sony-com:service:IRCC:1#X_SendIRCC\"",
            "X-Auth-PSK": remote.remotePin
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
