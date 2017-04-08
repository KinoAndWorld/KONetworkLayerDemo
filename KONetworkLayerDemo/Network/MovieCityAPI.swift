//
//  MovieCityAPI.swift
//  KONetworkLayerDemo
//
//  Created by kino on 2017/4/5.
//  Copyright © 2017年 demo. All rights reserved.
//

import Foundation
import Moya

let MovieProvider = RxMoyaProvider<MovieApi>(
	endpointClosure: normalEndpointClosure(),
	plugins: [NetworkLoggerPlugin(verbose: true, cURL: true,responseDataFormatter: JSONResponseDataFormatter)]
)


public enum MovieApi {
	case cityList
}

extension MovieApi: TargetType {
	
	public var baseURL: URL { return URL(string: BaseUrl)! }
	
	public var path: String {
		switch self {
		case .cityList:
			return "movie/citys"
		}
	}
	
	public var method: Moya.Method {
		return .get
	}

	public var parameters: [String: Any]? {
		switch self {
		case .cityList:
			return nil
		}
	}

	public var parameterEncoding: ParameterEncoding {
		
		return URLEncoding.default
	}

	public var task: Task {
		return .request
	}
	
	public var validate: Bool {
		return true
	}
	
	public var sampleData: Data {
		switch self {
		default:
			return "".data(using: String.Encoding.utf8)!
		}
		
	}
}
