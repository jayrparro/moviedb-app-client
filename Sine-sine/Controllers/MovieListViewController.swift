//
//  MovieListViewController.swift
//  Sine-sine
//
//  Created by Leo Parro on 20/7/19.
//  Copyright © 2019 Leo Parro. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import AlamofireObjectMapper


class MovieListViewController: UICollectionViewController {
    
    let columns: CGFloat = 3.0
    let inset: CGFloat = 2.0
    let spacing: CGFloat = 2.0
    let lineSpacing: CGFloat = 2.0
    
    var footerView: CustomFooterView?
    var isLoading: Bool = false
    
    fileprivate var moviesData = [Movie]()
    fileprivate var currentPage = 1
    fileprivate var totalPages = 0
    
    let footerViewReuseIdentifier = "RefreshFooterView"
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MovieListToDetailSegue" {
            let detailViewController = segue.destination as! MovieDetailController
            detailViewController.movie = sender as? Movie
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Sine Movies"
        
        self.collectionView.register(UINib(nibName: "CustomFooterView", bundle: nil),
                                     forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                                     withReuseIdentifier: footerViewReuseIdentifier)
        
        fetchConfiguration()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func fetchConfiguration() {
        APIClient.configuration { result in
            switch result {
            case .success(let imageConfigResponse):
                if let imageConfig = imageConfigResponse.images {
                    Config.shared.configImageBaseUrl = imageConfig.secureBaseUrl!
    
                    let posterSizes = imageConfig.posterSizes!
    
                    if posterSizes.count > 0 {
                        Config.shared.configImagePosterSize = posterSizes[3]
                    }
                    
                    self.fetchMovies(page: self.currentPage)
                }
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func fetchMovies(page: Int) {
        APIClient.nowPlaying(pageId: page) { result in
            switch result {
            case .success(let moviesResponse):
                if let movies = moviesResponse.movies {
                    self.isLoading = false
                    self.totalPages = moviesResponse.totalPages
                    let currentMoviesCount = self.moviesData.count - 1
                    let newMoviesCount = movies.count - 1
                    
                    if self.moviesData.isEmpty {
                        self.moviesData = movies
                        self.collectionView.reloadData()
                        
                    } else {
                        self.moviesData.append(contentsOf: movies)
                        
                        self.collectionView.performBatchUpdates({
                            //let newItems = (self.items.count...self.items.count + 12).map {}
                            let insertIndexPaths = Array(currentMoviesCount...(currentMoviesCount+newMoviesCount)).map{
                                IndexPath(item: $0, section: 0)
                            }
                            
                            self.collectionView.insertItems(at: insertIndexPaths)
                        }, completion: nil)
                    }

                    
                }
                
            case .failure(let error):
                self.isLoading = false
                print(error.localizedDescription)
            }
        }
    }
}

// MARK: UICollectionViewDataSource
extension MovieListViewController {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return moviesData.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieListCellIdentifier", for: indexPath) as! MovieListCell
        
        // Configure the cell
        let item = moviesData[indexPath.row]        
        
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
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionFooter {
            let aFooterView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: footerViewReuseIdentifier, for: indexPath) as! CustomFooterView
            self.footerView = aFooterView
            self.footerView?.backgroundColor = UIColor.clear
            return aFooterView
        } else {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: footerViewReuseIdentifier, for: indexPath)
            return headerView
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        if elementKind == UICollectionView.elementKindSectionFooter {
            self.footerView?.prepareInitialAnimation()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
        if elementKind == UICollectionView.elementKindSectionFooter {
            self.footerView?.stopAnimate()
        }
    }
    
}

// MARK: UICollectionViewDelegate
extension MovieListViewController {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let movie = moviesData[indexPath.row]
        performSegue(withIdentifier: "MovieListToDetailSegue", sender: movie)
    }
}

// MARK: UICollectionViewDelegateFlowLayout
extension MovieListViewController: UICollectionViewDelegateFlowLayout {
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if isLoading {
            return CGSize.zero
        }
        return CGSize(width: collectionView.bounds.size.width, height: 55)
    }
}

// MARK: UIScrollViewDelegate
extension MovieListViewController {
    //compute the scroll value and play with the threshold to get desired effect
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let threshold = 100.0
        let contentOffset = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let diffHeight = contentHeight - contentOffset
        let frameHeight = scrollView.bounds.size.height
        var triggerThreshold  = Float((diffHeight - frameHeight))/Float(threshold)
        triggerThreshold =  min(triggerThreshold, 0.0)
        let pullRatio = min(abs(triggerThreshold), 1.0)
        self.footerView?.setTransform(inTransform: CGAffineTransform.identity, scaleFactor: CGFloat(pullRatio))
        if pullRatio >= 1 {
            self.footerView?.animateFinal()
        }
    }
    
    //compute the offset and call the load method
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y    // contentOffset
        let contentHeight = scrollView.contentSize.height   // contentHeight
        
        if offsetY > contentHeight - scrollView.frame.height {
            if (self.footerView?.isAnimatingFinal)! {
                self.isLoading = true
                self.footerView?.startAnimate()
                
                self.currentPage += 1
                if self.currentPage <= self.totalPages {
                    self.fetchMovies(page: self.currentPage)
                }
            }
        }
    }
}
