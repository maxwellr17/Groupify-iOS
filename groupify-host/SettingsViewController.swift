//
//  SettingsViewController.swift
//  groupify-host
//
//  Created by Noah Rubin on 1/20/18.
//  Copyright © 2018 Noah Rubin. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {
    
    @IBOutlet weak var defaultAlbumButton: UIButton!
    @IBOutlet weak var explicitToggle: UISwitch!
    @IBOutlet weak var shuffleDefaultAlbumToggle: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.explicitToggle.setOn(Queue.instance.explicit, animated: false)
        self.shuffleDefaultAlbumToggle.setOn(Queue.instance.shuffleDefaultPlaylist, animated: false)
        
        if let playlist = Queue.instance.defaultPlaylist {
            self.defaultAlbumButton.titleLabel?.text = playlist.name
        }
    }
    
    @IBAction func resetTokenTapped(_ sender: Any) {
        let url = URL(string: "REMOVED FOR SECURITY REASONS")!
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let postString = "spotifyID=\(Queue.instance.session.canonicalUsername!)"
        request.httpBody = postString.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("error=\(error)")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
            }
            
            do {
                let anyObj = try JSONSerialization.jsonObject(with: data, options: []) as AnyObject
                Queue.instance.groupifyID = anyObj["groupifyID"]! as! String
                
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Success", message: "Successfully changed Groupify ID", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: .default))
                    self.present(alert, animated: true)
                }
            }
                
            catch {
                print(error)
            }
        }
        
        task.resume()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func saveTapped(_ sender: Any) {
        let url = URL(string: "REMOVED FOR SECURITY REASONS")!
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "PATCH"
        
        var postString = "spotifyID=\(Queue.instance.session.canonicalUsername!)&allowExplicit=\(explicitToggle.isOn)&shuffleDefaultPlaylist=\(shuffleDefaultAlbumToggle.isOn)"
        
        if let playlist = Queue.instance.defaultPlaylist {
            postString += "&defaultPlaylist=\(playlist.uri.absoluteString)"
        }
        
        request.httpBody = postString.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("error=\(error)")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
            }
            
            DispatchQueue.main.async {
                Queue.instance.explicit = self.explicitToggle.isOn
                Queue.instance.shuffleDefaultPlaylist = self.shuffleDefaultAlbumToggle.isOn
                
                SPTAudioStreamingController.sharedInstance().setShuffle(self.shuffleDefaultAlbumToggle.isOn) { error in
                    DispatchQueue.main.async {
                        self.dismiss(animated: true)
                    }
                }
            }
        }
        
        task.resume()
    }
}
