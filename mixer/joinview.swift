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
