//
//  ViewControllerPantallaDos.swift
//  ExamenMovie
//
//  Created by Isai Abraham on 12/09/22.
//

import UIKit
import UserNotifications
let notificacionisai = "com.Ejemplo.ExamenMovie"
class ViewControllerPantallaDos: UIViewController {

    @IBOutlet weak var DescripcionPeliculaEspecifica: UITextView!
    @IBOutlet weak var TituloPeliculaEspecifica: UILabel!
    @IBOutlet weak var ImagenPeliculasEspecifica: UIImageView!
    
    var peliDesgloce : Movies?
    
    private let cache = NSCache<NSString, UIImage>()
    private let utilityQueue = DispatchQueue.global(qos: .utility)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        TituloPeliculaEspecifica.text = peliDesgloce?.original_title
        DescripcionPeliculaEspecifica.text = peliDesgloce?.overview
        
        if let name = peliDesgloce?.poster_path {
            let imageName = "https://image.tmdb.org/t/p/original" + name
            let cacheString = NSString(string: imageName)
            
            if let cacheImage = self.cache.object(forKey: cacheString) {
                ImagenPeliculasEspecifica.image = cacheImage
            } else {
                self.loadImage(from: URL(string: imageName)) { [weak self] (image) in
                    guard let self = self, let image = image else { return }
                    self.ImagenPeliculasEspecifica.image = image
              
                    self.cache.setObject(image, forKey: cacheString)
                }
            }
        
        }
    }

    
    
    
    @IBAction func Alerta(_ sender: Any) {
       
       
        showAlert(message: peliDesgloce!.original_title)
        self.navigationController?.popViewController(animated: true)
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            if granted{
                let notificationConten = UNMutableNotificationContent()
                notificationConten.title = "La Pelicula comienza en 10 minutos"
                notificationConten.body = ("La pelicula es : "+self.peliDesgloce!.original_title)
                let date = Date().addingTimeInterval(30)
                let dateInFuture = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute,.second], from: date)
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateInFuture, repeats: true)
                let request = UNNotificationRequest(identifier: "com.Ejemplo.ExamenMovie", content: notificationConten, trigger: trigger)
                center.add(request) { (error) in
                    
                }

            }else{
                print("NO DIO ACCESO")
            }
            
        }
        
        NotificationCenter.default.addObserver( self,selector: #selector(notiEvent),name: NSNotification.Name(notificacionisai), object: nil)

        
        
    }
    
     func showAlert(message: String){
        let alert = UIAlertController(title: "Compraste boletos para: ", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ENTENDIDO", style: .default, handler: nil))
        present(alert,animated: true, completion: nil)
 
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
    @objc
    func notiEvent (notification: Notification){
        print("evento", notification)
        let valorDeLaNotificacion = notification.userInfo
        let user = valorDeLaNotificacion!["User"] as! User
        
        
        
    }
    
}
struct User {
    let id: Int
    let name : String
}
