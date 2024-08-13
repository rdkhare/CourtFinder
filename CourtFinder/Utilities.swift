//
//  Utilities.swift
//  CourtFinder
//
//  Created by Rajat Khare on 7/18/24.
//

import UIKit

func getRootViewController() -> UIViewController? {
    guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
        return nil
    }
    return screen.windows.first?.rootViewController
}
