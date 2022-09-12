//
//  ViewController.swift
//  ROOV-Jobtest-Vincent
//
//  Created by Vincent on 12/09/22.
//

import UIKit
import Alamofire

class ViewController: UIViewController {
    
    @IBOutlet weak var movieSearchBar: UISearchBar!
    @IBOutlet weak var movieCollectionView: UICollectionView!

    var movieData = Movies()
    var currentPage = 1
    
    let inset: CGFloat = 10
    let minimumLineSpacing: CGFloat = 10
    let minimumInteritemSpacing: CGFloat = 10
    let cellsPerRow = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        movieCollectionView.delegate = self
        movieCollectionView.dataSource = self
        movieCollectionView.register(UINib(nibName: "MovieCellCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MovieCellCollectionViewCell")
        movieCollectionView.contentInsetAdjustmentBehavior = .always
        
        movieSearchBar.delegate = self
        
        self.title = "Trending Movies"
        
        APIService.shared.AFMovieList(page: currentPage) { movie in
            DispatchQueue.main.async {
                self.movieData = movie
                self.movieCollectionView.reloadData()
            }
        }
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movieData.results?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCellCollectionViewCell", for: indexPath) as! MovieCellCollectionViewCell
        cell.movieTitleLabel.text = movieData.results?[indexPath.row].title
        cell.tag = indexPath.row
        
        DispatchQueue.main.async {
            if cell.tag == indexPath.row{
                cell.movieImageView.loadImage(fromURL: "https://image.tmdb.org/t/p/w185\(self.movieData.results?[indexPath.row].poster_path ?? "")")
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return minimumLineSpacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return minimumInteritemSpacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let marginsAndInsets = inset * 2 + collectionView.safeAreaInsets.left + collectionView.safeAreaInsets.right + minimumInteritemSpacing * CGFloat(cellsPerRow - 1)
        let itemWidth = ((collectionView.bounds.size.width - marginsAndInsets) / CGFloat(cellsPerRow)).rounded(.down)
        return CGSize(width: itemWidth, height: 176)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        movieCollectionView.collectionViewLayout.invalidateLayout()
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if (indexPath.row == movieData.results!.count - 5){
            currentPage += 1
            if movieSearchBar.searchTextField.text!.isEmpty{
                APIService.shared.AFMovieList(page: currentPage) { movie in
                    DispatchQueue.main.async {
                        self.movieData.results?.append(contentsOf: movie.results!)
                        self.movieCollectionView.reloadData()
                    }
                }
            }else{
                APIService.shared.AFMovieSearch(page: currentPage, title: movieSearchBar.text!, completion: { movie in
                    DispatchQueue.main.async {
                        self.movieData.results?.append(contentsOf: movie.results!)
                        self.movieCollectionView.reloadData()
                    }
                })
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = UIStoryboard.init(name: "MovieDetailsViewController", bundle: nil).instantiateViewController(withIdentifier: "MovieDetailsViewController") as? MovieDetailsViewController
        vc?.id = movieData.results?[indexPath.row].id ?? 0
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
}

extension UIImageView {
    func loadImage(fromURL urlString: String) {
        guard let url = URL(string: urlString) else {
            return
        }
        
        let activityView = UIActivityIndicatorView(style: .large)
        self.addSubview(activityView)
        activityView.frame = self.bounds
        activityView.translatesAutoresizingMaskIntoConstraints = false
        activityView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        activityView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        activityView.startAnimating()
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            DispatchQueue.main.async {
                activityView.stopAnimating()
                activityView.removeFromSuperview()
            }

            if let data = data, error == nil {
                let image = UIImage(data: data)?.jpegData(compressionQuality: 0.0)
                DispatchQueue.main.async {
                    self.image = UIImage(data: image ?? Data())
                }
            }else{
                return
            }
        }.resume()
    }
}

extension ViewController: UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if !searchText.isEmpty{
            currentPage = 1
            let searchedText = searchText.replacingOccurrences(of: " ", with: "+")
            
            APIService.shared.AFMovieSearch(page: currentPage, title: searchedText) { movie in
                DispatchQueue.main.async {
                    self.movieData = movie
                    self.movieCollectionView.reloadData()
                }
            }
        }else{
            APIService.shared.AFMovieList(page: currentPage) { movie in
                DispatchQueue.main.async {
                    self.movieData = movie
                    self.movieCollectionView.reloadData()
                }
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.searchTextField.text = ""
    }
}

