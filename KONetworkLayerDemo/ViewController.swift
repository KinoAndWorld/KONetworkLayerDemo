//
//  ViewController.swift
//  KONetworkLayerDemo
//
//  Created by kino on 2017/4/5.
//  Copyright © 2017年 demo. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {
	
	let disposebag = DisposeBag()

	var movieCitys = [MovieCity]() {
		didSet {
			tableView.reloadData()
		}
	}
	
	@IBOutlet weak var tableView: UITableView!
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
		
		MovieProvider.request(MovieApi.cityList)
			.mapResponseToModelList(type: MovieCity.self)
			.subscribe(onNext: { [unowned self] movieCitys in
				self.movieCitys = movieCitys
			}, onError: { error in
				print(error)
			}).addDisposableTo(disposebag)
		
	}
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.movieCitys.count
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 50
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) 
		
		let item = movieCitys[indexPath.row]
		cell.textLabel?.text = "\(item.city_name)<\(item.count)>"
		
		
		return cell
	}
	
}

