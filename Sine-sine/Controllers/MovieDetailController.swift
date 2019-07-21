//
//  MoviewDetailController.swift
//  Sine-sine
//
//  Created by Leo Parro on 20/7/19.
//  Copyright © 2019 Leo Parro. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage


class MovieDetailController: UIViewController, UIScrollViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet private weak var posterImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var overview: UITextView!
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet fileprivate weak var collectionViewContentHeight: NSLayoutConstraint!
    
    let columns: CGFloat = 3.0
    let inset: CGFloat = 2.0
    let spacing: CGFloat = 2.0
    let lineSpacing: CGFloat = 2.0
    
    fileprivate var similarMoviesData = [Movie]()
    var movie: Movie?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLabel.text = ""
        
        populateContentData()
        
        if let movieId = movie?.id {
            fetchSimilarMovies(movieId: movieId)
        }
    }

    func populateContentData() {
        if let title = movie?.title, let releaseDate = movie?.releaseDate {
            self.titleLabel.text = "\(title) ∙ \(releaseDate.prefix(4))"
        }
        
        self.overview.text = movie?.overview
        
        if let posterImagePath = movie?.posterPath,
            let imageBaseUrl = Config.shared.configImageBaseUrl,
            let posterImageSize = Config.shared.configImagePosterSize {
            let imageUrl = imageBaseUrl + posterImageSize + posterImagePath

            Alamofire.request(imageUrl).responseImage { response in
                if let image = response.result.value {
                    self.posterImageView.image = image
                }
            }
        }
    }
    
    func resizeCollectionViewSize(){
        self.collectionViewContentHeight.constant = self.collectionView.collectionViewLayout.collectionViewContentSize.height
        
        self.collectionView.setNeedsLayout()
        self.collectionView.layoutIfNeeded()
    }
    
    func fetchSimilarMovies(movieId: Int) {
        APIClient.similarMovies(movieId: movieId) { result in
            switch result {
            case .success(let moviesResponse):
                if let movies = moviesResponse.movies {                    
                    self.similarMoviesData = movies
                    self.collectionView.reloadData()
                    self.resizeCollectionViewSize()
                }
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

// MARK: UICollectionViewDataSource
extension MovieDetailController {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return similarMoviesData.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieListCellIdentifier", for: indexPath) as! MovieListCell
        
        let item = similarMoviesData[indexPath.row]

        if let posterImagePath = item.posterPath,
            let imageBaseUrl = Config.shared.configImageBaseUrl,
            let posterImageSize = Config.shared.configImagePosterSize {
            let imageUrl = imageBaseUrl + posterImageSize + posterImagePath

            Alamofire.request(imageUrl).responseImage { response in
                if let image = response.result.value {
                    cell.imageView.image = image
                }
            }
        }

        return cell
    }
}

// MARK: UICollectionViewDelegate
extension MovieDetailController {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let movie = similarMoviesData[indexPath.row]
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "MovieDetailStoryboardId") as! MovieDetailController
        vc.movie = movie
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
}


// MARK: UICollectionViewDelegateFlowLayout
extension MovieDetailController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width / columns) - (inset + spacing)
        return CGSize(width: width, height: width * 1.5)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return spacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return lineSpacing
    }
}
