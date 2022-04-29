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

struct recordView: View {
    @Binding var created:Int
    @ObservedObject var audioRecorder: AudioRecorder
    @State var hours: Int = 0
    @State var minutes: Int = 0
    @State var seconds: Int = 0
    @State var timerIsPaused: Bool = true
    @State var timer: Timer? = nil
    
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
                        self.audioRecorder.startRecording()
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
                Button(action: {print("upload")})
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

