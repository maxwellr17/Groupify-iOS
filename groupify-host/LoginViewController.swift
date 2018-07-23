//
//  ViewController.swift
//  groupify-host
//
//  Created by Noah Rubin on 1/20/18.
//  Copyright © 2018 Noah Rubin. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, SPTAudioStreamingDelegate {
    
    @IBOutlet weak var loginButton: UIButton!
    
    var authorize = SPTAuth.defaultInstance()!
    var session: SPTSession!
    var loginUrl: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SPTAudioStreamingController.sharedInstance().delegate = self
        setup()
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.updateAfterFirstLogin), name: NSNotification.Name(rawValue: "loginSuccessful"), object: nil)
    }
    
    @objc func updateAfterFirstLogin() {
        let udefs = UserDefaults.standard
        print("update after first login")
        if let sessionObj: AnyObject = udefs.object(forKey: "SpotifySession") as AnyObject? {
            let sessionDataObj = sessionObj as! Data
            let firstTimeSession = NSKeyedUnarchiver.unarchiveObject(with: sessionDataObj) as! SPTSession
            self.session = firstTimeSession
            print("access token:" + self.session.accessToken)
            print("username:" + self.session.canonicalUsername)
            
            do {
                try SPTAudioStreamingController.sharedInstance().start(withClientId: self.authorize.clientID)
            }
            catch {
                print("An error")
            }
            
            SPTAudioStreamingController.sharedInstance().login(withAccessToken: self.session.accessToken)
            
            Queue.instance.session = firstTimeSession
        }
    }
    
    func audioStreamingDidLogin(_ audioStreaming: SPTAudioStreamingController!) {
        let url = URL(string: "REMOVED FOR SECURITY PURPOSES")!
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let postString = "spotifyID=\(self.session.canonicalUsername!)&apnsID=\(Queue.instance.deviceToken!)"
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
                Queue.instance.explicit = anyObj["allowExplicit"]! as! Bool
                Queue.instance.shuffleDefaultPlaylist = anyObj["shuffleDefaultPlaylist"]! as! Bool
                
                if let defaultPlaylist = anyObj["defaultPlaylist"] as? String {
                    let request = try SPTPlaylistSnapshot.createRequestForPlaylist(withURI: URL(string: defaultPlaylist), accessToken: self.session.accessToken)
                    SPTRequest.sharedHandler().perform(request) {
                        (error, response, data) in
                        do {
                            Queue.instance.defaultPlaylist = try SPTPlaylistSnapshot(from: data, with: response)
                            DispatchQueue.main.async {
                                self.performSegue(withIdentifier: "afterLogin", sender: self)
                            }
                        }
                            
                        catch {
                            print(error)
                        }
                    }
                }
                
                else {
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "afterLogin", sender: self)
                    }
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
        // Dispose of any resources that can be recreated.
    }
    
    func setup() {
        authorize.clientID = "REMOVED FOR SECURITY PURPOSES"
        authorize.redirectURL = URL(string: "groupify://spotify/callback")
        authorize.requestedScopes = [SPTAuthStreamingScope, SPTAuthPlaylistReadPrivateScope, SPTAuthPlaylistModifyPublicScope, SPTAuthPlaylistModifyPrivateScope]
        
        loginUrl = authorize.spotifyWebAuthenticationURL()
//        if (SPTAuth.supportsApplicationAuthentication()) {
//            loginUrl = authorize.spotifyAppAuthenticationURL()
//        }
    }
    
    @IBAction func loginClicked(_ sender: Any) {
        UIApplication.shared.open(loginUrl!, options: [:]) { successful in
            print("Opening url was successful: \(successful)")
            if self.authorize.canHandle(self.authorize.redirectURL) {
                //ADD ERROR HANDLING HERE
                print("can handle redirect url, loginClicked")
            }
        }
    }
}
