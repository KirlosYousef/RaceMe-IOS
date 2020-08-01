//
//  ActivityIndicator.swift
//  RaceMe
//
//  Created by Kirlos Yousef on 2019. 12. 19..
//  Copyright © 2019. Kirlos Yousef. All rights reserved.
//

import Foundation
import SwiftUI

/// Representable SwiftUI view for UIActivityIndicator
struct ActivityIndicator: UIViewRepresentable {
	
	func makeUIView(context: Context) -> UIActivityIndicatorView {
		let v = UIActivityIndicatorView()
		
		return v
	}
	
	func updateUIView(_ activityIndicator: UIActivityIndicatorView, context: Context) {
		activityIndicator.startAnimating()
	}
}
