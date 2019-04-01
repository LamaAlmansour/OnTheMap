//
//  API.swift
//  OnTheMap
//
//  Created by Lama on 31/12/2018.
//  Copyright © 2018 Lama. All rights reserved.
//

import Foundation

class API {
    
    private static var userInfo = UserInfo()
    private static var sessionId: String?
    
    
    static func postSession(username: String, password: String, completion: @escaping (String?)->Void) {
        guard let url = URL(string: APIConstants.SESSION) else {
            completion("Supplied url is invalid")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".data(using: .utf8)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            var errString: String?
            if let statusCode = (response as? HTTPURLResponse)?.statusCode { //Request sent succesfully
                if statusCode >= 200 && statusCode < 300 { //Response is ok
                    
                    let newData = data?.subdata(in: 5..<data!.count)
                    if let json = try? JSONSerialization.jsonObject(with: newData!, options: []),
                        let dict = json as? [String:Any],
                        let sessionDict = dict["session"] as? [String: Any],
                        let accountDict = dict["account"] as? [String: Any]  {
                        
                        self.userInfo.key = accountDict["key"] as? String
                        self.sessionId = sessionDict["id"] as? String
                        
                        self.getUserInfo(completion: { err in
                            
                        })
                    } else {
                        errString = "Couldn't parse response"
                    }
                } else {
                    errString = "Provided login credintials didn't match our records"
                }
            } else {
                errString = "Check your internet connection"
            }
            DispatchQueue.main.async {
                completion(errString)
            }
            
        }
        task.resume()
    }
    
    
    
    static func getUserInfo(completion: @escaping (Error?)->Void) {
        
//        let url = URL(string: "\(APIConstants.PUBLIC_USER)/\(userId)")
//        let request = URLRequest(url: url)

        let request = URLRequest(url: URL(string: "https://onthemap-api.udacity.com/v1/users/3903878747")!)
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            let range = (5..<data!.count)
            let new = data?.subdata(in: range)
            print(String(data: new!, encoding: .utf8)!)
            if let object = try? JSONSerialization.jsonObject(with: new!, options: [.allowFragments]) as? [String: Any]
            {
               self.userInfo.firstName = object?["first_name"] as? String
               self.userInfo.lastName = object?["last_name"] as? String
                
                print(self.userInfo.firstName!)
                print(self.userInfo.lastName!)
            }
            }.resume()
        
    
    }
    
    static func deleteSession (completion: @escaping (String?)->Void) {
        
        guard let url = URL(string: APIConstants.SESSION) else {
            completion("Supplied url is invalid")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.delete.rawValue
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil { // Handle error…
                return
            }
            let range = (5..<data!.count)
            let newData = data?.subdata(in: range) /* subset response data! */
            print(String(data: newData!, encoding: .utf8)!)
        }
        task.resume()
        
    }
    
    class Parser {
        
        static func getStudentLocations(limit: Int = 100, skip: Int = 0, orderBy: SLParam = .updatedAt, completion: @escaping (LocationsData?)->Void) {
            guard let url = URL(string: "\(APIConstants.STUDENT_LOCATION)?\(APIConstants.ParameterKeys.LIMIT)=\(limit)&\(APIConstants.ParameterKeys.SKIP)=\(skip)&\(APIConstants.ParameterKeys.ORDER)=-\(orderBy.rawValue)") else {
                completion(nil)
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = HTTPMethod.get.rawValue
            request.addValue(APIConstants.HeaderValues.PARSE_APP_ID, forHTTPHeaderField: APIConstants.HeaderKeys.PARSE_APP_ID)
            request.addValue(APIConstants.HeaderValues.PARSE_API_KEY, forHTTPHeaderField: APIConstants.HeaderKeys.PARSE_API_KEY)
            let session = URLSession.shared
            let task = session.dataTask(with: request) { data, response, error in
                var studentLocations: [StudentLocation] = []
                if let statusCode = (response as? HTTPURLResponse)?.statusCode { //Request sent succesfully
                    if statusCode >= 200 && statusCode < 300 { //Response is ok
                        
                        if let json = try? JSONSerialization.jsonObject(with: data!, options: []),
                            let dict = json as? [String:Any],
                            let results = dict["results"] as? [Any] {
                            
                            for location in results {
                                let data = try! JSONSerialization.data(withJSONObject: location)
                                let studentLocation = try! JSONDecoder().decode(StudentLocation.self, from: data)
                                studentLocations.append(studentLocation)
                            }
                            
                        }
                    }
                }
                
                DispatchQueue.main.async {
                    completion(LocationsData(studentLocations: studentLocations))
                }
                
            }
            task.resume()
        }
        
        static func postLocation(_ location: StudentLocation, completion: @escaping (String?)->Void) {
            
            var request = URLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation")!)
            request.httpMethod = "POST"
            request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
            request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = "{\"uniqueKey\": \"1234\", \"firstName\": \"John\", \"lastName\": \"Doe\",\"mapString\": \"Cupertino, CA\", \"mediaURL\": \"https://udacity.com\",\"latitude\": 37.322998, \"longitude\": -122.032182}".data(using: .utf8)
            
            // Does not work when i try it :(
//            request.httpBody = "{\"uniqueKey\": \"\(userInfo.key)\", \"firstName\": \"\(userInfo.firstName)\", \"lastName\": \"\(userInfo.lastName)\",\"mapString\": \"\(location.mapString)\", \"mediaURL\": \"\(location.mediaURL)\",\"latitude\": \(location.latitude), \"longitude\": \(location.longitude)}".data(using: .utf8)

            
            let session = URLSession.shared
            let task = session.dataTask(with: request) { data, response, error in
                if error != nil { // Handle error…
                    return
                }
                print(String(data: data!, encoding: .utf8)!)
            }
            task.resume()

            
            
        }
        
    }
    
    
    
}
