//
//  ClientNetworking.swift
//  BookLibrary
//
//  Created by Venugopal Reddy Devarapally on 22/05/17.
//  Copyright © 2017 Venugopal Reddy Devarapally. All rights reserved.
//

import Foundation

// Mark: Networking

func taskForGetBooksList(completionHandlerForGET: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
    var urlStr = "https://gist.githubusercontent.com/mdunbavan/9f4a6f9795e89110859a0d72aebcb589/raw/fcc7b2c4590453eed41def69c02829165c52143d/books.json"
    /*if itemId == itemId && itemId != -1{
        urlStr = Constants.HackerNews.APIBaseURL + "item/" + String(describing: itemId) + ".json"
    }*/
    
    let url = URL(string: urlStr)
    let request = URLRequest(url: url!)
    
    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
        func sendError(_ error: String) {
            print(error)
            let userInfo = [NSLocalizedDescriptionKey : error]
            completionHandlerForGET(nil, NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
        }
        
        /* GUARD: Was there an error? */
        guard (error == nil) else {
            sendError("There was an error with your request: \(error)")
            return
        }
        
        /* GUARD: Did we get a successful 2XX response? */
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
            sendError("Your request returned a status code other than 2xx!")
            return
        }
        
        /* GUARD: Was there any data returned? */
        guard let data = data else {
            sendError("No data was returned by the request!")
            return
        }
        
        convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForGET)
    }
    
    task.resume()
    
    return task
}

func convertDataWithCompletionHandler(_ data: Data, completionHandlerForConvertData: (_ result: AnyObject?, _ error: NSError?) -> Void) {
    
    var parsedResult: AnyObject! = nil
    do {
        parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
    } catch {
        let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
        completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
    }
    
    completionHandlerForConvertData(parsedResult, nil)
}





