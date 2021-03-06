//
//  TimeCategoryViewController.swift
//  magicOfMemo
//
//  Created by Kazutaka Homma on 2/11/19.
//  Copyright © 2019 Kazutaka. All rights reserved.
//

import UIKit
import GoogleMobileAds

class TimeCategoryViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var timeCategories: [TimeCategory] = []
    
    var adIsLoaded = false
    var adView : GADBannerView!
    var adUnitID: String {
        if stage != Stage.deploy {
            return ADMOB_TEST_AD_UNIT_ID
        }
        return "ca-app-pub-5469649181550273/6756895489"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.register(UINib(nibName: "TimeCategoryCell", bundle: Bundle.main), forCellReuseIdentifier: "TimeCategoryCell")
        tableView.register(UINib(nibName: "BannerCell", bundle: Bundle.main), forCellReuseIdentifier: "BannerCell")
        setupAdView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
        super.viewWillAppear(animated)
    }
    
    func setupAdView() {
        // Ensure subview layout has been performed before accessing subview sizes.
        tableView.layoutIfNeeded()
        let adSize = GADAdSizeFromCGSize(
            CGSize(width: tableView.contentSize.width, height: AD_VIEW_HEIGHT))
        adView = GADBannerView(adSize: adSize)
        adView.adUnitID = adUnitID
        adView.rootViewController = self
        adView.delegate = self
        let adRequest = GADRequest()
        if stage != Stage.deploy {
            adRequest.testDevices = [ "c0b9b945e7a65bb0f5e59fbfb1f92a5d" ]
        }
        adView.load(adRequest)
    }
}


extension TimeCategoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timeCategories.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "BannerCell", for: indexPath) as? BannerCell,
                  adIsLoaded else {return UITableViewCell()}
            cell.load(adView: adView)
            return cell
        }
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TimeCategoryCell", for: indexPath) as? TimeCategoryCell else {return UITableViewCell()}
        cell.timeCategory = timeCategories[indexPath.row-1]
        cell.indexPath = indexPath
        return cell
    }
    
}

extension TimeCategoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row > 0 else { return }
        let storyboard = UIStoryboard(name: "QuestionList", bundle: nil)
        guard let vc = storyboard.instantiateInitialViewController() as? QuestionListViewController else {return}
        let tc = timeCategories[indexPath.row-1]
        guard let questions = tc.questions.array as? [Question] else {return}
        vc.questions = questions
        vc.title = tc.title
        tableView.deselectRow(at: indexPath, animated: true)
        show(vc, sender: self)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            guard adIsLoaded else { return 0 }
            return AD_VIEW_HEIGHT
        }
        return CELL_HEIGHT
    }
}

extension TimeCategoryViewController: GADBannerViewDelegate {
    func adViewDidReceiveAd(_ adView: GADBannerView) {
        // Mark banner ad as succesfully loaded.
        adIsLoaded = true
        tableView.reloadData()
    }
    
    func adView(_ adView: GADBannerView,
                didFailToReceiveAdWithError error: GADRequestError) {
        print("Failed to receive ad: \(error.localizedDescription)")
    }
}
