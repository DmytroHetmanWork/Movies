//
//  YouTubePlayerViewController.swift
//  Movies
//
//  Created by Dmytro Hetman on 28.01.2025.
//

import UIKit
import YoutubePlayer_in_WKWebView

final class YouTubePlayerViewController: UIViewController {
    
    private let playerView = WKYTPlayerView()

    let id: YouTubeVideoID
    
    init(id: YouTubeVideoID) {
        self.id = id
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        setupCloseButton()
    }
    
    // MARK: - Player setup

    private func setup() {
        view.backgroundColor = .black
        
        playerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(playerView)
        
        NSLayoutConstraint.activate([
            playerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            playerView.widthAnchor.constraint(equalTo: view.widthAnchor),
            playerView.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])
        
        playerView.load(withVideoId: id.value, playerVars: [
            "autoplay": 1,
            "playsinline": 1
        ])
    }
    
    // MARK: - Close button
    
    private func setupCloseButton() {
        let closeButton = UIButton(type: .system)
        closeButton.setTitle(.localized(LocalizedKey.Title.close), for: .normal)
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.backgroundColor = UIColor(white: 0, alpha: 0.7)
        closeButton.layer.cornerRadius = 10
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(closePlayer), for: .touchUpInside)
        view.addSubview(closeButton)
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            closeButton.widthAnchor.constraint(equalToConstant: 70),
            closeButton.heightAnchor.constraint(equalToConstant: 35)
        ])
    }
    
    @objc private func closePlayer() {
        dismiss(animated: true)
    }

}
