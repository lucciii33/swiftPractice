//
//  ViewController.swift
//  fetchTest
//
//  Created by Angelo on 10/18/23.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var textAvatar: UITextView!
    @IBOutlet weak var titleAvatar: UILabel!
    @IBOutlet weak var avatarImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        avatarImage.backgroundColor = .cyan
        avatarImage.layer.masksToBounds = true
        avatarImage.layer.cornerRadius = avatarImage.frame.height / 2
        
        Task {
                do {
                    let user = try await fetchUser()
                    print(user)
                    titleAvatar.text = user.login
                    textAvatar.text = user.bio
                    if let avatarURL = URL(string: user.avatarUrl) {
                        if let data = try? Data(contentsOf: avatarURL), let image = UIImage(data: data) {
                            DispatchQueue.main.async { [self] in
                                avatarImage.image = image
                                avatarImage.contentMode = .scaleAspectFill // Optional, adjust as needed
                                }
                            }
                        }
                    
                } catch {
                    print("Error fetching GitHub user data: \(error)")
                }
            }
       
    }

    func fetchUser() async throws -> GitHubUser{
        let endpoint =  "https://api.github.com/users/lucciii33"
        guard let url = URL(string: endpoint) else {
            throw GHError.invalidURL
        }
        let (data, response) =  try await URLSession.shared.data(from: url)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw GHError.invalidResponse
        }
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(GitHubUser.self, from: data)
        }
        catch{
            throw GHError.invalidData
        }
    }

}

struct GitHubUser: Codable {
    let login: String
    let avatarUrl: String
    let bio: String
}

enum GHError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
}
