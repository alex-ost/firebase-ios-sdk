// Copyright 2020 Google
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

@testable import FirebaseCore
@testable import FirebaseStorage
import XCTest

class StorageIntegration: XCTestCase {
  var app: FirebaseApp?
  var storage: Storage?

  override class func setUp() {
    FirebaseApp.configure()
  }

  override func setUp() {
    app = FirebaseApp.app()
    storage = Storage.storage(app: app!)
//    let setupExpectation = self.expectation(description: "foo")
  }

  func testName() {
    guard let app = app else {
      XCTFail()
      return
    }
    let aGS = app.options.projectID
    let aGSURI = "gs://\(aGS!).appspot.com/path/to"
    let ref = storage?.reference(forURL: aGSURI)
    XCTAssertEqual(ref?.description, aGSURI)
  }

  func testUnauthenticatedGetMetadata() {
    let expectation = self.expectation(description: "testUnauthenticatedGetMetadata")
    let ref = storage?.reference().child("ios/public/1mb")
    ref?.getMetadata(completion: { (metadata, error) -> Void in
      XCTAssertNotNil(metadata, "Metadata should not be nil")
      XCTAssertNil(error, "Error should be nil")
      expectation.fulfill()
    })
    waitForExpectations()
  }

  func testUnauthenticatedUpdateMetadata() {
    let expectation = self.expectation(description: "testUnauthenticatedUpdateMetadata")

    let meta = StorageMetadata()
    meta.contentType = "lol/custom"
    meta.customMetadata = ["lol": "custom metadata is neat",
                           "ちかてつ": "🚇",
                           "shinkansen": "新幹線"]

    let ref = storage?.reference(withPath: "ios/public/1mb")
    ref?.updateMetadata(meta, completion: { metadata, error in
      XCTAssertEqual(meta.contentType, metadata!.contentType)
      XCTAssertEqual(meta.customMetadata!["lol"], metadata?.customMetadata!["lol"])
      XCTAssertEqual(meta.customMetadata!["ちかてつ"], metadata?.customMetadata!["ちかてつ"])
      XCTAssertEqual(meta.customMetadata!["shinkansen"],
                     metadata?.customMetadata!["shinkansen"])
      XCTAssertNil(error, "Error should be nil")
      expectation.fulfill()
    })
    waitForExpectations()
  }

  func testUnauthenticatedDelete() {
    let expectation = self.expectation(description: "testUnauthenticatedDelete")
    let ref = storage?.reference(withPath: "ios/public/fileToDelete")
    guard let data = "Delete me!!!!!!".data(using: .utf8) else {
      XCTFail()
      return
    }
    ref?.putData(data, metadata: nil, completion: { metadata, error in
      XCTAssertNotNil(metadata, "Metadata should not be nil")
      XCTAssertNil(error, "Error should be nil")
      ref?.delete(completion: { error in
        XCTAssertNil(error, "Error should be nil")
        expectation.fulfill()
      })
    })
    waitForExpectations()
  }

  func testDeleteWithNilCompletion() {
    let expectation = self.expectation(description: "testDeleteWithNilCompletion")
    let ref = storage?.reference(withPath: "ios/public/fileToDelete")
    guard let data = "Delete me!!!!!!".data(using: .utf8) else {
      XCTFail()
      return
    }
    ref?.putData(data, metadata: nil, completion: { metadata, error in
      XCTAssertNotNil(metadata, "Metadata should not be nil")
      XCTAssertNil(error, "Error should be nil")
      ref?.delete(completion: nil)
      expectation.fulfill()
    })
    waitForExpectations()
  }

  func testUnauthenticatedSimplePutData() {
    let expectation = self.expectation(description: "testUnauthenticatedSimplePutData")
    let ref = storage?.reference(withPath: "ios/public/testBytesUpload")
    guard let data = "Hello Swift World".data(using: .utf8) else {
      XCTFail()
      return
    }
    ref?.putData(data, metadata: nil, completion: { metadata, error in
      XCTAssertNotNil(metadata, "Metadata should not be nil")
      XCTAssertNil(error, "Error should be nil")
      expectation.fulfill()
    })
    waitForExpectations()
  }

  func testUnauthenticatedSimplePutSpecialCharacter() {
    let expectation = self.expectation(description: "testUnauthenticatedSimplePutSpecialCharacter")
    let ref = storage?.reference(withPath: "ios/public/-._~!$'()*,=:@&+;")
    guard let data = "Hello Swift World".data(using: .utf8) else {
      XCTFail()
      return
    }
    ref?.putData(data, metadata: nil, completion: { metadata, error in
      XCTAssertNotNil(metadata, "Metadata should not be nil")
      XCTAssertNil(error, "Error should be nil")
      expectation.fulfill()
    })
    waitForExpectations()
  }

  private func waitForExpectations() {
    let kFIRStorageIntegrationTestTimeout = 60.0
    waitForExpectations(timeout: kFIRStorageIntegrationTestTimeout,
                        handler: { (error) -> Void in
                          if let error = error {
                            print(error)
                          }
    })
  }
}