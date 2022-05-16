//
//  joinview.swift
//  mixer
//
//  Created by 蔡汎昀 on 2022/4/29.
//

import SwiftUI
import UIKit
import Foundation
import Combine
import AVFoundation

//still have some problem deal with server
func downloadFile(roomnum: String) {
    var isDownloading = true

    let docsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first

    let destinationUrl = docsUrl?.appendingPathComponent("\(roomnum).mp4")

    if let destinationUrl = destinationUrl {
        if FileManager().fileExists(atPath: destinationUrl.path) {
            print("File already exists")
            isDownloading = false
        } else {
            var request = URLRequest(url: URL(string: "http://140.116.82.135:5000/Download")!)
            request.httpMethod = "POST"
            let sendtoserver="roomnum="+roomnum
            let dat=sendtoserver.data(using: .utf8)
            request.httpBody=dat

            let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    print("Request error: ", error)
                    isDownloading = false
                    return
                }

                guard let response = response as? HTTPURLResponse else { return }

                if response.statusCode == 200 {
                    guard let data = data else {
                        isDownloading = false
                        return
                    }
                    DispatchQueue.main.async {
                        do {
                            try data.write(to: destinationUrl, options: Data.WritingOptions.atomic)
                            DispatchQueue.main.async {
                                isDownloading = false
                            }
                        } catch let error {
                            print("Error decoding: ", error)
                            isDownloading = false
                        }
                    }
                }
            }
            dataTask.resume()
        }
    }
}

struct joinView: View {
    @Binding var created:Int
    @Binding var roomnum:String
    @Binding var framerate:String
    var textFieldBorder: some View {
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray, lineWidth: 5)
        }
    
    var body: some View{
        
            VStack{
                HStack{
                    Button{
                        created=0
                    }label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(Color.gray)
                            .font(.system(size: 40))
                            .padding()
                    }
                    
                    Spacer()
                    
                }
                
                Spacer()
                
                Button{
                    downloadFile(roomnum: roomnum)
                    
                }label: {
                    Text("Download video")
                        .padding()
                        .foregroundColor(Color.white)
                        .font(.system(size: 30))
                        .background(Color.gray)
                        .cornerRadius(10)
                }
                
                Spacer()
                
                HStack{
                    Button{
                        let sendtoserver="roomcode="+roomnum
                        let url = URL(string: "http://140.116.82.135:5000/sendsettingtoclient")!
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
                            framerate=str ?? "44100"

                        }.resume()
                        
                        created=3
                    }label: {
                        ZStack{
                            Image(systemName: "rectangle.portrait.fill")
                                .foregroundColor(Color.gray)
                                .font(.system(size: 150))
                            
                            VStack{
                                Text("audio\nrecorder")
                                    .foregroundColor(Color.white)
                                    .font(.system(size: 25))
                                    .padding(.bottom, 4.0)
                                
                                Image(systemName: "record.circle")
                                    .foregroundColor(Color.white)
                                    .font(.system(size: 60))
                            }
                        }
                    }
                    
                    
                    Button{
                        created=4
                    }label: {
                        ZStack{
                            Image(systemName: "rectangle.portrait.fill")
                                .foregroundColor(Color.gray)
                                .font(.system(size: 150))
                            
                            VStack{
                                Text("video\nrecorder")
                                    .foregroundColor(Color.white)
                                    .font(.system(size: 25))
                                    .padding(.bottom, 4.0)
                                
                                Image(systemName: "camera")
                                    .foregroundColor(Color.white)
                                    .font(.system(size: 60))
                            }
                        }
                    }
                    
                    
                    
                }
                
                Spacer()
            
            }
    }
}
