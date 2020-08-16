//
//  mapViewController.swift
//  GoodFood
//
//  Created by adithyasai neeli on 2020-08-13.
//  Copyright © 2020 GagandeepKaur. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase
import FirebaseAuth
import Firebase
import FirebaseFirestore
import CoreLocation
protocol getcurrDelegate{
    func getLoctxt(data: String)
}

class mapViewController: UIViewController,MKMapViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var MapView: MKMapView!

    @IBOutlet weak var btnDone: UIButton!
        var lat : Double?
    var long : Double?
    var city = "empty"
    var delegate: getcurrDelegate?
    var address = "empty"
    var fromVC: String?
    var selectedRestaurant: String?
    var locationsarray = [CLLocationCoordinate2D]()
  
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
   
        if(fromVC != "BookTable"){
             btnDone.setTitle("Done", for: .normal)
        let tap = UITapGestureRecognizer(target: self, action: #selector(Tapped))
        tap.numberOfTapsRequired = 1
        view.addGestureRecognizer(tap)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Search", style: .plain, target: self, action: #selector(addTapped))
                 MapView.delegate = self
        }else{
            btnDone.setTitle("Maps", for: .normal)
             MapView.delegate = self
            showroute()
        }
    }
    
    @objc func Tapped(tapges: UIGestureRecognizer ) {
 
        let allAnnotations = self.MapView.annotations
        self.MapView.removeAnnotations(allAnnotations)
        let touchPoint = tapges.location(in: MapView)
        let touchLocation = MapView.convert(touchPoint, toCoordinateFrom: MapView)
       // let location = CLLocation(latitude: touchLocation.latitude, longitude: touchLocation.longitude)
        let myAnnotation = MKPointAnnotation()
        myAnnotation.coordinate = touchLocation
        MapView.addAnnotation(myAnnotation)
        lat = myAnnotation.coordinate.latitude
        long = myAnnotation.coordinate.longitude
        myAnnotation.title = "\( getAddress(ann: myAnnotation))"

      
        let newp = CLLocationCoordinate2D(latitude: lat! ,longitude: long!)
        let latDelta: CLLocationDegrees = 0.60
        let longDelta: CLLocationDegrees = 0.60
        
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: longDelta)
        
        let regionSpan =   MKCoordinateRegion(center: newp , span: span )
        
        self.MapView.setRegion(regionSpan, animated: true)
        
    }
    
    @objc func addTapped(){
        let searchcontroller = UISearchController(searchResultsController: nil)
        searchcontroller.searchBar.delegate = self
        present(searchcontroller, animated: true, completion: nil)
    }
    
    func getDirections(loc1: CLLocationCoordinate2D, loc2: CLLocationCoordinate2D) {
       let source = MKMapItem(placemark: MKPlacemark(coordinate: loc1))
       source.name = "Your Location"
       let destination = MKMapItem(placemark: MKPlacemark(coordinate: loc2))
       destination.name = "Destination"
       MKMapItem.openMaps(with: [source, destination], launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        
        
        //Activity Indicator
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.style = UIActivityIndicatorView.Style.medium
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        
        self.view.addSubview(activityIndicator)
        
        //Hide search bar
        searchBar.resignFirstResponder()
        dismiss(animated: true, completion: nil)
        
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = searchBar.text
        
        let activeSearch = MKLocalSearch(request: searchRequest)
        
        activeSearch.start { (response, error ) in
            
            activityIndicator.stopAnimating()
            
            
            if response  == nil {
                print("error")
            }else{
                
                
                
                let latitude = response?.boundingRegion.center.latitude
                let longitude = response?.boundingRegion.center.longitude
                
                let annotation = MKPointAnnotation()
                self.lat = annotation.coordinate.latitude
                self.long = annotation.coordinate.longitude
                
                annotation.title = searchBar.text
                self.address = searchBar.text!
                annotation.coordinate = CLLocationCoordinate2D(latitude: latitude!,longitude: longitude!)
                self.MapView.addAnnotation(annotation)
                let newp = CLLocationCoordinate2D(latitude: latitude! ,longitude: longitude!)
             
                let latDelta: CLLocationDegrees = 0.60
                let longDelta: CLLocationDegrees = 0.60
                
                let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: longDelta)
                
                let regionSpan =   MKCoordinateRegion(center: newp , span: span )
                
                self.MapView.setRegion(regionSpan, animated: true)
                
                
                
                
            }
        }
        
        
        
        
    }
    
    
    func showroute(){
        
        let sr = self.selectedRestaurant
        let db = Firestore.firestore().collection("restaurants").document(sr!.lowercased())
        db.getDocument { (document, error) in
             if let document = document, document.exists {
                 let docData = document.data()
                  let status = docData!["address"] as? String ?? ""
            
                    self.trial(address:status)
          
              } else {
                 print("Document does not exist")

              }
        }
        
              
        
        let currentUser = (Auth.auth().currentUser?.uid)!
        
        let db2 = Firestore.firestore().collection("users").document(currentUser)
        
        db2.getDocument { (document, error) in
             if let document = document, document.exists {
                 let docData = document.data()
                  let status = docData!["address"] as? String ?? ""
                 self.trial(address:status)
              } else {
                 print("Document does not exist")

              }
        }
        
         DispatchQueue.main.asyncAfter(deadline: .now() + 2) {

            let sourcePlaceMark = MKPlacemark(coordinate: self.locationsarray[0])
            let destinationPlaceMark = MKPlacemark(coordinate: self.locationsarray[1])
            let DirectRequest = MKDirections.Request()
            DirectRequest.source = MKMapItem(placemark: sourcePlaceMark)
            DirectRequest.destination = MKMapItem(placemark: destinationPlaceMark)
            
            let directions = MKDirections(request: DirectRequest)
            directions.calculate { (response, error) in
                guard let Directionresponse = response else {
                    if let error = error {
                        print(error)
                    }
                    return
                }
                let route = Directionresponse.routes[0]
                self.MapView.addOverlay(route.polyline, level: .aboveRoads)
                
                let rect = route.polyline.boundingMapRect
                self.MapView.setRegion(MKCoordinateRegion(rect), animated: true)
                
            }

            self.MapView.delegate = self
        }
    }
    
    func mapView(_ mapView: MKMapView,
                   rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
          let renderer = MKPolylineRenderer(overlay: overlay)
                 renderer.strokeColor = UIColor.blue
                 renderer.lineWidth = 4.0
             
                 return renderer
          
          
          
      }

 
    func trial(address: String){
        
        let searchRequest = MKLocalSearch.Request()
           searchRequest.naturalLanguageQuery = address
        let activeSearch = MKLocalSearch(request: searchRequest)
               
               activeSearch.start { (response, error ) in
             
                   if response  == nil {
                       print("error")
                   }else{
                             let latitude = response?.boundingRegion.center.latitude
                                   let longitude = response?.boundingRegion.center.longitude
                                   
                                   let annotation = MKPointAnnotation()
                                   self.lat = annotation.coordinate.latitude
                                   self.long = annotation.coordinate.longitude
                                   
                                   annotation.title = address
                                   annotation.coordinate = CLLocationCoordinate2D(latitude: latitude!,longitude: longitude!)
                                   self.MapView.addAnnotation(annotation)
                                   let newp = CLLocationCoordinate2D(latitude: latitude! ,longitude: longitude!)
                                self.locationsarray.append(newp)
                                   let latDelta: CLLocationDegrees = 0.50
                                   let longDelta: CLLocationDegrees = 0.50
                                   
                                   let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: longDelta)
                                   
                                   let regionSpan =   MKCoordinateRegion(center: newp , span: span )
                                   
                                   self.MapView.setRegion(regionSpan, animated: true)
                     
                     
                 }
             
         
        
             }
        
    }
    
    @IBAction func btndone(_ sender: Any) {
        
          if(fromVC != "BookTable"){
        delegate?.getLoctxt(data: self.address)
        self.dismiss(animated: true, completion: nil)
              self.navigationController?.popViewController(animated: true)
          }else{
            getDirections(loc1: self.locationsarray[0], loc2: self.locationsarray[1])
            
        }
      
    }
    
    
    func getAddress( ann: MKPointAnnotation) {
        let location = CLLocation(latitude: lat!, longitude: long!)
        
        
        
        CLGeocoder().reverseGeocodeLocation(location) { (placemarks, error) in
            if let error = error {
                print(error)
            } else {
                if let placemark = placemarks?[0] {
                    
                    var address = ""
                    if placemark.subThoroughfare != nil {
                        address += placemark.subThoroughfare! + " "
                          
                        
                    }
                    
                    if placemark.thoroughfare != nil {
                        address += placemark.thoroughfare!
                        
                        ann.title = address
                        self.address = address
                        address = ""
                    }
                    
                    if placemark.subLocality != nil {
                        address += placemark.subLocality! + " "
                    }
                    
                    if placemark.subAdministrativeArea != nil {
                        address += placemark.subAdministrativeArea! + " "
                      
                    }
                    
                    if placemark.postalCode != nil {
                        address += placemark.postalCode! + " "
                    }
                    
                    if placemark.country != nil {
                        address += placemark.country!
                        
                        ann.subtitle = address
                        self.address += address
                       
                    }
                    
                    
                }
            }
            
            
        }
    }
    
}
