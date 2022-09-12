//
//  MovieInteractor.swift
//  IST-iOSTechnicalTest
//
//  Created by Vincent on 17/03/22.
//

import Foundation
import Alamofire

class APIService {
    
    static var shared = APIService()
    
    // SEARCH MOVIE ACCORDING TO TITLE
    func AFMovieSearch(page: Int, title: String, completion: @escaping (Movies) -> Void){
        AF.request("https://api.themoviedb.org/3/search/movie?api_key=d7ff494718186ed94ee75cf73c1a3214&language=en-US&query=\(title)&page=\(page)").responseDecodable(of: Movies.self) { dataResponse in
            guard let data = dataResponse.value, dataResponse.error == nil else{
                return
            }
            completion(data)
        }
    }
    
    // MOVIE TRENDING LIST
    func AFMovieList(page: Int, completion: @escaping (Movies) -> Void){
        AF.request("https://api.themoviedb.org/3/trending/movie/day?api_key=d7ff494718186ed94ee75cf73c1a3214&page=\(page)").responseDecodable(of: Movies.self) { dataResponse in
            guard let data = dataResponse.value, dataResponse.error == nil else{
                return
            }
            completion(data)
        }
    }
    
    // MOVIE DETAIL
    func AFMovieDetail(id: Int, completion: @escaping (MovieDetails) -> Void){
        AF.request("https://api.themoviedb.org/3/movie/\(id)?api_key=d7ff494718186ed94ee75cf73c1a3214&language=en-US").responseDecodable(of: MovieDetails.self) { dataResponse in
            guard let data = dataResponse.value, dataResponse.error == nil else{
                return
            }
            completion(data)
        }
    }
    
    // MOVIE'S USER REVIEW
    func AFUserReview(page: Int, id: Int, completion: @escaping (Reviews) -> Void){
        AF.request("https://api.themoviedb.org/3/movie/\(id)/reviews?api_key=d7ff494718186ed94ee75cf73c1a3214&language=en-US&page=\(page)").responseDecodable(of: Reviews.self) { dataResponse in
            guard let data = dataResponse.value, dataResponse.error == nil else{
                return
            }
            completion(data)
        }
    }
    
    //GET YOUTUBE VIDEO KEY
    func AFMovieTrailer(id: Int, completion: @escaping (MovieVideos) -> Void){
        AF.request("https://api.themoviedb.org/3/movie/\(id)/videos?api_key=d7ff494718186ed94ee75cf73c1a3214&language=en-US").responseDecodable(of: MovieVideos.self) { dataResponse in
            guard let data = dataResponse.value, dataResponse.error == nil else{
                return
            }
            completion(data)
        }
    }
}
