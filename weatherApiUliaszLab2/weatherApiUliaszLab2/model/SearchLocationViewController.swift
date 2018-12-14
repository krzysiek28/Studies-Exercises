//
//  SearchLocationViewController.swift
//  weatherApiUliaszLab2
//
//  Created by Krzysztof on 07/11/2018.
//  Copyright © 2018 Krzysztof. All rights reserved.
//

import UIKit

class SearchLocationViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var cityNameInput: UITextField!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchResultLabel: UILabel!
    @IBOutlet weak var SearchCityNameInput: UITextField!
    @IBOutlet weak var addCityButton: UIButton!
    
    var locations = [Location]()
    let urlBase = "https://www.metaweather.com/api/location/search/?query="
    var locationCells = [Location]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func searchLocations() -> Void {
        let valueToSearch = cityNameInput.text!
        let url = "\(urlBase)\(valueToSearch)"
        getLocationFromURL(url)
        run(after: 3){
            var phrasesFound = ""
            for element in self.locations{
                phrasesFound = "\(phrasesFound)\(element.title),"
                print(element.title)
//                self.insertCells(element)
            }
            self.searchResultLabel.text = phrasesFound
        }
        locations.removeAll()
    }
    
    @objc
    @IBAction func addLocation() -> Void{
        let itemToAdd = SearchCityNameInput.text!
        let url = "\(urlBase)\(itemToAdd)"
        getLocationFromURL(url)
        var cityId = "44418"
        for element in locations {
            if(element.title == itemToAdd){
                cityId = element.woeid.description
            }
        }
        
        let newLocation = WeatherDetails(city: cityId, cityName: itemToAdd)
        
        CityWeatherStorage.shared.objects.append(newLocation)
        performSegue(withIdentifier: "backToTable", sender: self)
    }
    
    @IBAction func backToTable() -> Void{
        performSegue(withIdentifier: "backToTable", sender: self)
    }
    
    func getLocationFromURL(_ url:String){
        let strURL = URL(string: url)
        let urlSession = URLSession.shared
        
        if let myUrl = strURL {
            let dataTask = urlSession.dataTask(with: myUrl, completionHandler: {
                (data, urlResponse, error) in
                
                if error != nil {
                    print("error \(String(describing: error))")
                } else {
                    if let jsonData = data {
                        do {
                            let locationsData = try JSONDecoder().decode([Location].self, from: jsonData)
                            for element in locationsData{
                                self.locations.append(element)
                            }
                        } catch let err {
                            print("error2: \(err)")
                        }
                    }
                    
                    OperationQueue.main.addOperation({
                    })
                }
            })
            
            dataTask.resume()
        }
    }
    
    func run(after seconds: Int, completion: @escaping () -> Void){
        let deadline = DispatchTime.now() + .seconds(seconds)
        DispatchQueue.main.asyncAfter(deadline: deadline){
            completion()
        }
    }
    
    func insertCells(_ newItem: Location) -> Void {
        locationCells.insert(newItem, at: 0)
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)

//        for element in locations {
//            locationCells.append(element)
//            let indexPath = IndexPath(row: locationCells.count-1, section: 0)
//            print("indexPath: \(indexPath) and row:\(indexPath.row)")
//            tableView.beginUpdates()
//            tableView.insertRows(at: [indexPath], with: .automatic)
//            tableView.endUpdates()
//            view.endEditing(true)
//        }
    }
}

extension SearchLocationViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locationCells.count;
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherDetailsUITableCell", for: indexPath) as! WeatherDetailsUITableCell
        let cityName = locationCells[indexPath.row]
        
        cell.cityNameLabel.text = cityName.title

        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}
