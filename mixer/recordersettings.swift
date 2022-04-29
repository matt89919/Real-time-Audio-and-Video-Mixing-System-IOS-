//
//  recordersettings.swift
//  mixer
//
//  Created by 蔡汎昀 on 2022/4/29.
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

struct RecordingRow: View {
    
    var audioURL: URL
    
    var body: some View {
        HStack {
            Text("\(audioURL.lastPathComponent)")
            Spacer()
        }
    }
}
