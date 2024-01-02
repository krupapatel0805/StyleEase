import Foundation
import CoreLocation

struct UserDefaultsKeys {
    static let email = "email"
    static let name = "name"
    static let address = "address"
    static let userId = "userId"
    static let latitude = "latitude"
    static let longitude = "longitude"
    static let city = "city"
    static let country = "country"
    static let manualLocation = "manualLocation"
    static let totalBalance = "totalBalance"
    
}

class AppUtility: NSObject, ObservableObject {
     
    override init() {
        super.init()
        email = UserDefaults.standard.object(forKey: UserDefaultsKeys.email) as? String
        name = UserDefaults.standard.object(forKey: UserDefaultsKeys.name) as? String
    }
    
    static let shared = AppUtility()
    
    var email: String? {
        didSet {
            UserDefaults.standard.set(self.email, forKey: UserDefaultsKeys.email)
        }
    }
    
    var name: String? {
        didSet {
            UserDefaults.standard.set(self.name, forKey: UserDefaultsKeys.name)
        }
    }
    
    var userId: String? {
        didSet {
            UserDefaults.standard.set(self.userId, forKey: UserDefaultsKeys.userId)
        }
    }
    
    var latitude: String? {
        didSet {
            UserDefaults.standard.set(self.latitude, forKey: UserDefaultsKeys.latitude)
        }
    }
    
    var longitude: String? {
        didSet {
            UserDefaults.standard.set(self.longitude, forKey: UserDefaultsKeys.longitude)
        }
    }
    
    var city: String? {
        didSet {
            UserDefaults.standard.set(self.city, forKey: UserDefaultsKeys.city)
        }
    }
    
    var country: String? {
        didSet {
            UserDefaults.standard.set(self.country, forKey: UserDefaultsKeys.country)
        }
    }
    var manualLocation: String? {
        didSet {
            UserDefaults.standard.set(self.manualLocation, forKey: UserDefaultsKeys.manualLocation)
        }
    }
    var totalBalance: Int? {
        didSet {
            UserDefaults.standard.set(self.totalBalance, forKey: UserDefaultsKeys.totalBalance)
        }
    }
}

