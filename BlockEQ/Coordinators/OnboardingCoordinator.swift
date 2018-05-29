//
//  OnboardingCoordinator.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-05-19.
//  Copyright © 2018 Satraj Bambra. All rights reserved.
//

import Foundation
import stellarsdk

protocol OnboardingCoordinatorDelegate: AnyObject {
    func onboardingCompleted()
}

final class OnboardingCoordinator {
    let navController: AppNavigationController
    let launchViewController = LaunchViewController()
    let verificationViewController = VerificationViewController(type: .recovery, mnemonic: "")
    let mnemonicViewController = MnemonicViewController(mnemonic: nil, shouldSetPin: false, hideConfirmation: false)

    weak var delegate: OnboardingCoordinatorDelegate?
    var firstPin: String?
    var secondPin: String?

    init() {
        navController = AppNavigationController(rootViewController: launchViewController)
        mnemonicViewController.delegate = self
        verificationViewController.delegate = self
        launchViewController.delegate = self
    }
}

extension OnboardingCoordinator: LaunchViewControllerDelegate {
    func requestedCreateNewWallet(_ vc: LaunchViewController) {
        
        navController.pushViewController(mnemonicViewController, animated: true)
    }

    func requestedImportWallet(_ vc: LaunchViewController) {
        navController.pushViewController(verificationViewController, animated: true)
    }
}

extension OnboardingCoordinator: MnemonicViewControllerDelegate {
    func confirmedWrittenMnemonic(_ vc: MnemonicViewController, mnemonic: String) {
        saveMnemonic(mnemonic: mnemonic)

        let pinEntry = PinViewController(mode: .dark, pin: nil, confirming: false, isCloseDisplayed: false, shouldSavePin: false)
        pinEntry.delegate = self

        navController.pushViewController(pinEntry, animated: true)
    }
}

extension OnboardingCoordinator: VerificationViewControllerDelegate {
    func validatedAccount(_ vc: VerificationViewController, mnemonic: String) {
        saveMnemonic(mnemonic: mnemonic)

        let pinEntry = PinViewController(mode: .dark, pin: nil, confirming: false, isCloseDisplayed: false, shouldSavePin: false)
        pinEntry.delegate = self

        navController.pushViewController(pinEntry, animated: true)
    }
}

extension OnboardingCoordinator: PinViewControllerDelegate {
    func pinEntryCompleted(_ vc: PinViewController, pin: String, save: Bool) {
        if firstPin == nil {
            firstPin = pin

            let pinConfirmation = PinViewController(mode: .dark, pin: nil, confirming: true, isCloseDisplayed: false, shouldSavePin: true)
            pinConfirmation.delegate = self

            navController.pushViewController(pinConfirmation, animated: true)
        } else if KeychainHelper.checkPin(inPin: pin, comparePin: firstPin) {
            if save {
                KeychainHelper.save(pin: pin)
                KeychainHelper.setPinWhenEnteringApp(shouldSet: true)
                KeychainHelper.setPinWhenSendingPayment(shouldSet: true)
            }

            delegate?.onboardingCompleted()
        } else {
            vc.pinMismatchError()
        }
    }
}

extension OnboardingCoordinator {
    func saveMnemonic(mnemonic: String) {
        let keyPair = try! Wallet.createKeyPair(mnemonic: mnemonic, passphrase: nil, index: 0)
        
        let publicKeyData = NSData(bytes: keyPair.publicKey.bytes, length: keyPair.publicKey.bytes.count) as Data
        let privateBytes = keyPair.privateKey?.bytes ?? [UInt8]()
        let privateKeyData = NSData(bytes: privateBytes, length: privateBytes.count) as Data
        
        print("Saving wallet items")
        KeychainHelper.save(mnemonic: mnemonic)
        KeychainHelper.save(accountId: keyPair.accountId)
        KeychainHelper.save(publicKey: publicKeyData)
        KeychainHelper.save(privateKey: privateKeyData)
    }
}
