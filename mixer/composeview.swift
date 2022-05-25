//
//  composeview.swift
//  mixer
//
//  Created by 蔡汎昀 on 2022/5/22.
//

import SwiftUI
import UIKit
import Foundation
import Combine
import AVFoundation

var composed=false

struct composeview: View {
    @Binding var created:Int
    @Binding var roomnum:String
    @State var responsestr=""
    @State var process=""

    var textFieldBorder: some View {
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray, lineWidth: 5)
    }
    
    var body: some View{
        
            VStack{
                HStack{
                    Button{
                        created=4
                    }label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(Color.gray)
                            .font(.system(size: 40))
                            .padding()
                    }
                    
                    Spacer()
                    
                }
                Spacer()
                
                if(responsestr=="Compose successful!!!" || responsestr=="" || responsestr=="Composing video ... "){
                    Text(responsestr)
                        .padding()
                        .font(.system(size: 30))
                        .foregroundColor(Color.red)
                }else{
                    Text("Time stamp can not be matched, compose failed")
                        .padding()
                        .font(.system(size: 30))
                        .foregroundColor(Color.red)
                }
                
                
          
                
                Spacer()
                
                if(responsestr=="Compose successful!!!" || composed)
                {
                    if(process=="processing"){
                        Text("Downloading video ...")
                            .padding()
                            .font(.system(size: 20))
                            .foregroundColor(Color.red)
                    }
                    
                    Button{
                        let docsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
                        let destinationUrl = docsUrl?.appendingPathComponent("\(roomnum).mp4")

                        if let destinationUrl = destinationUrl {
                            if FileManager().fileExists(atPath: destinationUrl.path) {
                                print("File already exists")
                                process="File already exists"
                                created=6
                                pre=5
                            } else {
                                var request = URLRequest(url: URL(string: "http://140.116.82.135:5000/Download_get_roomnumber")!)
                                request.httpMethod = "POST"
                                let sendtoserver="roomcode="+roomnum
                                let dat=sendtoserver.data(using: .utf8)
                                request.httpBody=dat

                                let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
                                    if let error = error {
                                        print("Request error: ", error)
                                        return
                                    }

                                    guard let response = response as? HTTPURLResponse else { return }

                                    if response.statusCode == 200 {
                                        guard let data = data else {
                                            print("404")
                                            return
                                        }
                                        let str = String(data:data, encoding: .utf8)
                                        print(str ?? "no response")
                                        if(str=="Haven't composed yet!!!")
                                        {
                                            process="no video"
                                        }else{
                                            DispatchQueue.main.async {
                                                do {
                                                    try data.write(to: destinationUrl, options: Data.WritingOptions.atomic)
                                                    DispatchQueue.main.async {
                         
                                                    }
                                                    print("download success")
                                                    downloaded=true
                                                    process="downloaded"
                                                    created=6
                                                    pre=5
                                                } catch let error {
                                                    print("Error decoding: ", error)
                                                }
                                            }
                                        }
                                    }
                                }
                                dataTask.resume()
                            }
                            
                            process="processing"
                            
                        }
                    }label: {
                        Text("Download video")
                            .padding()
                            .foregroundColor(Color.white)
                            .font(.system(size: 30))
                            .background(Color.gray)
                            .cornerRadius(10)
                    }.padding(50)
                    
                    
                }else
                {
                    Button{
                        
                        responsestr="Composing video ... "
                        
                        let sendtoserver="room_number=\(roomnum)&compose_file=compose"
                        let url = URL(string: "http://140.116.82.135:5000/Compose")!
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
                            if(str=="Compose successful!!!")
                            {
                                composed=true
                            }
                        }.resume()
                        
                    }label: {
                        Text("Compose")
                            .padding()
                            .frame(width: 200, height: 85)
                            .foregroundColor(Color.white)
                            .background(Color.red)
                    }.padding(50)
                }
                
                
             
                
            
            }
    }
}
