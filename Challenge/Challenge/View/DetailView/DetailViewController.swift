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
    
    init(item: MusicItem) {
        self.viewModel = DetailViewModel(item: item)
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
                detailVC.detailView.configureArtwork(with: url)
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
        
        // 미리듣기 있는지 확인
        // 미리듣기 재생
        output.previewURL
            .drive(with: self) { detailVC, url in
                detailVC.detailView.updatePreviewState(hasPreview: url != nil)
                detailVC.playPreviewIfNeeded(url: url)
            }
            .disposed(by: disposeBag)
    }
    
    private func playPreviewIfNeeded(url: URL?) {
        // 기존에 있던 플레이어는 없애줌
        player?.pause()
        player = nil
        
        // url없으면 아무것도 안하기
        guard let url else { return }
        
        // 있으면 자동 재생
        let player = AVPlayer(url: url)
        self.player = player
        player.play()
    }
}
