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
    
    let artworkImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 20
        $0.backgroundColor = .systemGray5
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
        $0.text = "▶️ 미리듣기 자동 재생 중"
    }
    
    let previewUnavailableLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14, weight: .medium)
        $0.textColor = .secondaryLabel
        $0.textAlignment = .center
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
    }
    
    private func configureLayout() {
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(artworkImageView)
        contentView.addSubview(titleStackView)
        contentView.addSubview(infoCardView)
        
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
        
        artworkImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.horizontalEdges.equalToSuperview().inset(24)
            $0.height.equalTo(artworkImageView.snp.width)
        }
        
        titleStackView.snp.makeConstraints {
            $0.top.equalTo(artworkImageView.snp.bottom).offset(24)
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
    
    func configureArtwork(with url: URL?) {
        artworkImageView.kf.setImage(
            with: url,
            placeholder: UIImage(systemName: "photo.trianglebadge.exclamationmark.fill")
        )
    }
    
    func updatePreviewState(hasPreview: Bool) {
        previewGuideLabel.isHidden = !hasPreview
        previewUnavailableLabel.isHidden = hasPreview
    }
}
