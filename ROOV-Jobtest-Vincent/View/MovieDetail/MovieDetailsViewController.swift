//
//  MovieDetailsViewController.swift
//  IST-iOSTechnicalTest
//
//  Created by Vincent on 17/03/22.
//

import UIKit
import WebKit

class MovieDetailsViewController: UIViewController {
    
    @IBOutlet weak var bannerImageView: UIImageView!
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var averageVoteLabel: UILabel!
    @IBOutlet weak var popularityLabel: UILabel!
    @IBOutlet weak var overviewTextView: UITextView!
    @IBOutlet weak var webKitPlayer: WKWebView!
    @IBOutlet weak var userReviewTableView: UITableView!
    @IBOutlet weak var userReviewLabel: UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    var arrMovieDetails: MovieDetails?
    var arrReview = Reviews()
    var currentPageReview = 1
    
    var id = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userReviewTableView.delegate = self
        userReviewTableView.dataSource = self
        
        userReviewTableView.register(UINib(nibName: "UserReviewTableViewCell", bundle: nil), forCellReuseIdentifier: "UserReviewTableViewCell")

        // Do any additional setup after loading the view.
        APIService.shared.AFMovieDetail(id: id) { data in
            DispatchQueue.main.async {
                self.arrMovieDetails = data
                self.bannerImageView.loadImage(fromURL: "https://image.tmdb.org/t/p/original\(data.backdrop_path ?? "")")
                self.posterImageView.loadImage(fromURL: "https://image.tmdb.org/t/p/original\(data.poster_path ?? "")")
                self.movieTitleLabel.text = data.title
                self.averageVoteLabel.text = "\(data.vote_average ?? 0.0)/10"
                self.popularityLabel.text = "Popularity: \(Int(data.popularity ?? 0))"
                self.overviewTextView.text = data.overview
                self.title = data.title
            }
        }
        
        APIService.shared.AFMovieTrailer(id: id) { data in
            if !data.results!.isEmpty{
                DispatchQueue.main.async {
                    self.loadYoutube(videoID: data.results?[0].key ?? "-aAHfOQ7Rbo")
                }
            }
        }
        
        APIService.shared.AFUserReview(page: currentPageReview, id: id) { data in
            DispatchQueue.main.async {
                self.arrReview = data
                self.userReviewTableView.reloadData()
            }
        }
    }
    
    func loadYoutube(videoID:String) {
        guard let youtubeURL = URL(string: "https://www.youtube.com/embed/\(videoID)")
        else { return }
        webKitPlayer.load( URLRequest(url: youtubeURL) )
    }
}

extension MovieDetailsViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrReview.results?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = userReviewTableView.dequeueReusableCell(withIdentifier: "UserReviewTableViewCell", for: indexPath) as! UserReviewTableViewCell
        cell.contentReviewText.text = arrReview.results?[indexPath.row].content
        cell.rateLabel.text = "10"
        cell.usernameLabel.text = arrReview.results?[indexPath.row].author_details.username

        var avatarImageURL = arrReview.results?[indexPath.row].author_details.avatar_path ?? ""
        if !avatarImageURL.isEmpty{
            avatarImageURL.remove(at: avatarImageURL.startIndex)
            cell.avatarImage.loadImage(fromURL: avatarImageURL)
        }

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 158
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (indexPath.row == arrReview.results!.count - 5){
            currentPageReview += 1
            APIService.shared.AFUserReview(page: currentPageReview, id: id) { data in
                DispatchQueue.main.async {
                    self.arrReview.results?.append(contentsOf: data.results ?? [])
                    self.userReviewTableView.reloadData()
                }
            }
        }
    }
}
