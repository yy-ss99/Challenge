//
//  NetworkService.swift
//  Challenge
//
//  Created by Yeseul Jang on 3/17/26.
//
import Foundation
import RxSwift

protocol NetworkService {
    func fetch<T: Decodable>(endpoint: ITunesEndpoint) -> Single<T>
}
