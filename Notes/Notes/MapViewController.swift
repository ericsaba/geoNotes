//
//  MapViewController.swift
//  Notes
//
//  Created by Eric Saba on 2/1/16.
//  Copyright © 2016 Eric Saba. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import GoogleMaps

class MapViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate, UIPopoverPresentationControllerDelegate, TypeDelegateProtocol {
    
    
    //Location and Google Maps
    var locationManager: CLLocationManager!
    var mapView: GMSMapView?
    var mapType: String = "Satellite"
    
    
    //Notes & Markers
    var markers: Dictionary<String, [GMSMarker]> = Dictionary<String, [GMSMarker]> ()
    var notes: Dictionary<String, [Note]> = Dictionary<String, [Note]>()
    
    
    //Location Values
    var latitude = 0.0
    var longitude = 0.0
    var prevLat = 0.0
    var prevLong = 0.0
    
    
    //Buttons
    var recenterButton: UIButton! = UIButton()
    var typeButton: UIButton! = UIButton()
    var listButton: UIButton! = UIButton()
    var postButton: UIButton! = UIButton()
    var recenterPushed: Bool = false
    
    
    //Note Types
    var noteImages: [UIImage] = [UIImage(named: "anonnote")!, UIImage(named: "personalnote")!, UIImage(named: "scenerynote")!, UIImage(named: "restaurantnote")!, UIImage(named: "cautionnote")!]
    var noteTypes: [String] = ["anon", "personal", "scenery", "restaurant", "caution"]
    
    
    //Note View
    var curNoteView: Note?
    var curType = "anonicon"
    
    
    //Google Autocomplete API
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var resultView: UITextView?
    var searchView: UIView?
    var searchButton: UIButton?
    let SEARCH_BAR_HEIGHT: CGFloat = 45.0
    let SEARCH_BAR_OFFSET: CGFloat = 20.0

    
    //UIViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBarHidden = true
        
