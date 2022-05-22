//
//  watchview.swift
//  mixer
//
//  Created by 蔡汎昀 on 2022/5/22.
//

import SwiftUI
import UIKit
import Foundation
import Combine
import AVFoundation
import AVKit

var pre=0

func getVideoFileAsset(roomnum: String) -> AVPlayerItem? {
    let docsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first

    let destinationUrl = docsUrl?.appendingPathComponent("\(roomnum).mp4")
    if let destinationUrl = destinationUrl {
        if (FileManager().fileExists(atPath: destinationUrl.path)) {
            let avAssest = AVAsset(url: destinationUrl)
            return AVPlayerItem(asset: avAssest)
        } else {
            return nil
        }
    } else {
        return nil
    }
}


struct watchview: View {
    @Binding var created: Int
    @Binding var roomnum: String
    
    var body: some View {
        
        HStack{
            Button{
                created=pre
            }label: {
                Image(systemName: "chevron.left")
                    .foregroundColor(Color.gray)
                    .font(.system(size: 40))
                    .padding()
            }
            
            Spacer()
            
        }
        
        let player = AVPlayer(playerItem: getVideoFileAsset(roomnum: roomnum))
        VideoPlayer(player: player)
    }
}
