//
//  XmlParser.swift
//  SimpleRssReader
//
//  Created by Beloizerov on 11.04.17.
//  Copyright © 2017 HOME. All rights reserved.
//

import Foundation

struct Post {
    
    var title = ""
    var date = ""
    var link = ""
    
}

class NewsParser: NSObject, XMLParserDelegate {
    
    // MARK: - Singleton
    
    private static var newsParser = NewsParser()
    
    static var posts: [Post] {
        if let posts = newsParser._posts { return posts }
        newsParser._posts = []
        newsParser.xmlParser?.parse()
        return newsParser._posts ?? []
    }
    
    class func reset() {
        newsParser._posts = []
    }
    
    // MARK: - Parser
    
    private let url = "http://rss.nytimes.com/services/xml/rss/nyt/HomePage.xml"
    
    private lazy var xmlParser: XMLParser? = {
        guard let url = URL(string: self.url),
            let parser = XMLParser(contentsOf: url)
            else { return nil }
        parser.delegate = self
        return parser
    }()
    
    private var _posts: [Post]?
    
    // MARK: - XMLParserDelegate
    
    private var newPost: Post?
    private var tempElementName: String?
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        tempElementName = elementName
        if elementName == "item" {
            tempElementName = nil
            newPost = Post()
        } else {
            tempElementName = elementName
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        switch tempElementName {
        case "title"?: newPost?.title.append(string)
        case "pubDate"?: newPost?.date.append(string)
        case "link"?: newPost?.link.append(string)
        default: break
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        guard elementName == "item", let post = newPost else { return }
        _posts?.append(post)
        newPost = nil
        tempElementName = nil
    }
    
}
