//
//  AlbumCardCell.swift
//  Challenge
//
//  Created by Yeseul Jang on 3/11/26.
//
import UIKit
import SnapKit
import Then
import Kingfisher

final class AlbumCardCell: UICollectionViewCell {
    
    static let identifier = "AlbumCardCell"
    
    private let cardView = UIView()
    private let albumImageView = UIImageView()
    private let dimView = UIView()
    private let titleLabel = UILabel()
    private let artistLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureLayout()
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        albumImageView.image = nil
        titleLabel.text = nil
        artistLabel.text = nil
    }
    
    func configure(with item: MusicItem) {
        titleLabel.text = item.collectionName ?? "앨범 제목"
        artistLabel.text = item.artistName ?? "아티스트"
        
        let imageURL = "https://is1-ssl.mzstatic.com/image/thumb/Music126/v4/b7/d7/f7/b7d7f7f9-c428-ceda-59da-9ab0b112ca88/5059460232280.jpg/100x100bb.jpg"
        albumImageView.kf.setImage(with: URL(string: imageURL))
    }
    
    func configureLayout() {
        contentView.addSubview(cardView)
        
        cardView.addSubview(albumImageView)
        cardView.addSubview(dimView)
        cardView.addSubview(titleLabel)
        cardView.addSubview(artistLabel)
        
        cardView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        albumImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        dimView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        artistLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(16)
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalTo(artistLabel.snp.top).offset(-6)
        }
    }
    
    func configureUI() {
        contentView.backgroundColor = .clear
        
        cardView.clipsToBounds = true
        cardView.layer.cornerRadius = 20
        
        albumImageView.contentMode = .scaleAspectFill
        albumImageView.clipsToBounds = true
        
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.28)
        
        titleLabel.font = .boldSystemFont(ofSize: 22)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 2
        
        artistLabel.font = .systemFont(ofSize: 15, weight: .medium)
        artistLabel.textColor = .white
        artistLabel.numberOfLines = 1
    }
}

