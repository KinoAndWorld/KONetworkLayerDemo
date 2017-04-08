//
//  NetworkConfig.swift
//  ProjectPlan
//
//  Created by kino on 2017/3/14.
//  Copyright © 2017年 Kino. All rights reserved.
//

import UIKit

import RxSwift
import Moya
import HandyJSON
import SwiftyJSON


public let BaseUrl = "http://v.juhe.cn"


public enum ServiceError : Swift.Error {
	case NoRepresentor
	case NotSuccessfulHTTP
	case Nodata
	case CouldNotMakeObjectError
	case OtherError(resultCode: String, resultMsg: String)
}

enum BizStatus: String {
	case BizSuccess = "0"
	case BizError
}

let RESULT_CODE = "error_code"
let RESULT_MSG = "reason"
let RESULT_DATA = "result"

extension ObservableType where E == Moya.Response {
	
	func preOrderCheck(response: Response) throws -> JSON {
		
		// check http status
		guard ((200...209) ~= response.statusCode) else {
			throw ServiceError.NotSuccessfulHTTP
		}
		
		// unwrap biz json shell
		let json = JSON.init(data: response.data)
		
		// check biz status
		let code = json[RESULT_CODE].stringValue
		if code == BizStatus.BizSuccess.rawValue {
			return json[RESULT_DATA]
		}else {
			throw ServiceError.OtherError(resultCode: json[RESULT_CODE].stringValue, resultMsg: json[RESULT_MSG].stringValue)
		}
	}
	
	func mapResponseToModel<T: HandyJSON>(type: T.Type) -> Observable<T> {
		return map{ response in
				do {
					let respContent = try self.preOrderCheck(response: response)
					
					if let obj = T.deserialize(from: respContent.rawString()) {
						return obj
					}else {
						throw ServiceError.CouldNotMakeObjectError
					}
					
				} catch let err as ServiceError {
					throw err
				}
		}
	}
	
	func mapResponseToModelList<T: HandyJSON>(type: T.Type) -> Observable<[T]> {
		return map{ response in
			
			do {
				let respContent = try self.preOrderCheck(response: response)
				
				if let objs = [T].deserialize(from: respContent.rawString()) as? [T] {
					return objs
				}else {
					throw ServiceError.CouldNotMakeObjectError
				}
				
			} catch let err as ServiceError {
				throw err
			}
		}
	}
}



let headerFields: Dictionary<String, String> = [
	"platform": "iOS",
	"Auth-Token": "get some token from your code"
]

let headerFieldsWithoutToken: Dictionary<String, String> = [
	"platform": "iOS"
]

public func url(_ route: TargetType) -> String {
	return route.baseURL.appendingPathComponent(route.path).absoluteString
}

func normalEndpointClosure<T: TargetType>() -> ( (_ target: T) -> Endpoint<T>) {
	
	return { (target: T) -> Endpoint<T> in
		
		let appendedParams: Dictionary<String, AnyObject> = ["key" : "fa89d1a9e0cd1680bd3d71fd49d3e21c" as AnyObject]
		let fields:Dictionary<String, String> = headerFieldsWithoutToken
//		if UserManager.sharedInstance.curUser != nil {
//			fields = headerFields
//		}
		print(fields)
		
		return Endpoint<T>(url: url(target), sampleResponseClosure: {.networkResponse(200, target.sampleData)}, method: target.method, parameters: target.parameters)
			.adding(newParameters: appendedParams)
			.adding(newHTTPHeaderFields: fields)
	}
}



public func JSONResponseDataFormatter(_ data: Data) -> Data {
	do {
		let dataAsJSON = try JSONSerialization.jsonObject(with: data)
		let prettyData =  try JSONSerialization.data(withJSONObject: dataAsJSON, options: .prettyPrinted)
		return prettyData
	} catch {
		return data // fallback to original data if it can't be serialized.
	}
}

