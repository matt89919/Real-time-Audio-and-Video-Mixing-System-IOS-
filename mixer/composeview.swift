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
                
                Text(responsestr)
                    .padding()
                    .font(.system(size: 30))
                    .foregroundColor(Color.red)
                
                
          
                
                Spacer()
                
                if(responsestr=="Compose successful!!!" || downloaded)
                {
                    if(process=="processing"){
                        Text("Downloading video ...")
                            .padding()
                            .font(.system(size: 20))
                            .foregroundColor(Color.red)
                    }
                    
                    Button{
                        process=downloadFile(roomnum: roomnum)
                        if(process=="File already exists"){
                            downloaded=true
                            pre=5
                            created=6
                        }
                    }label: {
                        Text("Download video")
                            .padding()
                            .foregroundColor(Color.white)
                            .font(.system(size: 30))
                            .background(Color.gray)
                            .cornerRadius(10)
                    }.padding(50)
                    
                    .onChange(of: downloaded, perform: { _ in
                        if(downloaded==true){ pre=5; created=6 }
                    })
                    
                    
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
