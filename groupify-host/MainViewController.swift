//
//  ViewController.swift
//  groupify-host
//
//  Created by Noah Rubin on 1/20/18.
//  Copyright © 2018 Noah Rubin. All rights reserved.
//

import UIKit
import AVFoundation

class MainViewController: UIViewController, SPTAudioStreamingDelegate, SPTAudioStreamingPlaybackDelegate {
    
    @IBOutlet weak var groupifyID: UILabel!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var albumArtwork: UIImageView!
    @IBOutlet weak var songTitle: UILabel!
    @IBOutlet weak var albumTitle: UILabel!
    @IBOutlet weak var artistName: UILabel!
    
    let audioStreaming = SPTAudioStreamingController.sharedInstance()!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SPTAudioStreamingController.sharedInstance().delegate = self
        SPTAudioStreamingController.sharedInstance().playbackDelegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(MainViewController.queueSong), name: NSNotification.Name(rawValue: "queueSong"), object: nil)
        
        if let shuffle = Queue.instance.shuffleDefaultPlaylist {
            audioStreaming.setShuffle(shuffle, callback: nil)
        }
        
        if let startingPlaylist = Queue.instance.defaultPlaylist {
            audioStreaming.playSpotifyURI(startingPlaylist.uri.absoluteString, startingWith: 0, startingWithPosition: 0) {error in if let e = error {print("Here's the error \(e)")} else {print("No error")}}
            audioStreaming.setIsPlaying(false, callback: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.groupifyID.text = Queue.instance.groupifyID
    }
    
    @objc private func queueSong(notification: Notification) {
        let song = Song(data: notification.object! as! [String: AnyObject])
        Queue.instance.queue.append(song)
        audioStreaming.queueSpotifyURI(song.uri) {error in if let e = error {print("Here's the error \(e)")} else {print("No error")}}
        
        if let queueControllerNav = self.presentedViewController as? UINavigationController {
            if let queueControllerNav = queueControllerNav.viewControllers.first as? QueueViewController {
                queueControllerNav.tableView.reloadData()
            }
        }
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChange metadata: SPTPlaybackMetadata!) {
        if let current = metadata.currentTrack {
            songTitle.text = current.name
            albumTitle.text = current.albumName
            artistName.text = current.artistName
            
            if let cover = current.albumCoverArtURL {
                do {
                    try albumArtwork.image = UIImage(data: NSData(contentsOf: URL(string: cover)!) as Data)
                }
                catch {
                    print(error)
                }
            }
        }
        
        if let first = Queue.instance.queue.first {
            if first.uri == metadata.currentTrack?.uri {
                Queue.instance.queue.remove(at: 0)
            }
        }
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChangePlaybackStatus isPlaying: Bool) {
        if (isPlaying) {
            pauseButton.imageView?.image = #imageLiteral(resourceName: "Pause")
            
            try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try? AVAudioSession.sharedInstance().setActive(true)
        }
        
        else {
            pauseButton.imageView?.image = #imageLiteral(resourceName: "Play")
            
            try? AVAudioSession.sharedInstance().setActive(false)
        }
    }
    
    @IBAction func pauseTapped(_ sender: Any) {
        audioStreaming.setIsPlaying(!audioStreaming.playbackState.isPlaying) {error in print(error ?? "No error")}
    }
    
    @IBAction func skipTapped(_ sender: Any) {
        audioStreaming.skipNext {error in print(error ?? "No error")}
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
