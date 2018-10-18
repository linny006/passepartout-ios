//
//  IssueReporter.swift
//  Passepartout-iOS
//
//  Created by Davide De Rosa on 9/26/18.
//  Copyright (c) 2018 Davide De Rosa. All rights reserved.
//
//  https://github.com/keeshux
//
//  This file is part of Passepartout.
//
//  Passepartout is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Passepartout is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with Passepartout.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation
import MessageUI

class IssueReporter: NSObject {
    static let shared = IssueReporter()
    
    private weak var viewController: UIViewController?
    
    override private init() {
        super.init()
    }

    func present(in viewController: UIViewController) {
        guard MFMailComposeViewController.canSendMail() else {
            let alert = Macros.alert(L10n.IssueReporter.title, L10n.IssueReporter.Alerts.EmailNotConfigured.message)
            alert.addCancelAction(L10n.Global.ok)
            viewController.present(alert, animated: true, completion: nil)
            return
        }
        
        self.viewController = viewController
        
        let alert = Macros.alert(L10n.IssueReporter.title, L10n.IssueReporter.message)
        alert.addDefaultAction(L10n.IssueReporter.Buttons.accept) {
            VPN.shared.requestDebugLog(fallback: AppConstants.Log.debugSnapshot) {
                self.composeEmail(withDebugLog: $0)
            }
        }
        alert.addCancelAction(L10n.Global.cancel)
        viewController.present(alert, animated: true, completion: nil)
    }
    
    private func composeEmail(withDebugLog debugLog: String?) {
        let metadata = DebugLog(raw: "--").decoratedString()
        
        let vc = MFMailComposeViewController()
        vc.setToRecipients([AppConstants.IssueReporter.recipient])
        vc.setSubject(L10n.IssueReporter.Email.subject(GroupConstants.App.name))
        vc.setMessageBody(L10n.IssueReporter.Email.body(metadata), isHTML: false)
        if let raw = debugLog {
            let attachment = DebugLog(raw: raw).decoratedData()
            vc.addAttachmentData(attachment, mimeType: AppConstants.IssueReporter.attachmentMIME, fileName: AppConstants.Log.debugFilename)
        }
        vc.mailComposeDelegate = self
        vc.apply(Theme.current)
        viewController?.present(vc, animated: true, completion: nil)
    }
}

extension IssueReporter: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        viewController?.dismiss(animated: true, completion: nil)
    }
}
