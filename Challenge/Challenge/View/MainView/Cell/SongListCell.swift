//
//  SongListCell.swift
//  Challenge
//
//  Created by Yeseul Jang on 3/12/26.
//
import UIKit
import SnapKit
import Then
import Kingfisher

final class SongListCell: UICollectionViewCell {
    
    static let identifier = "SongListCell"
    
    let albumImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 8
        $0.backgroundColor = .systemGray5
    }
    
    let trackNameLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16, weight: .semibold)
        $0.textColor = .label
        $0.numberOfLines = 1
    }
    
    let artistLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 13)
        $0.textColor = .secondaryLabel
    }
    
    let albumLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 13)
        $0.textColor = .secondaryLabel
    }
    
    private let infoStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 6
    }
    
    private let textStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 4
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        albumImageView.image = nil
    }
    
    private func configureLayout() {
        contentView.addSubview(albumImageView)
        contentView.addSubview(textStackView)
        
        infoStackView.addArrangedSubview(artistLabel)
        infoStackView.addArrangedSubview(albumLabel)
        
        textStackView.addArrangedSubview(trackNameLabel)
        textStackView.addArrangedSubview(infoStackView)
        
        albumImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(56)
        }
        
        textStackView.snp.makeConstraints {
            $0.leading.equalTo(albumImageView.snp.trailing).offset(12)
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalToSuperview()
        }
    }
    
    func configure(with item: MusicItem) {
        trackNameLabel.text = item.trackName ?? "노래 제목 없음"
        artistLabel.text = item.artistName ?? "아티스트"
        let imageURL = "https://is1-ssl.mzstatic.com/image/thumb/Music126/v4/b7/d7/f7/b7d7f7f9-c428-ceda-59da-9ab0b112ca88/5059460232280.jpg/100x100bb.jpg"
        albumImageView.kf.setImage(with: URL(string: imageURL))
        
        //trackNameLabel.text = "노래 제목"
        //artistLabel.text = "아티스트"
    }
}
