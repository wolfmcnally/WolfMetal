//
//  Framework.swift
//  WolfCore
//
//  Created by Wolf McNally on 6/23/17.
//  Copyright © 2017 WolfMcNally.com. All rights reserved.
//

import Foundation
import WolfCore

public class Framework {
    public static var bundle: Bundle { return Bundle.findBundle(forClass: self) }
}
