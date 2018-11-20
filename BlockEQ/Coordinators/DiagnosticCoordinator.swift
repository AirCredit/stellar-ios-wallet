//
//  DiagnosticCoordinator.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-11-12.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Foundation

protocol DiagnosticCoordinatorDelegate: AnyObject {
    func completedDiagnostic(_ coordinator: DiagnosticCoordinator)
}

final class DiagnosticCoordinator {
    enum DiagnosticStep: Int, RawRepresentable {
        case summary
        case completion

        var next: DiagnosticStep {
            let value = rawValue + 1
            let step = self != .completion ? DiagnosticStep(rawValue: value)! : DiagnosticStep.completion
            return step
        }

        var title: String {
            switch self {
            case .summary: return "WALLET_DIAGNOSTICS_TITLE".localized()
            case .completion: return "DIAGNOSTIC_COMPLETE_TITLE".localized()
            }
        }

        var description: String {
            switch self {
            case .summary: return "WALLET_DIAGNOSTICS_DESCRIPTION".localized()
            case .completion: return "DIAGNOSTIC_COMPLETE_DESCRIPTION".localized()
            }
        }

        static let all: [DiagnosticStep] = [.summary, .completion]
    }

    var isOnLastStep: Bool {
        return step.rawValue < DiagnosticStep.all.count
    }

    var diagnosticQueue: OperationQueue {
        let operationQueue = OperationQueue()
        operationQueue.qualityOfService = .background

        return operationQueue
    }

    let diagnosticViewController = DiagnosticViewController()

    weak var delegate: DiagnosticCoordinatorDelegate?

    var currentDiagnostic: Diagnostic?
    var step: DiagnosticStep = .summary

    init() {
        diagnosticViewController.delegate = self
    }

    func reset() {
        currentDiagnostic = nil
        step = .summary

        diagnosticViewController.scrollTo(step: step, animated: false)
    }

    func runWalletDiagnostic() {
        let diagnostic = Diagnostic(walletDiagnostic: KeychainHelper.walletDiagnostic)
        currentDiagnostic = diagnostic
        diagnosticViewController.update(with: diagnostic)
    }

    func runBasicDiagnostic() {
        let diagnostic = Diagnostic()
        currentDiagnostic = diagnostic
        diagnosticViewController.update(with: diagnostic)
    }

    func sendDiagnostic() {
        guard let diagnostic = currentDiagnostic else {
            return
        }

        diagnosticViewController.showHud()

        let diagnosticOperation = SendDiagnosticOperation(
            diagnostic: diagnostic,
            completion: { result in
                self.diagnosticViewController.showDiagnosticResult(identifier: result)
        })

        diagnosticQueue.addOperation(diagnosticOperation)
    }
}

extension DiagnosticCoordinator: DiagnosticViewControllerDelegate {
    func selectedNextStep(_ viewController: DiagnosticViewController) {
        step = step.next

        if step == .completion {
            sendDiagnostic()
        }
    }

    func selectedClose(_ viewController: DiagnosticViewController) {
        diagnosticViewController.dismiss(animated: true) {
            self.delegate?.completedDiagnostic(self)
        }
    }
}
