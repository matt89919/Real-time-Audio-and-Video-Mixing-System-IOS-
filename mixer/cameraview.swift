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

var filepath: String = ""

struct VideoRecordingView: UIViewRepresentable {
    
    @Binding var recording: Bool
    @Binding var valid: Bool
    
    func makeUIView(context: UIViewRepresentableContext<VideoRecordingView>) -> PreviewView {
        let recordingView = PreviewView()
        recordingView.recording=recording

        return recordingView
    }
    
    func updateUIView(_ uiViewController: PreviewView, context: UIViewRepresentableContext<VideoRecordingView>) {
        if recording
        {
            uiViewController.startRecording()
            
        }else
        {
            uiViewController.stopRecording()
            
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
    
    func startRecording(){
            recording = true
            
            captureSession?.addOutput(videoFileOutput)
            print("start RECORDING \(videoFileOutput.isRecording)")
            
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let filePath = documentsURL.appendingPathComponent("\(Date().toString(dateFormat: "YYYY_MM_dd_HH_mm_ss"))")
            filepath=filePath.path
            
            videoFileOutput.startRecording(to: filePath, recordingDelegate: recordingDelegate)
        
            let d = Date()
            let df = DateFormatter()
            df.dateFormat = "y_MM_dd_H_mm_ss_SSS"
            let timestamp1=df.string(from: d)
            print(timestamp1)
    }
    
    func stopRecording(){
        recording = false
        recorded = true
        videoFileOutput.stopRecording()
        
        print("🔴 RECORDING \(videoFileOutput.isRecording)")
        
        let d = Date()
        let df = DateFormatter()
        df.dateFormat = "y_MM_dd_H_mm_ss_SSS"
        let timestamp1=df.string(from: d)
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
                    if recorded == false{
                        VideoRecordingView(recording: $recording, valid: $valid)
                    }else{
                        Text("starting timestamp: \n"+timestamp1)
                            .font(.system(size: 25))
                            .foregroundColor(.gray)
                            .padding()
                        
                        Text("stopping timestamp: \n"+timestamp2)
                            .font(.system(size: 25))
                            .foregroundColor(.gray)
                            .padding()
                    
                    
                        Text(filepath)
                            .font(.system(size: 20))
                            .foregroundColor(.gray)
                            .padding()
                    }
                    Spacer()
                }
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
                        
                        Button
                        {
                            self.recording.toggle()
                            if recording
                            {
                                let d = Date()
                                let df = DateFormatter()
                                df.dateFormat = "y_MM_dd_H_mm_ss_SSS"
                                timestamp1=df.string(from: d)
                            }else{
                                let d = Date()
                                let df = DateFormatter()
                                df.dateFormat = "y_MM_dd_H_mm_ss_SSS"
                                timestamp2=df.string(from: d)
                                if timestamp1 != ""
                                {
                                    recorded=true
                                }
                            }
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
                        

                    }
        }
        }
}



