//
//  Network.swift
//  PeiYang Lite
//
//  Created by TwTStudio on 7/5/20.
//

import SwiftUI

struct Network {
    enum Failure: Error, Equatable, Hashable {
        case urlError, requestFailed, loginFailed, unknownError, alreadyLogin, usorpwWrong, captchaWrong
        case custom(String)
        case `default`
        
        private static let pair: [Failure: Localizable] = [
            .urlError: .urlError,
            .requestFailed: .requestFailed,
            .loginFailed: .loginFailed,
            .unknownError: .unknownError,
            .alreadyLogin: .alreadyLogin,
            .usorpwWrong: .usorpwWrong,
            .captchaWrong: .captchaWrong,
        ]

        var localizedStringKey: LocalizedStringKey {
            Failure.pair[self]?.rawValue ?? ""
        }
        
    }
    
    enum Method: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
    }
    
    static func uploadFile(
        _ urlString: String,
        fileURL: URL,
        query: [String: String] = [:],
        headers: [String: String] = [:],
        method: Method = .post,
        body: [String: String] = [:],
        async: Bool = true,
        completion: @escaping (Result<(Data, HTTPURLResponse), Failure>) -> Void
    ) {
        // URL
        guard let url = URL(string: urlString) else {
            completion(.failure(.urlError))
            return
        }
        
        // Query
        var requestURL: URL
        if query.isEmpty {
            requestURL = url
        } else {
            var comps = URLComponents(url: url, resolvingAgainstBaseURL: true)!
            comps.queryItems = comps.queryItems ?? []
            comps.queryItems!.append(contentsOf: query.map { URLQueryItem(name: $0.0, value: $0.1) })
            requestURL = comps.url!
        }
        
        // Headers
        var request = URLRequest(url: requestURL)
        /// TODO: Check if cookies been stored in `Storage.defaults`, if true then add to headers
        if !headers.isEmpty {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        // Method
        request.httpMethod = method.rawValue
        
        // Body
        if method == .get {
            request.httpBody = body.percentEncoded()
        } else if method == .post || method == .put {
            var bodyData = Data()
            let boundary = "Boundary+\(arc4random())\(arc4random())"
            for (key, value) in body {
                bodyData.appendString(string: "--\(boundary)\r\n")
                bodyData.appendString(string: "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                bodyData.appendString(string: "\(value)\r\n")
            }
            
            bodyData.appendString(string: "--\(boundary)--\r\n")
            request.httpBody = bodyData
        }
        
        // Request
        URLSession.shared.uploadTask(with: request, fromFile: fileURL){ data, response, error in
            func process() {
                guard let data = data, let response = response as? HTTPURLResponse, error == nil else {
                    completion(.failure(.requestFailed))
                    return
                }
                completion(.success((data, response)))
                
                // Save Cookies
                guard let url = response.url, let headers = response.allHeaderFields as? [String: String] else {
                    completion(.failure(.requestFailed))
                    return
                }
                let cookies = HTTPCookie.cookies(withResponseHeaderFields: headers, for: url)
                HTTPCookieStorage.shared.setCookies(cookies, for: url, mainDocumentURL: nil)
                for cookie in cookies {
                    var cookieProperties = [HTTPCookiePropertyKey: Any]()
                    cookieProperties[.name] = cookie.name
                    cookieProperties[.value] = cookie.value
                    cookieProperties[.domain] = cookie.domain
                    cookieProperties[.path] = cookie.path
                    cookieProperties[.version] = cookie.version
                    cookieProperties[.expires] = Date().addingTimeInterval(31536000)
                    
                    if let newCookie = HTTPCookie(properties: cookieProperties) {
                        HTTPCookieStorage.shared.setCookie(newCookie)
                    }
                }
            }
            
            if async {
                DispatchQueue.main.async {
                    process()
                }
            } else {
                process()
            }
        }.resume()
    }
    
    static func fetch(
        _ urlString: String,
        query: [String: String] = [:],
        headers: [String: String] = [:],
        method: Method = .get,
        body: [String: Any] = [:],
        async: Bool = true,
        completion: @escaping (Result<(Data, HTTPURLResponse), Failure>) -> Void
    ) {
        // URL
        guard let url = URL(string: urlString) else {
            completion(.failure(.urlError))
            return
        }
        
        // Query
        var requestURL: URL
        if query.isEmpty {
            requestURL = url
        } else {
            var comps = URLComponents(url: url, resolvingAgainstBaseURL: true)!
            comps.queryItems = comps.queryItems ?? []
            comps.queryItems!.append(contentsOf: query.map { URLQueryItem(name: $0.0, value: $0.1) })
            requestURL = comps.url!
        }
        
        // Headers
        var request = URLRequest(url: requestURL)
        /// TODO: Check if cookies been stored in `Storage.defaults`, if true then add to headers
        if !headers.isEmpty {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        // Method
        request.httpMethod = method.rawValue
        
        // Body
        // Body
        if method == .get {
            request.httpBody = body.percentEncoded()
        } else if method == .post || method == .put {
            
            var bodyData = Data()
            let boundary = "Boundary+\(arc4random())\(arc4random())"
            request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            for (key, value) in body {
                bodyData.appendString(string: "--\(boundary)\r\n")
                bodyData.appendString(string: "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                bodyData.appendString(string: "\(value)\r\n")
            }
            
            bodyData.appendString(string: "--\(boundary)--\r\n")
            request.httpBody = bodyData
        }
        
        // Request
        URLSession.shared.dataTask(with: request) { data, response, error in
            func process() {
                guard let data = data, let response = response as? HTTPURLResponse, error == nil else {
                    completion(.failure(.requestFailed))
                    return
                }
                completion(.success((data, response)))
                
                // Save Cookies
                guard let url = response.url, let headers = response.allHeaderFields as? [String: String] else {
                    completion(.failure(.requestFailed))
                    return
                }
                let cookies = HTTPCookie.cookies(withResponseHeaderFields: headers, for: url)
                HTTPCookieStorage.shared.setCookies(cookies, for: url, mainDocumentURL: nil)
                for cookie in cookies {
                    var cookieProperties = [HTTPCookiePropertyKey: Any]()
                    cookieProperties[.name] = cookie.name
                    cookieProperties[.value] = cookie.value
                    cookieProperties[.domain] = cookie.domain
                    cookieProperties[.path] = cookie.path
                    cookieProperties[.version] = cookie.version
                    cookieProperties[.expires] = Date().addingTimeInterval(31536000)
                    
                    if let newCookie = HTTPCookie(properties: cookieProperties) {
                        HTTPCookieStorage.shared.setCookie(newCookie)
                    }
                }
                
                
                
                /// TODO: Add cookies to `Storage.defaults`
            }
            
            if async {
                DispatchQueue.main.async {
                    process()
                }
            } else {
                process()
            }
        }.resume()
    }
    
    static func batch(
        _ urlString: String,
        query: [String: String] = [:],
        headers: [String: String] = [:],
        method: Method = .get,
        body: [String: String] = [:],
        completion: @escaping (Result<(Data, HTTPURLResponse), Failure>) -> Void
    ) {
        fetch(urlString, query: query, headers: headers, method: method, body: body, async: false, completion: completion)
    }
    
    static func requestWithFormData(urlString: String, method: Method, headers: [String: Any] = [:], parameters: [String: Any] = [:],imageUrls: [(String, String)] = [] ,dataPath: [(String, Data)] = [], completion: @escaping (Result<(Data, HTTPURLResponse), Failure>) -> Void){
        let url = URL(string: urlString)!
        var request = URLRequest(url: url,timeoutInterval: Double.infinity)
        request.httpMethod = Method.post.rawValue
        let boundary = "Boundary-\(UUID().uuidString)"
        
        for (k, v) in headers {
            request.setValue(v as? String, forHTTPHeaderField: k)
        }
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        var body = Data()
        for (key, value) in parameters {
            body.appendString(string: "--\(boundary)\r\n")
            body.appendString(string: "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            body.appendString(string: "\(value)\r\n")
        }
        
        for (key, value) in imageUrls {
            body.appendString(string: "--\(boundary)\r\n")
            body.appendString(string: "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            body.appendString(string: "\(value)\r\n")
        }
        
        for (key, value) in dataPath {
            body.appendString(string: "--\(boundary)\r\n")
            body.appendString(string: "Content-Disposition: form-data; name=\"\(key)\"; filename=\"\(arc4random()).jpg\"\r\n") //此處放入file name，以隨機數代替，可自行放入
            body.appendString(string: "Content-Type: \"content-type header\"\r\n\r\n") //image/png 可改為其他檔案類型 ex:jpeg
            body.append(value)
            body.appendString(string: "\r\n")
        }
        
        body.appendString(string: "--\(boundary)--\r\n")
        request.httpBody = body
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            func process() {
                guard let data = data, let response = response as? HTTPURLResponse, error == nil else {
                    completion(.failure(.requestFailed))
                    return
                }
                completion(.success((data, response)))
                
                // Save Cookies
                guard let url = response.url, let headers = response.allHeaderFields as? [String: String] else {
                    completion(.failure(.requestFailed))
                    return
                }
                let cookies = HTTPCookie.cookies(withResponseHeaderFields: headers, for: url)
                HTTPCookieStorage.shared.setCookies(cookies, for: url, mainDocumentURL: nil)
                for cookie in cookies {
                    var cookieProperties = [HTTPCookiePropertyKey: Any]()
                    cookieProperties[.name] = cookie.name
                    cookieProperties[.value] = cookie.value
                    cookieProperties[.domain] = cookie.domain
                    cookieProperties[.path] = cookie.path
                    cookieProperties[.version] = cookie.version
                    cookieProperties[.expires] = Date().addingTimeInterval(31536000)
                    
                    if let newCookie = HTTPCookie(properties: cookieProperties) {
                        HTTPCookieStorage.shared.setCookie(newCookie)
                    }
                }
            }
            
            DispatchQueue.main.async {
                process()
            }
        }.resume()
    }
}

extension Data{
    
    mutating func appendString(string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        append(data!)
    }
}

extension Dictionary {
    func percentEncoded() -> Data? {
        var charSet = CharacterSet.urlQueryAllowed
        charSet.remove(charactersIn: "&?")
        return self.map { key, value in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: charSet) ?? ""
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: charSet) ?? ""
            return escapedKey + "=" + escapedValue
        }
        .joined(separator: "&")
        .data(using: .utf8)
    }
}

extension Network.Failure: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .custom(let desc):
            return desc
        case .default:
            return "未知错误，请联系管理员处理"
        default:
            return self.localizedStringKey.stringValue()
        }
    }
    
    var description: String {
        return self.errorDescription ?? "未知错误，请联系管理员处理"
    }
}


