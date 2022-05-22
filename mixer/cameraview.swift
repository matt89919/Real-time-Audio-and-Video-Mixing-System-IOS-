//
//  cameraview.swift
//  mixer
//
//  Created by 蔡汎昀 on 2022/4/29.
//

import SwiftUI
import UIKit
import Foundation
import Combine
import AVFoundation

var filepath: URL?

struct VideoRecordingView: UIViewRepresentable {
    
    @Binding var recording: Bool
    @Binding var valid: Bool
    @Binding var ts1: String
    @Binding var ts2: String
    
    func makeUIView(context: UIViewRepresentableContext<VideoRecordingView>) -> PreviewView {
        let recordingView = PreviewView()
        recordingView.recording=recording

        return recordingView
    }
    
    func updateUIView(_ uiViewController: PreviewView, context: UIViewRepresentableContext<VideoRecordingView>) {
        if recording
        {
            uiViewController.startRecording(ts1: ts1)
            
        }else
        {
            uiViewController.stopRecording(ts2: ts2)
            
        }
    }
    
}
extension PreviewView: AVCaptureFileOutputRecordingDelegate{
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        print(outputFileURL.absoluteString)
        
    }
}

class PreviewView: UIView {
    private var captureSession: AVCaptureSession?
    private var shakeCountDown: Timer?
    let videoFileOutput = AVCaptureMovieFileOutput()
    
    var recordingDelegate:AVCaptureFileOutputRecordingDelegate!
    var recording = false
    var recorded = false
    
    
    

    
    init() {
        super.init(frame: .zero)
        
        var allowedAccess = false
        let blocker = DispatchGroup()
        blocker.enter()
        AVCaptureDevice.requestAccess(for: .video) { flag in
            allowedAccess = flag
            blocker.leave()
        }
        blocker.wait()
        
        if !allowedAccess {
            print("!!! NO ACCESS TO CAMERA")
            return
        }
        
        // setup session
        let session = AVCaptureSession()
        session.beginConfiguration()
        
        let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                  for: .video, position: .back)
        guard videoDevice != nil, let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice!), session.canAddInput(videoDeviceInput) else {
            print("!!! NO CAMERA DETECTED")
            return
        }
        session.addInput(videoDeviceInput)
        session.commitConfiguration()
        self.captureSession = session
    }
    
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        recordingDelegate = self
        if nil != self.superview {
            self.videoPreviewLayer.session = self.captureSession
            self.videoPreviewLayer.videoGravity = .resizeAspect
            self.captureSession?.startRunning()
        } else {
            self.captureSession?.stopRunning()
        }
    }
    
    func startRecording(ts1:String){
            recording = true
            let connection = videoFileOutput.connection(with: .video)
            if videoFileOutput.availableVideoCodecTypes.contains(.h264) {
                // Use the H.264 codec to encode the video.
                videoFileOutput.setOutputSettings([AVVideoCodecKey: AVVideoCodecType.h264], for: connection!)
            }
            captureSession?.addOutput(videoFileOutput)
            print("start RECORDING \(videoFileOutput.isRecording)")
            
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let filePath = documentsURL.appendingPathComponent("\(ts1.prefix(19)).mov")
            filepath=filePath
            
            videoFileOutput.startRecording(to: filePath, recordingDelegate: recordingDelegate)
        
            let timestamp1=ts1
            print(timestamp1)
    }
    
    func stopRecording(ts2:String){
        recording = false
        recorded = true
        videoFileOutput.stopRecording()
        
        print("🔴 RECORDING \(videoFileOutput.isRecording)")
        
        let timestamp1=ts2
        print(timestamp1)
    }
}

   
struct cameraview: View {
    @Binding var created:Int
    @Binding var roomnum:String
    @State private var recording = false
    @State var valid = true
    @State var recorded = false
    @State var timestamp1 = ""
    @State var timestamp2 = ""
    @State var fileurl: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    
    var body: some View {
                
            ZStack{
                VStack
                {
                    Spacer()
                    if !recorded
                    {
                        VideoRecordingView(recording: $recording, valid: $valid, ts1: $timestamp1, ts2: $timestamp2)
                    }else
                    {
                        Text("starting timestamp: \n"+timestamp1)
                            .font(.system(size: 25))
                            .foregroundColor(.gray)
                            .padding()
                        
                        Text("stopping timestamp: \n"+timestamp2)
                            .font(.system(size: 25))
                            .foregroundColor(.gray)
                            .padding()
                    
                    
                        Text(filepath!.absoluteString)
                            .font(.system(size: 20))
                            .foregroundColor(.gray)
                            .padding()
                    }
                    Spacer()
                }
                VStack
                {
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
                    
                        if !recorded
                        {
                            Button
                            {
                                
                                if !recording
                                {
                                    timestamp1=getTS()
                                }else{
                                    timestamp2=getTS()
                                    if timestamp1 != ""
                                    {
                                        recorded=true
                                    }
                                }
                                self.recording.toggle()
                            }label: {
                                ZStack {
                                    Circle()
                                        .fill(Color.red)
                                        .frame(width: 65, height: 65)
                                    
                                    Circle()
                                        .stroke(Color.white,lineWidth: 2)
                                        .frame(width: 75, height: 75)
                                }
                            }
                        }else
                        {
                            Button{
                                if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                                    let fp = filepath
                                    let file = "video_time_info"+fp!.lastPathComponent.replacingOccurrences(of: ".mov", with: ".txt")
                                    let infourl = dir.appendingPathComponent(file)
                                    //writing
                                    do {
                                        let tsinfo=timestamp1+"\n"+timestamp2
                                        try tsinfo.write(to: infourl, atomically: false, encoding: .utf8)
                                        print("success")
                                        print(infourl)
                                    }
                                    catch {
                                        print("error txt")
                                    }
                                    
                                    let videoData = try? Data(contentsOf: fp!)
                                    let infodata = try? Data(contentsOf: infourl)
                                    let filename = filepath!.lastPathComponent
                                    let infoname = infourl.lastPathComponent
                                    let url = URL(string: "http://140.116.82.135:5000/Video_store")!
              
                                    let boundary = UUID().uuidString
                                    let session = URLSession.shared
                                    var urlRequest = URLRequest(url: url)
                                    urlRequest.httpMethod = "POST"
                                    urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

                                    var data = Data()

                                    data.append("--\(boundary)\r\n".data(using: .utf8)!)
                                    data.append("Content-Disposition: form-data; name=\"video\"; filename=\"\(filename)\"\r\n\r\n".data(using: .utf8)!)
                                    data.append(videoData!)
                                    data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
                                    data.append("Content-Disposition: form-data; name=\"video_info\"; filename=\"\(infoname)\"\r\n\r\n".data(using: .utf8)!)
                                    data.append(infodata!)
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
                                }
                            }label: {
                                Image(systemName: "square.and.arrow.up.fill")
                                    .resizable()
                                    .frame(width: 40, height: 50)
                                    
                                    .foregroundColor(.gray)
                                    .padding(.bottom, 40)
                            }
                        }
                        

                    }
            }
        }
}



