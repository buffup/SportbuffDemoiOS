//
//  StreamViewController.swift
//  buffup-ios
//
//  Created by Eleftherios Charitou on 14/01/2020.
//  Copyright © 2020 BuffUp. All rights reserved.
//

import UIKit
import AVFoundation
import SportBuff

class StreamViewController: LandscapeViewController {
    
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var videoView: UIView!
    
    private var player: AVPlayer!
    private var timeObserver: Any?
	
	//TODO: Replace with your give client account name
	private let clientAccount = "sportbuff"
	
    private let buffView = BuffView()
	private var startDate: Date?
	
    private var isSeeking = false
    private let formatter = DateComponentsFormatter()
	private var sportBuffInitialized = false
    
    lazy var playerLayer: AVPlayerLayer = {
        let layer = AVPlayerLayer(player: player)
        layer.frame = self.view.bounds
        layer.videoGravity = .resizeAspect
        layer.needsDisplayOnBoundsChange = true
        return layer
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let videoURL = URL(string: "https://buffup-public.s3.eu-west-2.amazonaws.com/video/HIGHLIGHTS+++Arsenal+vs+Liverpool+(3-2)+++Martinelli%2C+Saka+(2).mp4") {
            self.playVideoWithURL(url: videoURL)
			setupSportBuff()
        }
    }
    
    deinit {
        cleanPlayer()
    }
    
    private func setupSportBuff() {
        //Initialize the SportBuff SDK
		SportBuff.initialize(clientAccount: clientAccount)
		
		//We are initializing without a logged in user here, as we are not providing a JWT token
		//If we implement Backend to Backend Authentication, then we should get from the User Token and use it in the init method:
		//TODO: Use a real USER TOken obtained by your backend to authenticate the user in
//		SportBuff.signInUser(token: USER_TOKEN) { Result<Void, Error> in
//
//		}
        
        buffView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(buffView)
        NSLayoutConstraint.activate([
            buffView.leadingAnchor.constraint(equalTo: videoView.leadingAnchor),
            buffView.trailingAnchor.constraint(equalTo: videoView.trailingAnchor),
            buffView.topAnchor.constraint(equalTo: videoView.topAnchor),
            buffView.bottomAnchor.constraint(equalTo: videoView.bottomAnchor, constant: 0)
        ])
        
        buffView.startStreamListener = { result in
            switch result {
            case .success(let status):
                print("status", status)
				DispatchQueue.main.async {
					switch status {
					case .connected:
						//TODO: This should be the actual start Date of the video feed
						//this is only used if Time Synchronization is enabled in the Stream Settings
						//for this demo we are using the time now, but this should be changed obviously
						self.startDate = Date()
					default:
						()
					}
				}
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
		
		//TODO: Use either a streamId that is obtained from the SportBuff Dashboard, or use a unique identifier in the providerId field which
		// needs to be added to the SportBuff Dashboard in the stream's provider Id field
		buffView.startStream(streamId: nil, providerId: "buffRedAppDemo")
		
		sportBuffInitialized = true
    }
    
    private func playVideoWithURL(url: URL) {
        let asset = AVAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)
        player = AVPlayer(playerItem: playerItem)
        self.view.layer.addSublayer(playerLayer)
        player.allowsExternalPlayback = false
        
        #if DEBUG
            player.isMuted = true
        #endif
		
        timeObserver = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: CMTimeScale(NSEC_PER_SEC)), queue: DispatchQueue.main) {[weak self] (progressTime) in
            guard let self = self else { return }
            
			//TODO: This is only needed if the video is a VOD video. It's not needed for live events
//          self.buffView.provideVOD(playbackTime: progressTime)
			
			//TODO: This is only needed if Time Synchronization has been enabled on the Stream settings in the Dashboard.
			//In this case you need to provide the playback time of the video in UTC time
			//So we need to know when the video started streaming and add the current playback time as an offset to calculate the time
			
//			let startDateTimestamp = self.startDate?.unixTimestamp ?? 0
//			let currentPlaybackTimestamp = startDateTimestamp + Int(progressTime.seconds)
//			self.buffView.provideSync(timeStamp: currentPlaybackTimestamp)
			
        }
        player.play()
        setupGesture()
    }
    
    @objc
    private func showExitButton(recognizer: UIGestureRecognizer) {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        exitButton.isHidden = false
        self.view.bringSubviewToFront(exitButton)
        UIView.animate(withDuration: 0.3) {
            self.exitButton.alpha = 1
            self.view.layoutIfNeeded()
        }
        self.perform(#selector(hideExitButton), with: nil, afterDelay: 3)
    }
    
    @objc
    private func hideExitButton() {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        UIView.animate(withDuration: 0.3, animations: {
            self.exitButton.alpha = 0
        }) { _ in
            self.exitButton.isHidden = true
        }
    }

    @IBAction func exitStream(_ sender: Any) {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        self.dismiss(animated: true, completion: nil)
    }
    
    private func cleanPlayer() {
        guard player != nil else { return }
        player.pause()
        if let timeObserver = timeObserver {
            player.removeTimeObserver(timeObserver)
        }
        player.removeObserver(self, forKeyPath: "timeControlStatus")
    }
    
    private func setupGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showExitButton(recognizer:)))
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
    }
}

extension StreamViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let touchView = touch.view, touchView.classForCoder != gestureRecognizer.view?.classForCoder  {
            return false
        }
        return true
    }
}
