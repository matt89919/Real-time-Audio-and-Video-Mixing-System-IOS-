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

class AudioRecorder: NSObject,ObservableObject {
    
    override init() {
            super.init()
            fetchRecordings()
        }
    
    let objectWillChange = PassthroughSubject<AudioRecorder, Never>()
    var recording = false {
            didSet {
                objectWillChange.send(self)
            }
        }
    var audioRecorder: AVAudioRecorder!
    var recordings = [Recording]()
    struct Recording {
        let fileURL: URL
        let createdAt: Date
    }
    
    
    func fetchRecordings() {
            recordings.removeAll()
        
            let fileManager = FileManager.default
            let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let directoryContents = try! fileManager.contentsOfDirectory(at: documentDirectory, includingPropertiesForKeys: nil)
            for audio in directoryContents {
                        let recording = Recording(fileURL: audio, createdAt: getCreationDate(for: audio))
                        recordings.append(recording)
                    }
        
            recordings.sort(by: { $0.createdAt.compare($1.createdAt) == .orderedAscending})
            objectWillChange.send(self)
        }
    
    func getCreationDate(for file: URL) -> Date {
        if let attributes = try? FileManager.default.attributesOfItem(atPath: file.path) as [FileAttributeKey: Any],
            let creationDate = attributes[FileAttributeKey.creationDate] as? Date {
            return creationDate
        } else {
            return Date()
        }
    }
    
    func startRecording() {
        let recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
        } catch {
            print("Failed to set up recording session")
        }
        
        
        let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioFilename = documentPath.appendingPathComponent("\(Date().toString(dateFormat: "dd-MM-YY_'at'_HH:mm:ss")).m4a")
        
        ////////
        let settings = [
                    AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                    AVSampleRateKey: 12000,
                    AVNumberOfChannelsKey: 1,
                    AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
                ]
        
        do {
                    audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
                    audioRecorder.record()
                    recording = true
                } catch {
                    print("Could not start recording")
                }
        
        //////////
    }
    
    func stopRecording() -> AVAudioRecorder {
            audioRecorder.stop()
            recording = false
            fetchRecordings()
            return audioRecorder
    }
}
/*
struct ImagePickerView: UIViewControllerRepresentable {

    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) var isPresented
    var sourceType: UIImagePickerController.SourceType

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = self.sourceType
        return imagePicker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {

    }
}
 */
struct RecordingRow: View {
    
    var audioURL: URL
    
    var body: some View {
        HStack {
            Text("\(audioURL.lastPathComponent)")
            Spacer()
        }
    }
}



struct recordView: View {
    
    @ObservedObject var audioRecorder: AudioRecorder
    @State var hours: Int = 0
    @State var minutes: Int = 0
    @State var seconds: Int = 0
    @State var timerIsPaused: Bool = true
    @State var timer: Timer? = nil
    
    var body: some View{
        
        VStack {
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




struct joinView: View {
    
    var textFieldBorder: some View {
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray, lineWidth: 5)
        }
    
    var body: some View{
        
        VStack(){
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
                NavigationLink(destination: recordView(audioRecorder: AudioRecorder())){
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
                
                NavigationLink(destination: Text("camera")){
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

struct ContentView: View {
    
    @State var roomnum=""
    @State var isactive=true
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
                
                
                Spacer()
                Spacer()
                
                
                NavigationLink(destination: {Text("create")} ) {
                    Text("CREATE")
                        .padding()
                        .frame(width: 200, height: 70)
                        .foregroundColor(Color.black)
                        .background(Color.gray)
                }
                
                Spacer()
                
                NavigationLink(destination: joinView()) {
                    Text("JOIN")
                        .padding()
                        .frame(width: 200, height: 70)
                        .foregroundColor(Color.black)
                        .background(Color.gray)
                }
                
                
                
                
                Spacer()
                
            }
        }

      
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}