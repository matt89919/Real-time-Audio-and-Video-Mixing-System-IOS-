//
//  firstview.swift
//  mixer
//
//  Created by 蔡汎昀 on 2022/4/29.
//

import SwiftUI
import UIKit
import Foundation
import Combine
import AVFoundation

struct firstview: View{
    @Binding var created:Int
    @Binding var roomnum:String
    @State var isactive=false
    @State var sendtoserver=""
    @State var isresponse=false
    @State var responsestr=""
    @State var statemsg=""
    var textFieldBorder: some View {
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray, lineWidth: 1)
        }
    
    
    var body: some View {
        
        NavigationView{
        
            VStack(){
                
                Spacer()
                Spacer()
                
                HStack(){
                    Spacer()
                    
                    Text("Room : ")
                        .foregroundColor(Color.gray)
                        .font(.system(size: 30))
                        .multilineTextAlignment(.leading)
                        .padding()
                    
                    Spacer()
                    Spacer()
                    Spacer()
                    }
                
                
                
                
                TextField("Enter room number", text: $roomnum,
                            prompt: Text("Enter room number").font(.system(size: 25)))
                        .padding()
                        .frame(width: 300.0, height: 75.0)
                        .overlay(textFieldBorder)
                        .keyboardType(.numberPad)
                
                Text(statemsg)
                    .font(.system(size: 22))
                    .foregroundColor(Color.red)
                    .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
                                   
                Spacer()
                            
                    Button {
                            // run your code
                            // send requset to server
                            sendtoserver="action=CREATE&room_number="+roomnum
                            let url = URL(string: "http://140.116.82.135:5000/Room")!
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
                            //end of request
                            
                            // then set
//                            if(isresponse==true){
//                                if(responsestr.prefix(2)=="Ok"){
//                                    created=2
//                                }
//                            }

                        } label: {
                            Text("CREATE")
                                .padding()
                                .frame(width: 200, height: 70)
                                .foregroundColor(Color.black)
                                .background(Color.gray)
                        }
                
                .onChange(of: responsestr, perform: { _ in
                    if(responsestr.prefix(2)=="Ok"){
                        created=1
                    }else if(responsestr.prefix(5)=="No, E"){
                        statemsg="Room exist, please use join"
                    }
                })
                
                Spacer()
                
                
                    Button {
                            // run your code
                            sendtoserver="action=JOIN&room_number="+roomnum
                            let url = URL(string: "http://140.116.82.135:5000/Room")!
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
                            // then set
                            //isactive = true

                        } label: {
                            Text("JOIN")
                                .padding()
                                .frame(width: 200, height: 70)
                                .foregroundColor(Color.black)
                                .background(Color.gray)
                        }
                        .onChange(of: responsestr, perform: { _ in
                            if(responsestr.prefix(3)=="Yes"){
                                created=2
                            }else if(responsestr.prefix(5)=="No, r"){
                                statemsg="Room not exist, please confirm room number or create it"
                            }
                        })
                
                
                
                
                Spacer()
                
            }
        }
    }
    
}

