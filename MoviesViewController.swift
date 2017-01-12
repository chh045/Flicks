//
//  MoviesViewController.swift
//  Flicks
//
//  Created by Huang Edison on 1/8/17.
//  Copyright © 2017 Edison. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate{

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var networkErrorLabel: UILabel!
    @IBOutlet weak var movieSearchBar: UISearchBar!
    
    var movies: [NSDictionary]? //if the api is down, the movie list can be nil
    
    var filteredMovies: [NSDictionary]!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(refreshControl:)), for: UIControlEvents.valueChanged)
        
        tableView.dataSource = self
        tableView.delegate = self
        movieSearchBar.delegate = self
        tableView.insertSubview(refreshControl, at: 0)
        networkErrorLabel.isHidden = true
        networkErrorLabel.isUserInteractionEnabled = true
        
        updateMovie()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if ((filteredMovies) != nil) {
            return filteredMovies.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        
        let movie = filteredMovies![indexPath.row]
        
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        
        let base_url = "https://image.tmdb.org/t/p/w500"
        let file_path = movie["poster_path"] as! String
        let image_url = URL(string: base_url + file_path)
        
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview

        cell.posterView.setImageWith(image_url!)
        
        //cell.textLabel!.text = title
        //print("row \(indexPath.row)")
        return cell
    }
    
    func updateMovie() {
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = URL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")!
        let request = URLRequest(url: url)
        
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate: nil,
            delegateQueue: OperationQueue.main
        )
        
        // Display HUD right before the request is made
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        let task: URLSessionDataTask =
            session.dataTask(
                with: request,
                completionHandler: {
                    (dataOrNil, response, error) in
                    
                    //Hide HUD once the network request comes back (must be done on main UI thread)
                    //MBProgressHUD.hide(for: self.view, animated: true)
                    
                    if let data = dataOrNil {
                        if let responseDictionary = try! JSONSerialization.jsonObject(
                            with: data, options: []) as? NSDictionary {
                            
                            MBProgressHUD.hide(for: self.view, animated: true)
                            
                            self.networkErrorLabel.isHidden = true
                            self.movies = responseDictionary["results"] as? [NSDictionary]
                            
                            self.filteredMovies = self.movies
                            
                            
                            self.tableView.reloadData()
                        }
                        else {
                            MBProgressHUD.hide(for: self.view, animated: true)
                            self.networkErrorLabel.isHidden = false
                            
                        }
                    }
                    else {
                        MBProgressHUD.hide(for: self.view, animated: true)
                        self.networkErrorLabel.isHidden = false
                    }
            }
        )
        
        task.resume()
    }
    
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = URL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")!
        let request = URLRequest(url: url)

        
        // Configure session so that completion handler is executed on main UI thread
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate: nil,
            delegateQueue: OperationQueue.main
        )
        
        let task : URLSessionDataTask =
            session.dataTask(
                with: request,
                completionHandler: { (dataOrNil, response, error) in
                    
                    // ... Use the new data to update the data source ...
                    if let data = dataOrNil {
                        if let responseDictionary = try! JSONSerialization.jsonObject(
                            with: data, options: []) as? NSDictionary {
                            
                            self.networkErrorLabel.isHidden = true
                            self.movies = responseDictionary["results"] as? [NSDictionary]
                            self.tableView.reloadData()
                            refreshControl.endRefreshing()

                        }
                    }
                    
                }
        )
        task.resume()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        
        guard let movies = self.movies else {
            return
        }
        
        filteredMovies = searchText.isEmpty ? movies : movies.filter({(movie : NSDictionary) -> Bool in
            let title = movie["title"] as! String
            return title.range(of: searchText, options: .caseInsensitive) != nil
        })
        
        
        tableView.reloadData()
    }
    
    @IBAction func onTap(_ sender: Any) {
        view.endEditing(true)
    }
    
    @IBAction func tapNetworkErrorLabelAction(_ sender: Any) {
        
        self.networkErrorLabel.isHidden = true
        updateMovie()
    }



    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