enum Localizable: LocalizedStringKey, CaseIterable {
    case urlError, requestFailed, loginFailed, unknownError, alreadyLogin, usorpwWrong, captchaWrong
        
    case notificationError, notificationErrorMessage
    case biometryNotEnrolled, biometryNotAvailable, biometryNotAvailableMessage, userCancel, faceIDUsageDescription
    
    
    case login, ok
    case captcha
    case classesUsername, classesPassword
    case ecardUsername, ecardPassword
    case wlanUsername, wlanPassword
    
//    case fullCourse, onlyThisWeek
    case account
    case classes, online, offline
    case logout, logoutMessage, confirm
    
    case safety
    case needUnlock
    
    case home
    case beforeDawn, dawn, morning, beforeNoon, noon, noonSoon, afternoon, dusk, evening, night
    
    case courseTable, emptyCourseMeesage, nextDayEmptyCourse
    
    case examTable
    
    case term, score, gpa, credit, emptyGPAMeesage
    case totalScore, totalGPA, totalCredit
    
    case ecard, ecardNO, state, balance, expire, subsidy
    case period, transaction, dailyConsume, siteConsume, siteRecharge
    
    case wlan, detail
}


extension LocalizedStringKey {
    var stringKey: String {
        let description = "\(self)"

        let components = description.components(separatedBy: "key: \"")
            .map { $0.components(separatedBy: "\",") }

        return components[1][0]
    }
}

extension String {
    static func localizedString(for key: String,
                                locale: Locale = .current) -> String {
        
        var language = locale.language.languageCode?.identifier ?? ""
        if (locale.language.script?.identifier ?? "") != "" || language == "zh" {
            language += "-" + (locale.language.script?.identifier ?? "Hans")
        }
        
        guard let path = Bundle.main.path(forResource: language, ofType: "lproj") else {
            return ""
        }
        guard let bundle = Bundle(path: path) else {
            return ""
        }
        let localizedString = NSLocalizedString(key, bundle: bundle, comment: "")
        
        return localizedString
    }
}

extension LocalizedStringKey {
    func stringValue(locale: Locale = .current) -> String {
        return .localizedString(for: self.stringKey, locale: locale)
    }
}
