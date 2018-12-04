//
//  DescriptionViewController.swift
//  rssReader
//
//  Created by Андрей Глухих on 03/12/2018.
//  Copyright © 2018 scapegoat. All rights reserved.
//

import UIKit

class DescriptionViewController: UIViewController {

    var newsItem: NewsItem!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var fullContentLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageHeight: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = newsItem.title
        descriptionLabel.text = newsItem.description
        fullContentLabel.text = newsItem.fullContent

        if newsItem.imageURL.isEmpty{
            imageHeight.constant = 0
            print("No image")
        } else {
            print(newsItem.imageURL)
            let url = URL(string: newsItem.imageURL)
            do {
                let data = try Data(contentsOf: url!)
                imageView.image = UIImage(data: data)
            } catch let error{
                print(error)
                imageHeight.constant = 0
            }
        }
    }

}


   
