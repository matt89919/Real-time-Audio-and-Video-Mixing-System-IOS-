//
//  ContentView.swift
//  mixer
//
//  Created by 蔡汎昀 on 2022/3/28.
//

import SwiftUI
import UIKit
import Foundation
import Combine
import AVFoundation

public func getTS() -> String
{
    var responsestr=""
    let sendtoserver="date_request=1"
    let url = URL(string: "http://140.116.82.135:5000/timesynchronize")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    let dat=sendtoserver.data(using: .utf8)
    request.httpBody=dat

    URLSession.shared.dataTask(with: request){ data, response, error in
        guard let data = data,
              let response = response as? HTTPURLResponse,
              error == nil else{
              print("err")
              return
        }
        
        let str = String(data:data, encoding: .utf8)
        print(str ?? "no response")
        responsestr = str ?? ""

    }.resume()
    
    while(responsestr==""){}
    
    return responsestr
}


struct ContentView: View {
    @State var created = 0
    @State var roomnum = ""
    @State var framerate = ""
    var body: some View{
        switch created{
        case 1:
            createView(created: $created, roomnum: $roomnum)
        case 2:
            joinView(created: $created, roomnum: $roomnum, framerate: $framerate)
        case 3:
            recordView(created: $created, roomnum: $roomnum, framerate: $framerate, audioRecorder: AudioRecorder())
        case 4:
            cameraview(created: $created, roomnum: $roomnum)
            
        case 5:
            composeview(created: $created, roomnum: $roomnum)
            
        case 6:
            watchview(created: $created, roomnum: $roomnum)
            
        default:
            firstview(created: $created, roomnum: $roomnum)
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
