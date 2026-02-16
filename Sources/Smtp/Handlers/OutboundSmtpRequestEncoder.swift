//
//  https://mczachurski.dev
//  Copyright © 2021 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import NIO
import NIOFoundationCompat
import Foundation

internal final class OutboundSmtpRequestEncoder: MessageToByteEncoder {
    typealias OutboundIn = SmtpRequest

    func encode(data: SmtpRequest, out: inout ByteBuffer) {
        switch data {
        case .sayHello(serverName: let server, helloMethod: let helloMethod):
            out.writeString("\(helloMethod.rawValue) \(server)")
        case .startTls:
            out.writeString("STARTTLS")
        case .sayHelloAfterTls(serverName: let server, helloMethod: let helloMethod):
            out.writeString("\(helloMethod.rawValue) \(server)")
        case .mailFrom(let from):
            out.writeString("MAIL FROM:<\(from)>")
        case .recipient(let rcpt):
            out.writeString("RCPT TO:<\(rcpt)>")
        case .data:
            out.writeString("DATA")
        case .transferData(let email):
            email.write(to: &out)
        case .quit:
            out.writeString("QUIT")
        case .beginAuthentication(let authType):
            switch authType {
                case .login:
                    out.writeString("AUTH LOGIN")
                case .oAuth:
                    out.writeString("AUTH XOAUTH2")
            }
        case .authUser(let user):
            let userData = Data(user.utf8)
            out.writeBytes(userData.base64EncodedData())
        case .authPassword(let password):
            let passwordData = Data(password.utf8)
            out.writeBytes(passwordData.base64EncodedData())
        case .oAuthLogin(user: let user, accessToken: let accessToken):
            let loginData = Data("user=\(user)\u{0001}auth=Bearer \(accessToken)\u{0001}\u{0001}".utf8)
            out.writeBytes(loginData.base64EncodedData())
        }

        out.writeString("\r\n")
    }
}
