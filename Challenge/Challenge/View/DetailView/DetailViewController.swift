//
//  DetailViewController.swift
//  Challenge
//
//  Created by Yeseul Jang on 3/19/26.
//
import UIKit
import RxSwift
import RxCocoa
import SnapKit
import AVFoundation

final class DetailViewController: UIViewController {
    private let detailView = DetailView()
    private let disposeBag = DisposeBag()
    private let viewModel: DetailViewModel
    
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    
    init(item: MusicItem, contentType: DetailContentType) {
        self.viewModel = DetailViewModel(item: item, contentType: contentType)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.largeTitleDisplayMode = .never
        
        configureUI()
        bindViewModel()
    }
    
    // 화면 나갈때 플레이어 꺼줌
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player?.pause()
    }
    
    // 오토레이아웃이 안먹어서 이렇게 지정해줘야함
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer?.frame = detailView.videoContainerView.bounds
    }
    
    // VC 없어질때 같이 지워줌
    deinit {
        player?.pause()
    }
    
    private func configureUI() {
        view.addSubview(detailView)
        
        detailView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func bindViewModel() {
        // 뷰 올라왔다고 알림
        let input = DetailViewModel.Input(
            viewDidLoad: Observable.just(())
        )
        
        let output = viewModel.transform(input: input)
        
        // 타이틀이랑 라벨의 text랑 연결함
        output.title
            .drive(detailView.titleLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.subtitle
            .drive(detailView.subtitleLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.artworkURL
            .drive(with: self) { detailVC, url in
                detailVC.detailView.configureAlbumCover(with: url)
            }
            .disposed(by: disposeBag)
        
        output.genreText
            .drive(detailView.genreLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.releaseDateText
            .drive(detailView.releaseDateLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.countryText
            .drive(detailView.countryLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.media
            .drive(with: self) { detailVC, url in
                detailVC.detailView.updateMediaState(
                    showsVideo: url.showsVideo,
                    showsGuideText: url.showsGuideText,
                    statusText: url.statusText
                )
                detailVC.playMediaIfNeeded(media: url)
            }
            .disposed(by: disposeBag)
    }
    
    private func playMediaIfNeeded(media: DetailMedia) {
        // 전에 영상 완전히 정리함
        player?.pause()
        player = nil
        playerLayer?.removeFromSuperlayer()
        playerLayer = nil
        
        // URL 없으면 return
        guard let url = media.mediaURL else { return }
        
        // AVPlayer 생성
        let player = AVPlayer(url: url)
        self.player = player
        
        // 비디오 일때만 아예 레이어 추가
        if media.showsVideo {
            // 플레이어 만들고
            let playerLayer = AVPlayerLayer(player: player)
            playerLayer.videoGravity = .resizeAspectFill // 화면 채우기
            playerLayer.frame = detailView.videoContainerView.bounds // 직접 사이즈 지정해줘야함
            // 만든 플레이어 넣어줌
            detailView.videoContainerView.layer.addSublayer(playerLayer)
            self.playerLayer = playerLayer
        }
        // 재생
        player.play()
    }
}
