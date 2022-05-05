//
//  recordview.swift
//  mixer
//
//  Created by 蔡汎昀 on 2022/4/29.
//

import SwiftUI
import UIKit
import Foundation
import Combine
import AVFoundation
import Alamofire

struct recordView: View {
    @Binding var created:Int
    @Binding var roomnum:String
    @ObservedObject var audioRecorder: AudioRecorder
    @State var hours: Int = 0
    @State var minutes: Int = 0
    @State var seconds: Int = 0
    @State var timerIsPaused: Bool = true
    @State var timer: Timer? = nil
    @State var fileurl: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    @State var recorded: Bool = false
    
    
    var body: some View{
        
        VStack {
            HStack{
                Button{
                    created=2
                }label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(Color.gray)
                        .font(.system(size: 40))
                        .padding()
                }
                
                Spacer()
                
            }
            
            Spacer()
            List {
                ForEach(audioRecorder.recordings, id: \.createdAt) { recording in
                RecordingRow(audioURL: recording.fileURL)
                }
            }
            
            Text("\(hours):\(minutes):\(seconds)")
                .font(.system(size: 50))
                .foregroundColor(.gray)
                .padding(50)
            
            HStack{
                
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                
                if audioRecorder.recording == false {
                    Button(action: {
                        fileurl = self.audioRecorder.startRecording()
                        startTimer()
                    }) {
                        Image(systemName: "record.circle")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 100, height: 100, alignment: .center)
                            .clipped()
                            .foregroundColor(.red)
                            .padding(.bottom, 40)
                    }
                } else {
                    Button(action: {
                        self.audioRecorder.stopRecording()
                        stopTimer()
                        recorded=true
                    }) {
                        Image(systemName: "record.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 100, height: 100)
                            .clipped()
                            .foregroundColor(.red)
                            .padding(.bottom, 40.0)
                    }
                }
                
                Spacer()
                
                Button{
                    if(recorded==true){
                        let voiceData = try? Data(contentsOf: fileurl)
                        let filename = fileurl.lastPathComponent
                        let url = URL(string: "http://140.116.82.135:5000/Audio_store")!
    //                        let headers : Alamofire.HTTPHeaders = [
    //                                    "cache-control" : "no-cache",
    //                                    "Accept-Language" : "en",
    //                                    "Connection" : "close"
    //                                ]
                             //generate boundary string using a unique per-app string
                        let boundary = UUID().uuidString
                                                    let session = URLSession.shared
                                                    var urlRequest = URLRequest(url: url)
                                                    urlRequest.httpMethod = "POST"
                                                    urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

                                                    var data = Data()

                                                    data.append("--\(boundary)\r\n".data(using: .utf8)!)
                                                    data.append("Content-Disposition: form-data; name=\"audio\"; filename=\"\(filename)\"\r\n\r\n".data(using: .utf8)!)
                                                    data.append(voiceData!)
                                                    data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
                                                    data.append("Content-Disposition: form-data; name=\"audio_info\"; filename=\"1111.txt\"\r\n\r\n".data(using: .utf8)!)
                                                    data.append(voiceData!)
                                                    data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
                                                    data.append("Content-Disposition: form-data; name=\"room_number\"\r\n\r\n\(roomnum)".data(using: .utf8)!)
                                                    data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

                                                    // Send a POST request to the URL, with the data we created earlier
                                                    session.uploadTask(with: urlRequest, from: data, completionHandler: { data, response, error in
                                                        guard let data = data,
                                                              let response = response as? HTTPURLResponse,
                                                              error == nil else{
                                                              print("err")
                                                              return
                                                        }
                                                        let str = String(data:data, encoding: .utf8)
                                                        print(str ?? "no response")
                                                       // responsestr = str ?? ""
                                                    }).resume()
                    }else{
                        print("didnt recorded yet!")
                    }
                        
                }label:
                {
                    Image(systemName: "square.and.arrow.up.fill")
                        .resizable()
                        .frame(width: 40, height: 50)
                        
                        .foregroundColor(.gray)
                        .padding(.bottom, 40)
                }
                
                Spacer()
                Spacer()
            
                
            }
        }
        
    }
    
    func startTimer(){
        timerIsPaused = false
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true){ tempTimer in
          if self.seconds == 59 {
            self.seconds = 0
            if self.minutes == 59 {
              self.minutes = 0
              self.hours = self.hours + 1
            } else {
              self.minutes = self.minutes + 1
            }
          } else {
            self.seconds = self.seconds + 1
          }
        }
    }
      
    func stopTimer(){
        timerIsPaused = true
        minutes=0
        hours=0
        seconds=0
        timer?.invalidate()
        timer = nil
    }
    
}

