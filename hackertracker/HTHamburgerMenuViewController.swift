//
//  HTHamburgerMenuViewController.swift
//  hackertracker
//
//  Created by Christopher Mays on 7/28/18.
//  Copyright © 2018 Beezle Labs. All rights reserved.
//

import UIKit

struct HamburgerItem {
    let title : String
    let imageID : String
    
    static func == (lhs: HamburgerItem, rhs: HamburgerItem) -> Bool {
        return lhs.title == rhs.title &&
            lhs.imageID == rhs.imageID
    }
}

class HTHamburgerMenuViewController: UIViewController, HTHamburgerMenuTableViewControllerDelegate {
  
    var currentViewController : UIViewController?
    var hamburgerMenuLeftContraint : NSLayoutConstraint?
    var hamburgerMenuOpen = false

    let hamburgerTableViewController : HTHamburgerMenuTableViewController
    let hamburgerNavigationController: HTEventsNavViewController
    let alphaView = UIView()

    //let leftButton = UIBarButtonItem(title:"Menu", style:UIBarButtonItemStyle.plain, target: self, action: #selector(hamburgerMenuItemPressed))
    let leftButton = UIBarButtonItem(image: #imageLiteral(resourceName: "menu"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(hamburgerMenuItemPressed))
    let intialTab = "Home"
    //This is a mapping of tabs to vcs
    let tabs = [
                "Home" : "HTUpdatesViewController",
                "Events" : "HTScheduleTableViewController",
                "My Schedule" : "HTMyScheduleTableViewController",
                "Map" : "HTMapsViewController",
                "FAQ" : "HTFAQTableViewController",
                "News" : "HTNewsTableViewController",
                "Vendors": "HTVendorTableViewController"
                //"Settings": "HTConferenceTableViewController" // Include this after DEFCON
    ];
    
    //This is a list of tabs we will display in the hamburger menu
    let displayedTabs = [
        HamburgerItem(title:"Home", imageID:"skull-active"),
        HamburgerItem(title:"Events", imageID:"calendar-active"),
        HamburgerItem(title:"My Schedule", imageID:"star_active"),
        HamburgerItem(title:"Map", imageID:"map-active"),
        HamburgerItem(title:"FAQ", imageID:"faq"),
        HamburgerItem(title:"News", imageID:"news"),
        HamburgerItem(title: "Vendors", imageID: "vendor")
        //HamburgerItem(title: "Settings", imageID: "filter") // Include this after DEFCON
    ]
    
    let hamburgerMenuWidth : CGFloat = 300.0
    
    required init?(coder aDecoder: NSCoder) {
        hamburgerTableViewController = HTHamburgerMenuTableViewController(hamburgerItems: displayedTabs)
        hamburgerNavigationController = HTEventsNavViewController()
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        let edgeSwipe = UIScreenEdgePanGestureRecognizer()
        edgeSwipe.addTarget(self, action: #selector(edgeSwipe(sender:)))
        edgeSwipe.edges = UIRectEdge.left
        self.view.addGestureRecognizer(edgeSwipe)
        
        hamburgerTableViewController.delegate = self
        setCurrentViewController(tabID: intialTab)
        self.addChildViewController(hamburgerNavigationController)
        self.view.addSubview(hamburgerNavigationController.view)
        alphaView.backgroundColor = UIColor.black
        alphaView.alpha = 0.0
        
        hamburgerNavigationController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        hamburgerNavigationController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        hamburgerNavigationController.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        hamburgerNavigationController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
   
        self.view.addSubview(alphaView)
        alphaView.translatesAutoresizingMaskIntoConstraints = false
        alphaView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        alphaView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        alphaView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        alphaView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        let tapGesture = UITapGestureRecognizer(target:self, action: #selector(backgroundTapped))
        self.alphaView.addGestureRecognizer(tapGesture)
        
        let panGesture = UIPanGestureRecognizer()
        panGesture.addTarget(self, action: #selector(edgeSwipe(sender:)))
        self.view.addGestureRecognizer(panGesture)
        
        self.addChildViewController(hamburgerTableViewController)
        self.view.addSubview(hamburgerTableViewController.view)
        hamburgerTableViewController.view.translatesAutoresizingMaskIntoConstraints = false
        hamburgerTableViewController.view.widthAnchor.constraint(equalToConstant: hamburgerMenuWidth).isActive = true
        hamburgerTableViewController.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        hamburgerTableViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        hamburgerMenuLeftContraint = hamburgerTableViewController.view.trailingAnchor.constraint(equalTo: view.leadingAnchor)
        hamburgerMenuLeftContraint?.isActive = true
        
        self.hamburgerTableViewController.setSelectedItem(hamburgerItem: displayedTabs[0])
    }
    
    @objc func backgroundTapped() {
        toggleHamburgerMenu()
    }
    
    func setCurrentViewController(tabID : String) {
        if let storyboardID = tabs[tabID] {
            currentViewController = storyboard?.instantiateViewController(withIdentifier: storyboardID)
        } else {
            assertionFailure("Tab id should be tab list")
        }
        
        if let newViewController = currentViewController {
            hamburgerNavigationController.setViewControllers([newViewController], animated: false)
            currentViewController?.navigationItem.leftBarButtonItem = leftButton
        }
    }
    
    @objc func hamburgerMenuItemPressed() {
        toggleHamburgerMenu()
    }
    
    func didSelectItem(item: HamburgerItem) {
        setCurrentViewController(tabID: item.title)
        self.view.layoutIfNeeded()
        toggleHamburgerMenu()
        self.hamburgerTableViewController.setSelectedItem(hamburgerItem: item)
    }
    
    func toggleHamburgerMenu() {
        guard let leftConstraint = hamburgerMenuLeftContraint else {
            return;
        }
        
        let appearing = leftConstraint.constant <= 0
        leftConstraint.constant = appearing ? hamburgerMenuWidth : 0

        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
            self.alphaView.alpha = appearing ? 0.5 : 0.0
        }
        
        hamburgerMenuOpen = !hamburgerMenuOpen
    }
    
    @objc func edgeSwipe(sender: UIPanGestureRecognizer) {
        guard let leftConstraint = hamburgerMenuLeftContraint else {
            return;
        }
        
        switch sender.state {
        case .began:
            break;
        case .changed:
            leftConstraint.constant = max(min(leftConstraint.constant + sender.translation(in:self.view).x, hamburgerMenuWidth), 0.0)
            self.alphaView.alpha = leftConstraint.constant/(hamburgerMenuWidth * 2)
        default:
            if hamburgerMenuOpen && leftConstraint.constant < 250 {
                hamburgerMenuOpen = false
            } else if !hamburgerMenuOpen && leftConstraint.constant > 50 {
                hamburgerMenuOpen = true
            }
            
            let appearing = hamburgerMenuOpen
            let newXDestination = appearing ? hamburgerMenuWidth : 0
            let timeToLocation = abs((newXDestination - leftConstraint.constant) / hamburgerMenuWidth) * 0.3
            leftConstraint.constant = newXDestination
            
            UIView.animate(withDuration:Double(timeToLocation)) {
                self.view.layoutIfNeeded()
                self.alphaView.alpha = appearing ? 0.5 : 0.0
            }
        }
        
        sender.setTranslation(CGPoint.zero, in: self.view)
    }
}