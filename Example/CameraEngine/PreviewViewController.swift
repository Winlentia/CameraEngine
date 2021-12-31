//
//  PreviewViewController.swift
//  CameraEngine2
//
//  Created by Remi Robert on 25/12/15.
//  Copyright © 2015 Remi Robert. All rights reserved.
//

import UIKit
import PBJVideoPlayer
import FLAnimatedImage

enum Media {
    case Photo(image: UIImage)
    case Video(url: URL)
    case GIF(url: URL)
}

class PreviewViewController: UIViewController {

    @IBOutlet weak var imageView: FLAnimatedImageView!
    @IBOutlet weak var buttonClose: UIButton!
    @IBOutlet weak var flashButton: UIButton!
    @IBOutlet weak var torchButton: UIButton!
    var media: Media!
    var playerController: PBJVideoPlayerController!
    
    @IBAction func closePreview(sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func playVideo(url: URL) {
        print("display video for url : \(url.absoluteString)")
        UISaveVideoAtPathToSavedPhotosAlbum(url.absoluteString, nil, nil, nil)
        self.playerController = PBJVideoPlayerController()
        self.playerController.view.frame = self.view.bounds
        self.playerController.videoPath = url.absoluteString
        
        self.playerController.view.backgroundColor = UIColor.orange
        
        self.addChildViewController(self.playerController)
        self.view.insertSubview(self.playerController.view, at: 0)
        self.playerController.didMove(toParentViewController: self)
    }
    
    private func displayAnimatedGIF(url: URL) {
        var dataImage: Data?
        do {
            dataImage = try Data(contentsOf: url)
        }
        catch {
            fatalError()
        }
        let animatedImage = FLAnimatedImage(animatedGIFData: dataImage!)
        
        self.imageView.animatedImage = animatedImage
    }
    
    override func viewWillAppear(_ animated: Bool) {
        switch self.media! {
        case .Photo(let image): self.imageView.image = image
        case .Video(let url): self.playVideo(url: url)
        case .GIF(let url): self.displayAnimatedGIF(url: url)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black
    }
}
