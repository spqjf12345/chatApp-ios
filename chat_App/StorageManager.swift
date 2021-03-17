//
//  StorageManager.swift
//  chat_App
//
//  Created by JoSoJeong on 2021/03/09.
//

import Foundation
import FirebaseStorage

final class StorageManager {
    static let shared = StorageManager()
    private init(){}
    
    private let storage = Storage.storage().reference()
    
    public typealias UploadPictureCompletion = (Result<String, Error>) -> Void
    ///upload pictures to firebase storage and return completion with url string to download
    public func uplaodProfilePicture(with data: Data, fileName: String, completion: @escaping UploadPictureCompletion) {
        storage.child("images/\(fileName)").putData(data, metadata: nil, completion: {[weak self] metadata, error in
            guard let strongSelf = self else {
                            return
                        }
            guard error == nil else{
                //failed
                print("failed to upload data to firebase for picture")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            strongSelf.storage.child("images/\(fileName)").downloadURL(completion: {url, error in
                guard let url = url else{
                    print("failed to get download url")
                    completion(.failure(StorageErrors.failedToUpload))
                    return
                }
            
            let urlString = url.absoluteString
            print("download url returned: \(urlString)")
            completion(.success(urlString))
            })
        })
        
        
    }
    
    public enum StorageErrors: Error {
        case failedToUpload
        case failedToDownloadUrl
    }
    
    public func downloadURL(for path: String, completion: @escaping (Result<URL, Error>) -> Void) {
           let reference = storage.child(path)
        
           reference.downloadURL(completion: { url, error in
               guard let url = url, error == nil else {
                   completion(.failure(StorageErrors.failedToDownloadUrl))
                   return
               }

               completion(.success(url))
           })
       }
}
