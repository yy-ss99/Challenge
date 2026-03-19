//
//  DetailView.swift
//  Challenge
//
//  Created by Yeseul Jang on 3/19/26.
//
import UIKit
import RxSwift
import SnapKit
import Then
import Kingfisher

final class DetailView: UIView {
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    // 현재레이아웃 상태 저장
    private var isShowingVideoLayout: Bool?
    
    // 상단에 보여줄 영역
    let mediaContainerView = UIView().then {
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 20
        $0.backgroundColor = .systemGray5
    }
    
    // 앨범커버
    let albumCoverImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 20
        $0.backgroundColor = .systemGray5
    }
    
    let videoContainerView = UIView().then {
        $0.backgroundColor = .black
        $0.isHidden = true
    }
    
    let titleLabel = UILabel().then {
        $0.font = .boldSystemFont(ofSize: 24)
        $0.textColor = .label
        $0.numberOfLines = 2
        $0.textAlignment = .center
    }
    
    let subtitleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16)
        $0.textColor = .secondaryLabel
        $0.numberOfLines = 0
        $0.textAlignment = .center
    }
    
    let previewGuideLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14, weight: .medium)
        $0.textColor = .systemBlue
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.text = "미리듣기 자동 재생 중"
    }
    
    let previewUnavailableLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14, weight: .medium)
        $0.textColor = .secondaryLabel
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.text = "이 항목은 자동 재생을 지원하지 않습니다."
        $0.isHidden = true
    }
    
    let genreLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 15)
        $0.textColor = .label
    }
    
    let releaseDateLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 15)
        $0.textColor = .label
    }
    
    let countryLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 15)
        $0.textColor = .label
    }
    
    private let infoCardView = UIView().then {
        $0.backgroundColor = .secondarySystemBackground
        $0.layer.cornerRadius = 16
    }
    
    private let infoStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 12
    }
    
    private let titleStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 8
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        configureLayout()
        applyMediaLayout(isVideo: false)
    }
    
    private func configureLayout() {
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(mediaContainerView)
        contentView.addSubview(titleStackView)
        contentView.addSubview(infoCardView)
        
        // 미디어영역 안에 앨범커버, 비디오 보여주는 뷰 둘다 넣음(종류에 따라 바꿔보여줌)
        mediaContainerView.addSubview(albumCoverImageView)
        mediaContainerView.addSubview(videoContainerView)
        
        titleStackView.addArrangedSubview(titleLabel)
        titleStackView.addArrangedSubview(subtitleLabel)
        titleStackView.addArrangedSubview(previewGuideLabel)
        titleStackView.addArrangedSubview(previewUnavailableLabel)
        
        infoCardView.addSubview(infoStackView)
        infoStackView.addArrangedSubview(genreLabel)
        infoStackView.addArrangedSubview(releaseDateLabel)
        infoStackView.addArrangedSubview(countryLabel)
        
        scrollView.snp.makeConstraints {
            $0.edges.equalTo(safeAreaLayoutGuide)
        }
        
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }
        
        albumCoverImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        videoContainerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        titleStackView.snp.makeConstraints {
            $0.top.equalTo(mediaContainerView.snp.bottom).offset(24)
            $0.horizontalEdges.equalToSuperview().inset(24)
        }
        
        infoCardView.snp.makeConstraints {
            $0.top.equalTo(titleStackView.snp.bottom).offset(24)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(24)
        }
        
        infoStackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(20)
        }
    }
    
    func configureAlbumCover(with url: URL?) {
        albumCoverImageView.kf.setImage(
            with: url,
            placeholder: UIImage(systemName: "photo.trianglebadge.exclamationmark.fill")
        )
    }
    
    // 보여지는 미디어에 따라서 보여질 것들 설정 상태 줌
    func updateMediaState(showsVideo: Bool, showsGuideText: Bool, statusText: String) {
        
        // 비디오인지 아닌지에 따라 미디어 보여주는 부분 설정해줌
        applyMediaLayout(isVideo: showsVideo)
        
        videoContainerView.isHidden = !showsVideo
        albumCoverImageView.isHidden = showsVideo
        
        // 프리뷰 가능하면 프리뷰 정보 보여줌
        if showsGuideText {
            previewGuideLabel.text = statusText
            previewGuideLabel.isHidden = false
            previewUnavailableLabel.isHidden = true
        } else {
            previewUnavailableLabel.text = statusText
            previewGuideLabel.isHidden = true
            previewUnavailableLabel.isHidden = false
        }
    }
    
    // 비디오냐 아니냐에 따라 다 그림
    func applyMediaLayout(isVideo: Bool) {
        // 다시 그릴 필요없으면 안그림
        guard isShowingVideoLayout != isVideo else { return }
        isShowingVideoLayout = isVideo
        
        // 비디오면 모서리 둥근거 없애줌 앨범이면 모서리 깎아줌
        mediaContainerView.layer.cornerRadius = isVideo ? 0 : 20
        albumCoverImageView.layer.cornerRadius = isVideo ? 0 : 20
        
        //레이아웃 다시 잡기
        mediaContainerView.snp.remakeConstraints {
            $0.top.equalToSuperview().offset(24)
            
            // 비디오가 맞으면 영상비율에 맞게 잡아주기
            // 비디오 아니고 앨범커버일 경우 양옆 인셋 잡고 정사각형모양
            if isVideo {
                $0.leading.trailing.equalToSuperview()
                $0.height.equalTo(mediaContainerView.snp.width).multipliedBy(9.0 / 16.0)
            } else {
                $0.horizontalEdges.equalToSuperview().inset(24)
                $0.height.equalTo(mediaContainerView.snp.width)
            }
        }
        
        // 중요!!
        setNeedsLayout() // 레이아웃 다시 그려야돼!
        layoutIfNeeded() // 필요하면 다시 그려!!
        // 바꾼거 당장 바꿈
    }
}
