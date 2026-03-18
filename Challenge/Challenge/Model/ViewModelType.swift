//
//  ViewModelType.swift
//  Challenge
//
//  Created by Yeseul Jang on 3/18/26.
//

protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    func transform(input: Input) -> Output
}
