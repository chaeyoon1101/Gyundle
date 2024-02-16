//
//  Bundle.swift
//  Gyundle
//
//  Created by 임채윤 on 2/16/24.
//

import Foundation

extension Bundle {
    func appKey(for name: String) -> String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "KakaoNativeAppKey") as? String else {
            print("app Key 가져오는데 에러 발생")
            
            return ""
        }
        
        return key
    }
}
