//
//  API.swift
//  PBL5
//
//  Created by Minh Quan on 28/05/2023.
//

import UIKit

var BASE_DOMAIN = "http://192.168.69.103"

func sendImageToAPI(imageBase64: String, completion: @escaping(String) -> (Void), failure: @escaping() -> (Void)) {
    guard let url = URL(string: "\(BASE_DOMAIN):5000/transfer") else {
        print("Invalid URL")
        failure()
        return
    }
    
//    guard let url = URL(string: "http://10.20.0.198:5001/recognize") else {
//        print("Invalid URL")
//        failure()
//        return
//    }
    
    // Create the JSON payload
    let payload: [String: Any] = ["image": imageBase64]
    
    do {
        // Convert the payload to JSON data
        let jsonData = try JSONSerialization.data(withJSONObject: payload, options: [])
        
        // Create the URL request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        // Perform the request
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                failure()
                return
            }
            
            if let data = data {
                // Handle the response data
                let responseString = String(data: data, encoding: .utf8)
                print("Response: \(responseString ?? "")")
                completion(responseString ?? "Error")
            }
        }
        
        task.resume()
    } catch {
        print("Error: \(error.localizedDescription)")
        failure()
    }
}

func extractValueFromResponse(responseString: String, key: String) -> String? {
    guard let jsonData = responseString.data(using: .utf8) else {
        print("Invalid response data")
        return nil
    }

    do {
        let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: [])
        guard let jsonDictionary = jsonObject as? [String: Any],
              let value = jsonDictionary[key] as? String else {
            print("Invalid response structure or missing key")
            return nil
        }
        
        return value
    } catch {
        print("Error: \(error.localizedDescription)")
        return nil
    }
}
