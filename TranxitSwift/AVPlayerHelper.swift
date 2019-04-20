//
//  AVPlayerHelper.swift
//  User
//
//  Created by CSS on 03/04/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import Foundation
import AVFoundation

class AVPlayerHelper {
    
    private var player : AVAudioPlayer?
    
    // Play audio
    
    func play(file name : String? = "outgoing.aiff", isLooped : Bool = true){
        
        if let path = Bundle.main.path(forResource: name, ofType: nil){
            
            let url = URL(fileURLWithPath: path)
            
            do {
                
                self.player = try AVAudioPlayer(contentsOf: url)
                self.player?.numberOfLoops = isLooped ? Int.max : 0
                self.player?.play()
                
            } catch let err {
                
                print("Error in playing audio ",err.localizedDescription)
            }
        }
    }
    
    //MARK:- Stop Audio
    
    func stop(){
     
        self.player?.stop()
    }
}
