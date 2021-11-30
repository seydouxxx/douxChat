//
//  AWS.swift
//  douxChat
//
//  Created by Seydoux on 2021/11/29.
//

import Foundation
import Amplify
import AWSCognitoAuthPlugin

class AWS {
    static let shared = AWS()
    static func initialize() -> AWS {
        return .shared
    }
    private init() {
        do {
            try Amplify.add(plugin: AWSCognitoAuthPlugin())
            try Amplify.configure()
            print("Amplify initialized")
        } catch {
            print("Error occured during initializing Amplify. \(error.localizedDescription)")
        }
    }
}
