//
//  StringExtension.swift
//  RichTextEditor
//
//  Created by hamdan hashmi on 23/04/2020.
//  Copyright © 2020 Hamdan. All rights reserved.
//

import Foundation
public extension String {
    var htmlToPlainText: String {
        return [
            ("(<[^>]*>)|(&\\w+;)", " "),
            ("[ ]+", " ")
        ].reduce(self) {
            try! $0.replacing(pattern: $1.0, with: $1.1)
        }.resolvedHTMLEntities
    }

    var resolvedHTMLEntities: String {
        return replacingOccurrences(of: "&#39;", with: "'")
            .replacingOccurrences(of: "&#x27;", with: "'")
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&nbsp;", with: " ")
    }

    func replacing(pattern: String, with template: String) throws -> String {
        let regex = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        return regex.stringByReplacingMatches(in: self, options: [], range: NSRange(0 ..< utf16.count), withTemplate: template)
    }

    var htmlEscapeQuotes: String {
        return [
            ("\"", "\\\""),
            ("“", "&quot;"),
            ("\r", "\\r"),
            ("\n", "\\n")
        ].reduce(self) {
            $0.replacingOccurrences(of: $1.0, with: $1.1)
        }
    }
    
    var escaped: String {
        let unicode = unicodeScalars
        var newString = ""
        for char in unicode {
            if char.value == 39 || // 39 == ' in ASCII
                char.value < 9 || // 9 == horizontal tab in ASCII
                (char.value > 9 && char.value < 32) { // < 32 == special characters in ASCII
                let escaped = char.escaped(asASCII: true)
                newString.append(escaped)
            } else {
                newString.append(String(char))
            }
        }
        return newString
    }
    
}
