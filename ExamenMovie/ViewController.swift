//
//  ViewController.swift
//  ExamenMovie
//
//  Created by Isai Abraham on 09/09/22.
//

import UIKit
import UserNotifications

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
//               Outlet
    
    @IBOutlet weak var FotoPeliRanket: UIImageView!
    @IBOutlet weak var CollectMovie: UICollectionView!
    @IBOutlet weak var CollectGeneros: UICollectionView!
    
//               Variables
    
    var generofalso = Generos.init(genres: [generosOpciones]())
    var cellScale : CGFloat = 0.6
    var generos: Generos?
    var Pelicula: resultados?
    var cambiogeneros: Int = 18
    var pasoMovies: Movies?
    private let cache = NSCache<NSString, UIImage>()
    private let utilityQueue = DispatchQueue.global(qos: .utility)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.CollectGeneros.register(UINib(nibName: "CollectionViewCellGeneros", bundle: nil), forCellWithReuseIdentifier: "CeldaGenero")
        self.CollectGeneros.dataSource = self
        self.CollectGeneros.delegate = self
        
        self.CollectMovie.register(UINib(nibName: "CollectionViewCellMovie", bundle: nil), forCellWithReuseIdentifier: "CeldaPeliculas")
        self.CollectMovie.dataSource = self
        self.CollectMovie.delegate = self
        
        
//               Codigo para que las celdas se vean mejor
        
        let screenSize = UIScreen.main.bounds.size
        let cellWidth = floor(screenSize.width * cellScale )
        let cellHeight = floor(screenSize.height * cellScale)
        let instX = ( view.bounds.width - cellWidth ) / 7.0
        let instY = ( view.bounds.height - cellHeight ) / 12.0
        let layout = CollectMovie!.collectionViewLayout as! UICollectionViewFlowLayout

        layout.itemSize = CGSize(width: cellWidth, height: cellHeight )
   CollectMovie.contentInset = UIEdgeInsets(top: instY , left: instX , bottom: instY, right: instX )
        
        TodasLasPeliculas(genero: "28") { respuesta in
            self.Pelicula = respuesta
            
            DispatchQueue.main.async { () -> Void in
                self.CollectMovie.reloadData()
            }
        }
        
        TodasLosGeneros(completion:{ resultado in
            self.generos = resultado
            
            DispatchQueue.main.async { () -> Void in
                self.CollectGeneros.reloadData()
            }
        })
        
        
        
    }
    


    
    
    //        Funciones Necesarias
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       
        if collectionView == CollectGeneros{
            return (self.generos?.genres.count) ?? 0
        }
        return (self.Pelicula?.results.count) ?? 0
        
        if collectionView == CollectMovie {
            if  let retorno = Pelicula?.results.count {
                return retorno
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       
       let celdaMovie = self.CollectMovie.dequeueReusableCell(withReuseIdentifier: "CeldaPeliculas", for: indexPath) as? CollectionViewCellMovie
        let pelis = Pelicula?.results[indexPath.row]
        
        if let name = pelis?.poster_path {
            let imageName = "https://image.tmdb.org/t/p/original" + name
            let cacheString = NSString(string: imageName)
            
            if let cacheImage = self.cache.object(forKey: cacheString) {
                celdaMovie?.imagenMovie.image = cacheImage
            } else {
                self.loadImage(from: URL(string: imageName)) { [weak self] (image) in
                    guard let self = self, let image = image else { return }
                    celdaMovie?.imagenMovie.image = image
              
                    self.cache.setObject(image, forKey: cacheString)
                }
            }
        
        }
        
//        LLenar la celda desde la Api
        
        celdaMovie?.text1.text = String(pelis?.vote_average ?? 10.0)
        celdaMovie?.text3.text = String(pelis?.vote_count ?? Int(10.0))
        celdaMovie?.nombreMovie.text = pelis?.original_title
        celdaMovie?.text2.text = String(pelis?.popularity ?? 0)
       

        if collectionView == CollectGeneros{
            let celdaGenero = self.CollectGeneros.dequeueReusableCell(withReuseIdentifier: "CeldaGenero", for: indexPath) as? CollectionViewCellGeneros
            let MuestraGenerosDatos = generos?.genres[indexPath.row]
            celdaGenero?.labelgenero.text = MuestraGenerosDatos?.name
    
            return celdaGenero!
        }
        
        return celdaMovie!
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == CollectGeneros{
            let g = generos!.genres[indexPath.row]
            print(g)
            cambiogeneros = g.id
            let nada = detectorDeGenero(x: cambiogeneros)
            TodasLasPeliculas(genero: nada) { respuesta in
                self.Pelicula = respuesta
                DispatchQueue.main.async { () -> Void in
                    self.CollectMovie.reloadData()
                }
            }
        }
        
        if collectionView == CollectMovie{
            pasoMovies = Pelicula!.results[indexPath.row]
            performSegue(withIdentifier: "Segunda", sender: self)

        }
    }
    
    private func loadImage(from url: URL?, completion: @escaping (UIImage?) -> ()) {
        utilityQueue.async {
            guard let data = try? Data(contentsOf: url!) else { return }
            let image = UIImage(data: data)
            DispatchQueue.main.async {
                completion(image)
            }
        }
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let vc = segue.destination as? ViewControllerPantallaDos {
            vc.peliDesgloce = pasoMovies
            }
    }
    @objc
    func notiEvent (notification: Notification){
        print("evento", notification)
        let valorDeLaNotificacion = notification.userInfo
        let user = valorDeLaNotificacion!["User"] as! User
        
        
        
    }
//           Boton de kids
    @IBAction func kids(_ sender: Any) {
        TodasLasPeliculas(genero: "16") { respuesta in
            self.Pelicula = respuesta
            let imagenNiños = self.Pelicula?.results[0]
           
            if let name = imagenNiños?.poster_path {
                let imageName = "https://image.tmdb.org/t/p/original" + name
                let cacheString = NSString(string: imageName)
                if let cacheImage = self.cache.object(forKey: cacheString) {

                } else {
                    self.loadImage(from: URL(string: imageName)) { [weak self] (image) in
                        guard let self = self, let image = image else { return }

                        self.cache.setObject(image, forKey: cacheString)
                    }
                }
            }
            DispatchQueue.main.async { () -> Void in
                self.CollectMovie.reloadData()
            }
            self.generos = self.generofalso
            DispatchQueue.main.async { () -> Void in
                self.CollectGeneros.reloadData()
            }
            
        }
        
    }
//               Boton para mostras las peliculas
    @IBAction func TodasLasPelis(_ sender: Any) {
        TodasLasPeliculas(genero: "28") { respuesta in
            self.Pelicula = respuesta
            let imagenNiños = self.Pelicula?.results[0]
           
            if let name = imagenNiños?.poster_path {
                let imageName = "https://image.tmdb.org/t/p/original" + name
                let cacheString = NSString(string: imageName)
                if let cacheImage = self.cache.object(forKey: cacheString) {

                } else {
                    self.loadImage(from: URL(string: imageName)) { [weak self] (image) in
                        guard let self = self, let image = image else { return }

                        self.cache.setObject(image, forKey: cacheString)
                    }
                }
            }
            DispatchQueue.main.async { () -> Void in
                self.CollectMovie.reloadData()
            }
            TodasLosGeneros(completion:{ resultado in
                self.generos = resultado
                DispatchQueue.main.async { () -> Void in
                    self.CollectGeneros.reloadData()
                }
            })
        }
    }
}

