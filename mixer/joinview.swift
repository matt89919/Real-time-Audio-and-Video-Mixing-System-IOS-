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

var downloaded=false
var processs=""
//still have some problem deal with server
func downloadFile(roomnum: String) -> String{
    
    let docsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    let destinationUrl = docsUrl?.appendingPathComponent("\(roomnum).mp4")

    if let destinationUrl = destinationUrl {
        if FileManager().fileExists(atPath: destinationUrl.path) {
            print("File already exists")

            return "File already exists"
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
                        processs="no video"
                    }else{
                        DispatchQueue.main.async {
                            do {
                                try data.write(to: destinationUrl, options: Data.WritingOptions.atomic)
                                DispatchQueue.main.async {
     
                                }
                                print("download success")
                                downloaded=true
                                processs="downloaded"
                            } catch let error {
                                print("Error decoding: ", error)
                       
                            }
                        }
                    }
                }
            }
            dataTask.resume()
        }
        
    }
    return "processing"
}

func checkFileExists(roomnum: Int) -> Bool{
    let docsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first

    let destinationUrl = docsUrl?.appendingPathComponent("\(roomnum).mp4")
    if let destinationUrl = destinationUrl {
        if (FileManager().fileExists(atPath: destinationUrl.path)) {
            return true
        } else {
            return false
        }
    } else {
        return false
    }
}

struct joinView: View {
    @Binding var created:Int
    @Binding var roomnum:String
    @Binding var framerate:String
    @State var process=""

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
                if(pre==1){
                    Text("Room: \(roomnum) [HOST]")
                        .padding(50)
                        .font(.system(size: 30))
                        .foregroundColor(Color.gray)
                }else{
                    Text("Room: \(roomnum) [Guest]")
                        .padding(50)
                        .font(.system(size: 30))
                        .foregroundColor(Color.gray)
                }
                
                
                
               
                
                Button{
                    
                    let docsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
                    let destinationUrl = docsUrl?.appendingPathComponent("\(roomnum).mp4")

                    if let destinationUrl = destinationUrl {
                        
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
                                                pre=2
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
                        
                    
                }label: {
                    Text("Download video")
                        .padding()
                        .foregroundColor(Color.white)
                        .font(.system(size: 30))
                        .background(Color.gray)
                        .cornerRadius(10)
                }
                
                
                if(process=="processing"){
                        Text("Downloading video ...")
                            .padding()
                            .font(.system(size: 20))
                            .foregroundColor(Color.red)
                }
                
                if(process=="no video")
                {
                    Text("Video haven't composed yet")
                        .padding()
                        .font(.system(size: 20))
                        .foregroundColor(Color.red)
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
//                    .onChange(of: process, perform: { _ in
//                        if(process=="downloaded"){
//                            created=6
//                            pre=2
//                        }else{
//                            print("create failed")
//                        }
//                    })
            }
    }
}
