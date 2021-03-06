//
//  Enviroment.swift
//  AllReview
//
//  Created by 정하민 on 2019/12/26.
//  Copyright © 2019 swift. All rights reserved.
//

import Foundation

public enum Environment {
    
    enum Keys {
      enum Plist {
        static let rootURL = "ROOT_URL"
      }
    }

    private static let infoDict: [String:Any] = {
        guard let dict = Bundle.main.infoDictionary else {
            fatalError("Info.plist Not Found")
        }
        return dict
    }()
    
    static let rootURL: String = {
        guard let rootURLstring = Environment.infoDict["ROOT_URL"] as? String else {
            fatalError("Root URL not set in plist for this environment")
        }
        return rootURLstring
    }()
    
}
