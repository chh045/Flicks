//
//  MoviesViewController.swift
//  Flicks
//
//  Created by Huang Edison on 1/8/17.
//  Copyright © 2017 Edison. All rights reserved.
//

import UIKit
import AFNetworking

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{

    @IBOutlet weak var tableView: UITableView!
    var movies: [NSDictionary]? //if the api is down, the movie list can be nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.

        tableView.dataSource = self
        tableView.delegate = self
        
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = URL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")!
        let request = URLRequest(url: url)

        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate: nil,
            delegateQueue: OperationQueue.main
        )

        let task: URLSessionDataTask =
            session.dataTask(
            with: request,
            completionHandler: {
                (dataOrNil, response, error) in
                    if let data = dataOrNil {
                        if let responseDictionary = try! JSONSerialization.jsonObject(
                            with: data, options: []) as? NSDictionary {
                                //NSLog("reponse: \(responseDictionary)")
                                self.movies = responseDictionary["results"] as? [NSDictionary]
                                self.tableView.reloadData()
                            }
                    }
            }
        )
        
        task.resume()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let movies = movies {
            return movies.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        
        let movie = movies![indexPath.row]
        
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        
        let base_url = "https://image.tmdb.org/t/p/w500"
        let file_path = movie["poster_path"] as! String
        let image_url = NSURL(string: base_url + file_path)
        
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        cell.posterView.setImageWith(image_url as! URL)
        
        //cell.textLabel!.text = title
        //print("row \(indexPath.row)")
        return cell
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
