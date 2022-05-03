//
//  createview.swift
//  mixer
//
//  Created by 蔡汎昀 on 2022/4/29.
//

import SwiftUI
import UIKit
import Foundation
import Combine
import AVFoundation

struct createView: View {
    @Binding var created:Int
    @Binding var roomnum:String
    @State var rate="44100"
    @State var choosenstr="Please select your prefer audio framerate\n(default: 44.1 KHZ)"
    @State var responsestr=""
    var body: some View{
        
        VStack{
            HStack{
                Button{
                    created=0
                }label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(Color.black)
                        .font(.system(size: 40))
                        .padding([.top, .leading, .bottom])
                }
                
                Spacer()
                
                Text("Settings")
                    .font(.system(size: 35))
                    .padding()
                    .foregroundColor(Color.black)
                
                Spacer()
                Spacer()
            }
            
            Spacer()
            Spacer()
            
            Text(choosenstr)
                .padding()
                .font(.system(size: 20))
                .foregroundColor(Color.gray)
            
            Spacer()
            
            Button{
                rate="44100"
                choosenstr="You have choosen 44.1 KHZ"
            }label: {
                Text("44.1 KHZ")
                    .padding()
                    .frame(width: 200, height: 50)
                    .foregroundColor(Color.black)
                    .background(Color.gray)
            }
            
            Button{
                rate="16000"
                choosenstr="You have choosen 16 KHZ"
            }label: {
                Text("16 KHZ")
                    .padding()
                    .frame(width: 200, height: 50)
                    .foregroundColor(Color.black)
                    .background(Color.gray)
            }
            
            Button{
                rate="8000"
                choosenstr="You have choosen 8 KHZ"
            }label: {
                Text("8 KHZ")
                    .padding()
                    .frame(width: 200, height: 50)
                    .foregroundColor(Color.black)
                    .background(Color.gray)
            }
            
            Button{
                let sendtoserver="roomnumbersetting="+roomnum+"&audioSetting="+rate
                let url = URL(string: "http://192.168.0.101:8000/Setting")!
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
                
            }label: {
                Text("Confirm")
                    .padding()
                    .frame(width: 200, height: 50)
                    .foregroundColor(Color.white)
                    .background(Color.red)
            }.padding(50.0)
            
                .onChange(of: responsestr, perform: { _ in
                    if(responsestr.prefix(2)=="SU"){
                        created=2
                    }else{
                        print("create failed")
                    }
                })
            
            Spacer()
                
        }
    }
}


