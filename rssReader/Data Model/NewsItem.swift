//
//  NewsItem.swift
//  rssReader
//
//  Created by Андрей Глухих on 03/12/2018.
//  Copyright © 2018 scapegoat. All rights reserved.
//

import Foundation

struct NewsItem {
    init(){
        title=""
        description=""
        pubDate=""
        fullContent=""
        imageURL=""
        category=""
    }

    var category: String
    var title: String
    var description: String
    var pubDate: String

    var fullContent: String

    var imageURL: String

}

