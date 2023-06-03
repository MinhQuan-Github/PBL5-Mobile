//
//  DatabaseManager.swift
//  PBL5
//
//  Created by Minh Quan on 29/05/2023.
//

import UIKit
import SQLite3

class DBHelper {
    static let instance = DBHelper()
    
//    func getDocumentsDirectory() -> URL? {
//        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
//        return paths.first
//    }
//
//    func saveData(model: ResultModel) {
//        let encoder = JSONEncoder()
//
//        do {
//            let data = try encoder.encode(model)
//            if let fileURL = getDocumentsDirectory()?.appendingPathComponent("data.json") {
//                try data.write(to: fileURL)
//                print("Data saved successfully.")
//            }
//        } catch {
//            print("Failed to save data. Error: \(error.localizedDescription)")
//        }
//    }
//
//    func loadData(completion: @escaping([ResultModel]) -> (Void)) {
//        if let fileURL = getDocumentsDirectory()?.appendingPathComponent("data.json") {
//            do {
//                let data = try Data(contentsOf: fileURL)
//                let decoder = JSONDecoder()
//                let models = try decoder.decode([ResultModel].self, from: data)
//                completion(models)
//            } catch {
//                print("Failed to load data. Error: \(error.localizedDescription)")
//            }
//        }
//    }

//    func deleteData() {
//        if let fileURL = getDocumentsDirectory()?.appendingPathComponent("data.json") {
//            do {
//                try FileManager.default.removeItem(at: fileURL)
//                print("Data deleted successfully.")
//            } catch {
//                print("Failed to delete data. Error: \(error.localizedDescription)")
//            }
//        }
//    }
    
    func getDatabasePointer(databaseName: String) -> OpaquePointer? {
        var databasePointer: OpaquePointer?
        
        let documentDatabasePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(databaseName).path
        
        if FileManager.default.fileExists(atPath: documentDatabasePath) {
            print("OK")
        } else {
            guard let bundleDatabasePath = Bundle.main.resourceURL?.appendingPathComponent(databaseName).path else {
                print("Bundle not exist")
                return nil
            }
            
            do {
                try FileManager.default.copyItem(atPath: bundleDatabasePath, toPath: documentDatabasePath)
                print("Database copied")
            } catch {
                print("\(error.localizedDescription)")
                return nil
            }
        }
        
        if sqlite3_open(documentDatabasePath, &databasePointer) == SQLITE_OK {
            print("successfully open database")
            print("Database path: \(documentDatabasePath)")
        } else {
            print("Could not open database")
        }
        
        return databasePointer
    }
    
//    func insertData(resultModel: ResultModel) {
//        let insertQuery = "INSERT INTO ResultModel (image, result) VALUES (?, ?)"
//
//        var statement: OpaquePointer?
//
//        if sqlite3_prepare_v2(databasePointer, insertQuery, -1, &statement, nil) == SQLITE_OK {
//            sqlite3_bind_text(statement, 1, resultModel.image, -1, nil)
//            sqlite3_bind_text(statement, 2, resultModel.result, -1, nil)
//
//            if sqlite3_step(statement) == SQLITE_DONE {
//                print("Data inserted successfully")
//            } else {
//                print("Data insertion failed")
//            }
//        }
//
//        sqlite3_finalize(statement)
//    }
    
    let SQLITE_TRANSIENT = unsafeBitCast(OpaquePointer(bitPattern: -1), to: sqlite3_destructor_type.self)
    
    func insertData(resultModel: ResultModel) {
            let insertQuery = "INSERT INTO ResultModel (image, result) VALUES (?, ?)"
            
            var statement: OpaquePointer?
            
            if sqlite3_prepare_v2(databasePointer, insertQuery, -1, &statement, nil) == SQLITE_OK {
                if let imageData = decodeBase64Image(base64String: resultModel.image)!.pngData() {
                    imageData.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) in
                        sqlite3_bind_blob(statement, 1, bytes.baseAddress, Int32(imageData.count), SQLITE_TRANSIENT)
                    }
//                    sqlite3_bind_blob(statement, 1, imageData.bytes, Int32(imageData.count), SQLITE_TRANSIENT)
                }
                sqlite3_bind_text(statement, 2, resultModel.result, -1, nil)
                
                if sqlite3_step(statement) == SQLITE_DONE {
                    print("Data inserted successfully")
                } else {
                    print("Data insertion failed")
                }
            }
            
            sqlite3_finalize(statement)
        }
    
//    func readData() -> [ResultModel] {
//        var resultModels = [ResultModel]()
//        let selectQuery = "SELECT * FROM ResultModel"
//
//        var statement: OpaquePointer?
//
//        if sqlite3_prepare_v2(databasePointer, selectQuery, -1, &statement, nil) == SQLITE_OK {
//            while sqlite3_step(statement) == SQLITE_ROW {
//                let image = String(cString: sqlite3_column_text(statement, 0))
//                let result = String(cString: sqlite3_column_text(statement, 1))
//
//                let resultModel = ResultModel(image: image, result: result)
//                resultModels.append(resultModel)
//            }
//        }
//
//        sqlite3_finalize(statement)
//
//        return resultModels
//    }
    
    func readData() -> [ResultModel] {
            var resultModels = [ResultModel]()
            let selectQuery = "SELECT image, result FROM ResultModel"
            
            var statement: OpaquePointer?
            
            if sqlite3_prepare_v2(databasePointer, selectQuery, -1, &statement, nil) == SQLITE_OK {
                while sqlite3_step(statement) == SQLITE_ROW {
                    if let imageBlob = sqlite3_column_blob(statement, 0) {
                        let imageBytes = sqlite3_column_bytes(statement, 0)
                        let imageData = Data(bytes: imageBlob, count: Int(imageBytes))
                        let image = UIImage(data: imageData)
                        
                        let result = String(cString: sqlite3_column_text(statement, 1))
                        
                        let resultModel = ResultModel(image: encodeImageToBase64(image: image!), result: result)
                        resultModels.append(resultModel)
                    }
                }
            }
            
            sqlite3_finalize(statement)
            
            return resultModels
        }
    
    func updateData(resultModel: ResultModel) {
        let updateQuery = "UPDATE ResultModel SET image = ? WHERE result = ?"
        
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(databasePointer, updateQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, resultModel.image, -1, nil)
            sqlite3_bind_text(statement, 2, resultModel.result, -1, nil)
            
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Data updated successfully")
            } else {
                print("Data update failed")
            }
        }
        
        sqlite3_finalize(statement)
    }
    
    func deleteData(resultModel: ResultModel) {
        let deleteQuery = "DELETE FROM ResultModel WHERE result = ?"
        
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(databasePointer, deleteQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, resultModel.result, -1, nil)
            
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Data deleted successfully")
            } else {
                print("Data deletion failed")
            }
        }
        
        sqlite3_finalize(statement)
    }

}

