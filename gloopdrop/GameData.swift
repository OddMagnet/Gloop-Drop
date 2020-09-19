//
//  GameData.swift
//  gloopdrop
//
//  Created by Michael Brünen on 17.09.20.
//  Copyright © 2020 Michael Brünen. All rights reserved.
//

import Foundation

class GameData: NSObject, Codable {
    // MARK: - Properties
    let saveDataFileName = "gamedata.json"
    var freeContinues: Int = 1 {
        didSet {
            saveDataWithFileName(saveDataFileName)
        }
    }

    static let shared: GameData = {
        let instance = GameData()
        instance.setUpObservers()
        return instance
    }()

    // MARK: - Init
    private override init() {}

    // MARK: - Notification Handlers
    func setUpObservers() {
        // TODO: Add observers
    }
    
    // MARK: - Save and load locally stored data
    /// Saves the game data
    /// - Parameter filename: the name under which the data is saved
    func saveDataWithFileName(_ filename: String) {
        let fullPath = getDocumentsDirectory().appendingPathComponent(filename)

        do {
            let data = try PropertyListEncoder().encode(self)
            let dataFile = try NSKeyedArchiver.archivedData(withRootObject: data,
                                                            requiringSecureCoding: true)
            try dataFile.write(to: fullPath)
        } catch {
            print("Couldn't write game data")
        }
    }

    /// Loads the game data
    /// - Parameter filename: the name of the file to load
    func loadDataWithFileName(_ filename: String) {
        let fullPath = getDocumentsDirectory().appendingPathComponent(filename)

        do {
            let contents = try Data(contentsOf: fullPath)
            if let data = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(contents) as? Data {
                let gameData = try PropertyListDecoder().decode(GameData.self, from: data)

                freeContinues = gameData.freeContinues
            }
        } catch {
            print("Couldn't load game data")
        }
    }

    // MARK: - Helper
    /// Returns the URL of the users documents directory
    /// - Returns: the URL of the users documents directory
    fileprivate func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory,
                                             in: .userDomainMask)
        return paths[0]
    }

}