        let camera = GMSCameraPosition.cameraWithLatitude(latitude,
            longitude: longitude, zoom: CAMERA_ZOOM)
        mapView = GMSMapView.mapWithFrame(CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height), camera: camera)
        manageLocation()
        setUpMap()
        addButtons()
        setUpSearch()
        
        for s in noteTypes {
            markers.updateValue([GMSMarker](), forKey: s)
        }
        getData()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        getData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func popoverPresentationControllerDidDismissPopover(popoverPresentationController: UIPopoverPresentationController) {
        getData()
    }
    
    //Set Up
    func addButtons() {
        searchButton = UIButton(frame: CGRect(x: self.view.frame.width - 70, y: Y_INSET - BUTTON_SIZE, width: BUTTON_SIZE, height: BUTTON_SIZE))
        searchButton!.setImage(UIImage(named: "search_button"), forState: UIControlState.Normal)
        searchButton!.addTarget(self, action: #selector(MapViewController.searchPressed(_:)), forControlEvents: .TouchUpInside)
        self.mapView!.addSubview(searchButton!)
        
        let settingsButton: UIButton = UIButton(frame: CGRect(x: 10.0, y: Y_INSET - BUTTON_SIZE, width: BUTTON_SIZE, height: BUTTON_SIZE))
        settingsButton.setImage(UIImage(named: "settings_button"), forState: UIControlState.Normal)
        settingsButton.addTarget(self, action: #selector(MapViewController.settingsPressed(_:)), forControlEvents: .TouchUpInside)
        self.mapView!.addSubview(settingsButton)
        
        postButton = UIButton(frame: CGRect(x: self.view.frame.width - 70, y: self.view.frame.height - Y_INSET, width: BUTTON_SIZE, height: BUTTON_SIZE))
        postButton.setImage(UIImage(named: "post_button"), forState: UIControlState.Normal)
        postButton.addTarget(self, action: #selector(MapViewController.postPressed(_:)), forControlEvents: .TouchUpInside)
        self.view.addSubview(postButton)
        
        listButton = UIButton(frame: CGRect(x: 10.0, y: self.view.frame.height - Y_INSET, width: BUTTON_SIZE, height: BUTTON_SIZE))
        listButton.setImage(UIImage(named: "list_button"), forState: UIControlState.Normal)
        listButton.addTarget(self, action: #selector(MapViewController.listPressed(_:)), forControlEvents: .TouchUpInside)
        self.view.addSubview(listButton)
        
        typeButton = UIButton(frame: CGRect(x: (self.view.frame.width / 2) - TYPE_SIZE/2, y: Y_INSET/2 - 15.0, width: TYPE_SIZE, height: TYPE_SIZE))
        typeButton.setImage(UIImage(named: "anonicon"), forState: UIControlState.Normal)
        typeButton.addTarget(self, action: #selector(MapViewController.typePressed(_:)), forControlEvents: .TouchUpInside)
        typeButton.layer.cornerRadius = 5
        typeButton.clipsToBounds = true
        self.mapView!.addSubview(typeButton)
        
        recenterButton = UIButton(frame: CGRect(x: (self.view.frame.width / 2) - BUTTON_SIZE/2, y: self.view.frame.height - Y_INSET, width: BUTTON_SIZE, height: BUTTON_SIZE))
        recenterButton.setImage(UIImage(named: "recenter_button"), forState: UIControlState.Normal)
        recenterButton.addTarget(self, action: #selector(MapViewController.recenterPressed(_:)), forControlEvents: .TouchUpInside)
        
        recenterButton.hidden = true
        self.view.addSubview(recenterButton)
    }
    
    
    func setUpMap() {
        mapView?.setMinZoom(18.0, maxZoom: (mapView?.maxZoom)!)
        mapView!.mapType = kGMSTypeSatellite
        mapView?.delegate = self
        self.view.addSubview(mapView!)
        setMapStyle(PFUser.currentUser()!.objectForKey("mapType") as! String)
    }
    
    
    func setUpSearch() {
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
        resultsViewController?.tableCellBackgroundColor = ACCENT_COLOR
        resultsViewController?.primaryTextColor = UIColor.lightTextColor()
        resultsViewController?.primaryTextHighlightColor = UIColor.whiteColor()
        resultsViewController?.secondaryTextColor = UIColor.lightTextColor()
        
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        
        let subview = UIView(frame: CGRect(x: 0.0, y: SEARCH_BAR_OFFSET, width: self.view.frame.width, height: SEARCH_BAR_HEIGHT))
        searchView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: SEARCH_BAR_OFFSET + SEARCH_BAR_HEIGHT))
        searchView?.backgroundColor = ACCENT_COLOR
        searchView?.addSubview(subview)
        
        searchController?.searchBar.barTintColor = ACCENT_COLOR
        searchController?.searchBar.tintColor = UIColor.whiteColor()
        
        subview.addSubview((searchController?.searchBar)!)
        
        self.view.addSubview(searchView!)
        mapAndButtonsToFront()
        searchController?.hidesNavigationBarDuringPresentation = false
        
        // When UISearchController presents the results view, present it in
        // this view controller, not one further up the chain.
        self.definesPresentationContext = true
    }
    
    func mapAndButtonsToFront() {
        self.view.bringSubviewToFront(mapView!)
        self.view.bringSubviewToFront(recenterButton)
        self.view.bringSubviewToFront(listButton)
        self.view.bringSubviewToFront(postButton)
    }
    
    
    //Map Settings
    func setMapStyle(style: String) {
        mapType = style
        if (style == "Satellite") {
            mapView?.mapType = kGMSTypeSatellite
        }
        else if (style == "Hybrid") {
            mapView?.mapType = kGMSTypeHybrid
        }
        else if (style == "Normal") {
            mapView?.mapType = kGMSTypeNormal
        }
    }
    
    
    //Location Methods
    func manageLocation() {
        mapView?.myLocationEnabled = true

        if !CLLocationManager.locationServicesEnabled() {
            locationManager.requestWhenInUseAuthorization()
        }
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            if mapView?.myLocation != nil {
                mapView?.camera = GMSCameraPosition.cameraWithLatitude((mapView?.myLocation?.coordinate.latitude)!,
                    longitude: (mapView?.myLocation?.coordinate.longitude)!, zoom: CAMERA_ZOOM)
            }
        }
        else {
            let alert = UIAlertController(title: "Location Services Disabled", message: "This app requires location services to be enabled. Go to Settings > Privacy > Location Services to enable this app.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: { (UIAlertAction) -> Void in
            }))
            self.presentViewController(alert, animated: true, completion: { () -> Void in
            })
        }
//        latitude = 36.0047591105439
//        longitude = -78.9245382138332
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations.last! as CLLocation
        
        latitude = location.coordinate.latitude
        longitude = location.coordinate.longitude
        
        if (CallHandler().findDistance(prevLat, long1: prevLong, lat2: latitude, long2: longitude) >= 10) {
            recenterButton.hidden = false
            if (prevLat == 0.0 && prevLong == 0.0) {
                recenterPressed(nil)
            }
            prevLat = latitude
            prevLong = longitude
            getData()
        }
    }
    
    //Data Methods
    func getData() {
        CallHandler().getAllNotes(self.latitude, long: self.longitude) { (success, dict) -> Void in
            if success {
                for (key, value) in self.markers {
                    for m in value {
                        m.map = nil
                    }
                    self.markers[key] = [GMSMarker]()
                }
                
                self.notes = dict
                for (key, value) in self.notes {
                    for note in value {
//                        if (note.dist <= FIND_RADIUS) {
                            let marker = GMSMarker(position: CLLocationCoordinate2D(latitude: note.lat!, longitude: note.long!))
                            marker.title = note.text!
                            marker.icon = self.noteImages[self.getTypeIndex(note.type!)]
                            marker.map = self.mapView
                            marker.layer.cornerRadius = 5
                            self.markers[key]?.append(marker)
//                        }
                    }
                }
                self.setType(self.curType)
            }
            else {
                print("error")
            }
        }
    }

    
    //Type Methods
    func getTypeIndex(type: String) -> Int {
        for i in 0...noteTypes.count - 1 {
            if type == noteTypes[i] {
                return i
            }
        }
        return 0
    }
    
    func setType(type: String) {
        curType = type
        typeButton.setImage(UIImage(named: type), forState: UIControlState.Normal)
        let typeName = type.componentsSeparatedByString("icon")[0]
        for array in self.markers.values {
            for m in array {
                m.map = mapView
            }
        }
        if typeName != "anon" {
            for (key, value) in self.markers {
                if key != typeName {
                    for m in value {
                        m.map = nil
                    }
                }
            }
        }
    }
    

    //MapView Methods
    func mapView(mapView: GMSMapView, didChangeCameraPosition position: GMSCameraPosition) {
        if (!recenterPushed) {
            recenterButton.hidden = false
        }
        recenterPushed = false
    }
    
    func mapView(mapView: GMSMapView, didTapInfoWindowOfMarker marker: GMSMarker) {
        for (_, listNotes) in notes {
            for note in listNotes {
                if marker.title == note.text {
                    curNoteView = note
                    break
                }
            }
        }
        performSegueWithIdentifier("NotePopOverSegue", sender: self)
    }
    
    
    //Button Calls
    func recenterPressed(sender: UIButton!) {
        mapView!.camera = GMSCameraPosition.cameraWithLatitude(latitude,
            longitude: longitude, zoom: CAMERA_ZOOM)
        recenterPushed = true
        recenterButton.hidden = true
    }
    
    func postPressed(sender: UIButton!) {
        self.performSegueWithIdentifier("PostSegue", sender: self)
    }
    
    func listPressed(sender: UIButton!) {
        self.performSegueWithIdentifier("ListSegue", sender: self)
    }
    
    func settingsPressed(sender: UIButton!) {
        self.performSegueWithIdentifier("SettingsSegue", sender: self)
    }
    
    func typePressed(sender: UIButton) {
        performSegueWithIdentifier("PopoverSegue", sender: sender)
    }
    
    func searchPressed(sender: UIButton) {
        if mapView?.frame.height == self.view.frame.height {
            UIView.animateWithDuration(0.5) {
                self.mapView?.frame = CGRect(x: 0.0, y: self.SEARCH_BAR_HEIGHT + self.SEARCH_BAR_OFFSET - 1.0, width: self.view.frame.width, height: self.view.frame.height - (self.SEARCH_BAR_HEIGHT + self.SEARCH_BAR_OFFSET - 1.0))
            }
        }
        else {
            hideSearchBar()
        }
    }
    
    func hideSearchBar() {
        UIView.animateWithDuration(0.5) {
            self.mapView?.frame = CGRect(x: 0.0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        }
    }
    

    //Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "ListSegue") {
            let listTVC = segue.destinationViewController as! ListTableViewController
            listTVC.userLat = latitude
            listTVC.userLong = longitude
        }
        else if (segue.identifier == "PopoverSegue") {
            let dvc: NoteTypeViewController = segue.destinationViewController as! NoteTypeViewController
            dvc.delegate = self
            var numDisplayed = self.view.frame.width % TYPE_SIZE + 5.0
            if numDisplayed > CGFloat(dvc.iconsArray.count) {
                numDisplayed = CGFloat(dvc.iconsArray.count)
            }
            dvc.preferredContentSize = CGSizeMake(numDisplayed*TYPE_SIZE + (numDisplayed+1)*5.0, TYPE_SIZE + 10.0)
            let controller: UIPopoverPresentationController = dvc.popoverPresentationController!
            controller.delegate = self
            controller.sourceView = self.view
            controller.sourceRect = typeButton.frame
        }
        else if (segue.identifier == "PostSegue") {
            let nav: UINavigationController = segue.destinationViewController as! UINavigationController
            let postVC: PostViewController = nav.childViewControllers[0] as! PostViewController
            postVC.lat = prevLat
            postVC.long = prevLong
        }
        else if (segue.identifier == "NotePopOverSegue") {
            let notePOVC: NotePopOverViewController = segue.destinationViewController as! NotePopOverViewController
            notePOVC.preferredContentSize = CGSizeMake(self.view.frame.width - 2*POPOVER_INSET, self.view.frame.height - 2*POPOVER_INSET)
            notePOVC.note = curNoteView
            let pop: UIPopoverPresentationController = notePOVC.popoverPresentationController!
            pop.delegate = self
            pop.sourceView = self.view
            pop.sourceRect = CGRect(x: self.view.frame.width / 2, y: self.view.frame.height / 2, width: 0, height: 0)
        }
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
}


//Map Auto Complete API
extension MapViewController: GMSAutocompleteResultsViewControllerDelegate {
    func resultsController(resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWithPlace place: GMSPlace) {
        searchController?.active = false
        // Do something with the selected place.
        hideSearchBar()
        mapView?.camera = GMSCameraPosition.cameraWithLatitude(place.coordinate.latitude, longitude: place.coordinate.longitude, zoom: CAMERA_ZOOM)
    }
    
    func resultsController(resultsController: GMSAutocompleteResultsViewController,
                           didFailAutocompleteWithError error: NSError){
        // TODO: handle the error.
        print("Error: ", error.description)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictionsForResultsController(resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictionsForResultsController(resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
}
