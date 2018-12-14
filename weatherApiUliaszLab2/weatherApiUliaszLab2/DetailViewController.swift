//
//  DetailViewController.swift
//  weatherApiUliaszLab2
//
//  Created by Krzysztof on 02/11/2018.
//  Copyright © 2018 Krzysztof. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var minTempLabel: UILabel!
    @IBOutlet weak var maxTempLabel: UILabel!
    @IBOutlet weak var windSpeedLabel: UILabel!
    @IBOutlet weak var windDirectionLabel: UILabel!
    @IBOutlet weak var predictabilityLabel: UILabel!
    @IBOutlet weak var airPreasureLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!

    func run(after seconds: Int, completion: @escaping () -> Void){
        let deadline = DispatchTime.now() + .seconds(seconds)
        DispatchQueue.main.asyncAfter(deadline: deadline){
            completion()
        }
    }
    
    func configureView() {
        // Update the user interface for the detail item.
        if let detail = detailItem {
            detail.initValues()
            run(after: 5){
                if(!detail.weather.isEmpty){
                    let firstElement = detail.weather[0]
                    print(firstElement.max_temp.rounded().description)
                    if let label = self.cityLabel {
                        label.text = detail.cityName
                    }
                    if let label = self.minTempLabel {
                        label.text = firstElement.min_temp.rounded().description
                    }
                    if let label = self.maxTempLabel {
                        label.text = firstElement.max_temp.rounded().description
                    }
                    if let label = self.windSpeedLabel {
                        label.text = firstElement.wind_speed.rounded().description
                    }
                    if let label = self.windDirectionLabel {
                        label.text = firstElement.wind_direction_compass
                    }
                    if let label = self.predictabilityLabel {
                        label.text = firstElement.predictability.description
                    }
                    if let label = self.airPreasureLabel {
                        label.text = firstElement.air_pressure.rounded().description
                    }
                    if let label = self.dateLabel {
                        label.text = firstElement.applicable_date
                    }
                    if let iconImageView = self.iconImageView {
                        iconImageView.image = UIImage(named: firstElement.weather_state_abbr)
                    }
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureView()
    }

    var detailItem: WeatherDetails? {
        didSet {
            // Update the view.
            configureView()
        }
    }
}

