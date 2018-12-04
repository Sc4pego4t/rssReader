//
//  NewsListViewController.swift
//  rssReader
//
//  Created by Андрей Глухих on 03/12/2018.
//  Copyright © 2018 scapegoat. All rights reserved.
//

import UIKit

class NewsListViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        dataModel = DataModel()
        initializeFilterButton()
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 80.0
        navigationItem.largeTitleDisplayMode = .always
        dataModel.parseNewsItems(url: "https://www.vesti.ru/vesti.rss"){
            self.tableView.reloadData()
        }
    }

    @IBOutlet weak var filterButton: UIBarButtonItem!

    @IBAction func filter(){
        dataModel.changeFiltred()
        initializeFilterButton()
        tableView.reloadData()
    }

    /// Define color of filter button
    func initializeFilterButton(){
        if dataModel.isFiltred{
            filterButton.tintColor = blueColor
        } else {
            filterButton.tintColor = UIColor.lightGray
        }
    }

    // MARK: - Table view data source
    var dataModel: DataModel!

    @IBAction func refresh(){
        dataModel.parseNewsItems(url: "https://www.vesti.ru/vesti.rss"){
            self.tableView.reloadData()
        }
    }

    /// how many sections to create
    ///
    /// - Parameter tableView: tv
    /// - Returns: return 1 section if filter is disabled and count of categories otherwise
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if(dataModel.isFiltred){
            return dataModel.categories.count
        } else {
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if(dataModel.isFiltred){
            return dataModel.itemsWithThisCategoryCount(categoryNum: section)
        } else {
            return dataModel.newsList.count
        }
    }

    

    let SectionHeaderHeight: CGFloat = 25

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

        if dataModel.isFiltred && dataModel.itemsWithThisCategoryCount(categoryNum: section) > 0{
            return SectionHeaderHeight
        }
        return 0
    }

    let blueColor = UIColor.init(displayP3Red: 0, green: 122/255.0, blue: 1, alpha: 1.0)

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: SectionHeaderHeight))
        view.backgroundColor = UIColor.white
        let label = UILabel(frame: CGRect(x: 15, y: 0, width: tableView.bounds.width - 30, height: SectionHeaderHeight))

        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textColor = blueColor
        label.text = dataModel.categories[section]

        view.addSubview(label)
        return view
    }


    let reuseIdentifier = "CellIdentifier"

    /// Create cell with code
    ///
    /// - Returns: created cell
    func makeCell() -> UITableViewCell{
        if let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier){
            return cell
        } else {
            return UITableViewCell(style: .subtitle, reuseIdentifier: reuseIdentifier)
        }
    }

    /// if filter is enabled, we fetch data with function, because we have multiple sections, but if it is disabled then we just get item by row number
    ///
    /// - Parameter indexPath: ip
    /// - Returns: newsItem
    func getNewsItem(_ indexPath: IndexPath) -> NewsItem?{
        var item: NewsItem?
        if dataModel.isFiltred{
            item = dataModel.getNewsListItemBy(category: dataModel.categories[indexPath.section], and: indexPath.row)
        } else {
            item = dataModel.newsList[indexPath.row]
        }
        return item
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = makeCell()
        let item = getNewsItem(indexPath)

        if let item = item{
            cell.textLabel?.text = item.title
            cell.textLabel?.numberOfLines = 0
            cell.detailTextLabel?.text = item.pubDate
        }
        return cell
    }

    let segueIdentifier = "ShowDescription"

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = getNewsItem(indexPath)
        performSegue(withIdentifier: segueIdentifier, sender: item)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueIdentifier{
            let controller = segue.destination as? DescriptionViewController
            controller?.newsItem = sender as? NewsItem
            print("Ok")
        }
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }

}
