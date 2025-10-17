//
//  UIView+Extensions.swift
//  MovieBrowser
//
//  Created by Mohamed Khaled on 15/10/2025.
//

import Foundation
import UIKit

extension UITableViewCell {
    class var identifier: String {
        return String(describing: self)
    }
}

// tiny helper
extension JSONDecoder {
    convenience init(withSnakeCase: Bool) {
        self.init()
        if withSnakeCase { keyDecodingStrategy = .convertFromSnakeCase }
    }
}

extension JSONDecoder {
    static var makeSnakeCaseDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }
}
