//
//  Extensions.swift
//  StyleEaseApp
//


import Foundation

extension String {
    
    func isValidateEmail() -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: self)
    }
    
    func isValidPassword() -> Bool {
        if self.count > 6 && self.count < 15 {
            return true
        } else {
            return false
        }
    }
    
}


extension String {
    var isNumeric: Bool {
        return !isEmpty && rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
    }
}


func generateRandomString() -> String {
    let prefix = "EAP-"
    let characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
    
    var randomString = prefix
    
    for _ in 0..<6 {
        let randomIndex = Int.random(in: 0..<characters.count)
        let randomCharacter = characters[characters.index(characters.startIndex, offsetBy: randomIndex)]
        randomString.append(randomCharacter)
    }
    
    return randomString
}

extension Int {
    func isValidPrice() -> Bool {
        guard self > 0 else {
            return false
        }

        let stringValue = String(self)
        return stringValue == "0" || !stringValue.hasPrefix("0")
    }
}

extension String {
    func removingLeadingZeros() -> String {
        let regex = try? NSRegularExpression(pattern: "^0+(?!$)", options: [])
        let range = NSRange(location: 0, length: count)

        if let trimmedString = regex?.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: "") {
            return trimmedString
        }

        return self
    }
}
