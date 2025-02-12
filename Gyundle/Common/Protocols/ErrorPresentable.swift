//
//  ErrorPresentable.swift
//  Gyundle
//
//  Created by 임채윤 on 2/7/25.
//

import Foundation

protocol ErrorPresentable {
    var showError: Bool { get set }
    var errorMessage: String? { get set }
    
    func presentError(message: String?)
}
