//
//  WeatherService.swift
//  widgetExtension
//
//  Created by 李佳林 on 2022/9/18.
//

import Foundation

class WeatherService {
    let url = URL(string: "http://www.weather.com.cn/weather/101030100.shtml")!
    
    
    func batch(completion: @escaping (Result<(Data, HTTPURLResponse), Network.Failure>) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = Network.Method.get.rawValue
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            guard let data = data, let response = response as? HTTPURLResponse, error == nil else {                completion(.failure(.requestFailed))
                return
            }
            completion(.success((data, response)))
        }.resume()
    }
    
    func weatherGet(completion: @escaping (Result<[Weather], Network.Failure>) -> Void) {
        DispatchQueue.global().async {
            let semaphore = DispatchSemaphore(value: 0)
            
            var todayWeather = Weather()
            self.batch { result in
                switch result {
                case .success(let (data, _)):
                    if let html = String(data: data, encoding: .utf8) {
                        let today = html.find("（今天）(.+?)</i>")
                        let wStatus = today.find("wea\">(.+?)<")
                        let wTempH = today.find("span>(.+?)</span>")
                        let wTempL = today.find("i>(.+?)℃")
                        todayWeather.wStatus = wStatus
                        if wTempH.isEmpty || wTempL.isEmpty {
                            todayWeather.weatherString = wTempL + wTempH + "℃"
                        } else {
                            todayWeather.weatherString = wTempL + "~" + wTempH + "℃"
                        }
                        if wStatus.contains("雪") {
                            todayWeather.weatherIconString1 = self.WidgetIconString("雪")
                        } else {
                            todayWeather.weatherIconString1 = self.WidgetIconString(wStatus)
                        }
                    }
                    semaphore.signal()
                    
                case .failure(let error):
                    completion(.failure(error))
                }
            }
            semaphore.wait()
            
            var tomorrowWeather = Weather()
            self.batch { result in
                switch result {
                case .success(let (data, _)):
                    if let html = String(data: data, encoding: .utf8) {
                        let tomorrow = html.find("（明天）(.+?)</i>")
                        let wStatus = tomorrow.find("wea\">(.+?)<")
                        let wTempH = tomorrow.find("span>(.+?)</span>")
                        let wTempL = tomorrow.find("i>(.+?)℃")
                        tomorrowWeather.wStatus = wStatus
                        if wTempH.isEmpty || wTempL.isEmpty {
                            tomorrowWeather.weatherString = wTempL + wTempH + "℃"
                        } else {
                            tomorrowWeather.weatherString = wTempL + "~" + wTempH
                        }
                        if wStatus.contains("雪") {
                            tomorrowWeather.weatherIconString1 = self.WidgetIconString("雪")
                        } else {
                            tomorrowWeather.weatherIconString1 = self.WidgetIconString(wStatus)
                        }
                    }
                    semaphore.signal()
                case .failure(let error):
                    completion(.failure(error))
                }
            }
            semaphore.wait()
            
            let weathers = [todayWeather, tomorrowWeather]
            DispatchQueue.main.async {
                completion(.success(weathers))
            }
        }
    }
    
    private func WidgetIconString(_ str: String) -> String {
        switch str {
        case "晴": return "晴"
        case "阴": return "多云"
        case "雨": return "小雨"
        case "雷阵雨": return "雷阵雨"
        case "多云": return "多云"
        case "雪": return "小雪"
        case "晴转多云": return "晴转阴"
        case "多云转晴": return "晴转阴"
        default: return "晴"
        }
    }
}
