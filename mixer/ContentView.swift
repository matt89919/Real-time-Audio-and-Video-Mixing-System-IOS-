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

struct ContentView: View {
    @State var created = 0
    @State var roomnum = ""
    var body: some View{
        switch created{
        case 1:
            createView(created: $created, roomnum: $roomnum)
        case 2:
            joinView(created: $created, roomnum: $roomnum)
        case 3:
            recordView(created: $created, roomnum: $roomnum, audioRecorder: AudioRecorder())
        case 4:
            cameraview(created: $created, roomnum: $roomnum)
            
        default:
            firstview(created: $created, roomnum: $roomnum)
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
