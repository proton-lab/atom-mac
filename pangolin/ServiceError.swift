//
//  ServiceError.swift
//  Proton
//
//  Created by Bencong Rion 2019/4/11.
//  Copyright © 2019年 com.proton. All rights reserved.
//

import Foundation

enum ServiceError:Error {
        case SysPorxyMountErr
        case SysProxyRemoveErr
        case SysProxySetupErr
}

extension ServiceError: LocalizedError {
        public var errorDescription: String? {
                switch self {
                case .SysPorxyMountErr:
                        return NSLocalizedString("Mount system proxy model error".localized, comment: "Mount Error")
                case .SysProxyRemoveErr:
                        return NSLocalizedString("Remove the system proxy setting error".localized, comment: "Remove Proxy Error")
                case .SysProxySetupErr:
                        return NSLocalizedString("Setup system proxy error".localized, comment: "Setup Error")
                }
        }
}
