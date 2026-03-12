//
//  ContentFilter.swift
//  HerHub
//
//  Lightweight text filter to reduce obviously offensive content.
//

import Foundation

enum ContentFilter {
    
   
    private static let blockedWords: [String] = [
      
        "damn",
        "hell",
        "shit",
        "fuck",
        "friggin",
        "freaking ",
        "wtf",
        "crap",
        "bullshit",
        "piss",
        "dumbass",
        "jackass",
        "asshole",
        "bastard",
        
        "idiot",
        "stupid",
        "moron",
        "loser",
        "freak",
        "psycho",
        "jerk",
        "weirdo",
        "hate you",
        "nobody likes you",
        "you are worthless",
        
        "go away and die",
        "go die",
        "you should die",
        "kill yourself",
        "kys ",
      
        "slut",
        "hore",
        "pervert",
        "pervy",
        "creep",
        "gross body",
        "disgusting body",
        "you are disgusting"
    ]
    
    static func containsOffensiveLanguage(_ text: String) -> Bool {
        let lowercased = text.lowercased()
        return blockedWords.contains { lowercased.contains($0) }
    }
    
    static func cleanedText(_ text: String) -> String {
        var result = text
        for word in blockedWords {
            let pattern = "(?i)\(NSRegularExpression.escapedPattern(for: word))"
            if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
                let range = NSRange(location: 0, length: (result as NSString).length)
                result = regex.stringByReplacingMatches(in: result, options: [], range: range, withTemplate: String(repeating: "*", count: word.count))
            }
        }
        return result
    }
}

