//
//  PlaylistViewController.swift
//  groupify-host
//
//  Created by Noah Rubin on 1/20/18.
//  Copyright © 2018 Noah Rubin. All rights reserved.
//

import UIKit

class PlaylistViewController: UITableViewController {
    
    var playlists: [SPTPartialPlaylist] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SPTPlaylistList.playlists(forUser: Queue.instance.session.canonicalUsername, withAccessToken: Queue.instance.session.accessToken) {
            (error, data) in
            let list = data as! SPTPlaylistList
            self.loadPlaylists(list) {
                data in
                self.playlists = data.items.map { $0 as! SPTPartialPlaylist }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    private func loadPlaylists(_ list: SPTListPage, _ callback: @escaping (SPTListPage) -> Void) {
        if list.hasNextPage {
            list.requestNextPage(withAccessToken: Queue.instance.session.accessToken) {
                (error, data) in
                self.loadPlaylists(list.appending(data as! SPTListPage), callback)
            }
        }
        
        else {
            callback(list)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let playlist = self.playlists[indexPath.item]
        Queue.instance.defaultPlaylist = playlist
        
        let audioStreaming = SPTAudioStreamingController.sharedInstance()!
        audioStreaming.playSpotifyURI(playlist.uri.absoluteString, startingWith: 0, startingWithPosition: 0) {error in if let e = error {print("Here's the error \(e)")} else {print("No error")}}
        audioStreaming.setIsPlaying(false, callback: nil)
        
        self.dismiss(animated: true)
        
        

    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.playlists.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let item = self.playlists[indexPath.item]
        cell.textLabel!.text = item.name
        return cell
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
}
