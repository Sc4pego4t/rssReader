//
//  DataModel.swift
//  rssReader
//
//  Created by Андрей Глухих on 03/12/2018.
//  Copyright © 2018 scapegoat. All rights reserved.
//

import Foundation

class DataModel: NSObject, XMLParserDelegate{
    var newsList: [NewsItem] = []

    let defaultFiltred = "filtred"
    var isFiltred: Bool

    override init(){
       isFiltred = UserDefaults.standard.bool(forKey: defaultFiltred)
    }

    func changeFiltred(){
        isFiltred = !isFiltred
        UserDefaults.standard.set(isFiltred, forKey: defaultFiltred)
    }

    func registerDefaults(){
        let dictionary: [String : Bool] = [defaultFiltred: true]
        UserDefaults.standard.register(defaults: dictionary)
    }
    /// get item by numerical ocurrence in section
    ///
    /// - Parameters:
    ///   - category: item category
    ///   - occurrence: what ocurrence in list this item has by his category
    /// - Returns: item
    func getNewsListItemBy(category:String,and occurrence:Int) -> NewsItem!{
        var counter = 0
        for item in newsList where item.category == category{
            if(counter == occurrence){
                return item
            }
            counter += 1
        }
        return nil
    }

    var categories: [String] = []

    /// funcrion for counting items with selected category
    ///
    /// - Parameter categoryNum: category index in array
    /// - Returns: count
    func itemsWithThisCategoryCount(categoryNum: Int) -> Int{
        var counter = 0
        for item in newsList where item.category == categories[categoryNum]{
            counter += 1
        }
        return counter
    }

    private var parserCompletionHandler: (()->Void)!

    /// create request url and start to parse data, with defined complition handler
    ///
    /// - Parameters:
    ///   - url: rss source site
    ///   - completionHandler: define, what to do on parse complition
    func parseNewsItems(url:String, completionHandler: (()->Void)?){
        newsList = []
        parserCompletionHandler = completionHandler!
        let request = URLRequest(url: URL(string: url)!)
        let urlSession = URLSession.shared
        let task = urlSession.dataTask(with:request){
            (data, response, error) in
            guard let data = data else {
                if let error = error{
                    print(error)
                }
                return
            }
            let parser = XMLParser(data: data)
            parser.delegate = self
            parser.parse()
        }
        task.resume()
    }

    var currentEl = ""
    var currentItem = NewsItem()

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if let type = attributeDict["type"]{
            if(elementName == "enclosure") && type.contains("image"){
                currentItem.imageURL = attributeDict["url"]!
            }
        }

        currentEl = elementName
        if currentEl == "item"{
            currentItem = NewsItem()
        }
    }
    func parser(_ parser: XMLParser, foundCharacters string: String) {

//        print(currentEl)
//        print(string)
        if(!string.isEmpty && string != "\n"){
            switch currentEl {
                case "title": currentItem.title += string
                case "description": currentItem.description += string
                case "pubDate":
                    let formatter = DateFormatter()
                    formatter.dateFormat = "E, dd MMM yyyy HH:mm:ss Z"
                    let date = formatter.date(from: string)
                    formatter.dateFormat = "d MMMM HH:mm"
                    formatter.locale = Locale(identifier: "ru")
                    if let goodLokingDate = date{
//                        print(formatter.string(from: goodLokingDate))
                        currentItem.pubDate = formatter.string(from: goodLokingDate)
                    }
                case "category":
                    currentItem.category += string
                    if !categories.contains(string){
                        categories.append(string)
                        categories.sort()

                }
                case "yandex:full-text": currentItem.fullContent += string
                default: break
            }
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item"{
            newsList.append(currentItem)
        }
    }

    /// define what to do after parsing is completed
    ///
    /// - Parameter parser: parser
    func parserDidEndDocument(_ parser: XMLParser) {
        DispatchQueue.main.async {
            self.parserCompletionHandler()
//            print(self.categories)
//            print(self.newsList)
        }
    }

    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print(parseError.localizedDescription)
    }
}
