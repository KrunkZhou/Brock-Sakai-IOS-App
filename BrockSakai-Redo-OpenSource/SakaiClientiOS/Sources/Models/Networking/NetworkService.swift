//
//  NetworkService.swift
//  SakaiClientiOS
//
//  Created by Pranay Neelagiri on 1/1/19.
//  Modified by Krunk
//

import Foundation

protocol NetworkService {
    typealias DecodableResponse<T: Decodable> = (T?, SakaiError?) -> Void

    func makeEndpointRequest
        <T: Decodable>(request: SakaiRequest<T>, completion: @escaping DecodableResponse<T>)

    func makeEndpointRequestWithoutCache
        <T: Decodable>(request: SakaiRequest<T>, completion: @escaping DecodableResponse<T>)
}
