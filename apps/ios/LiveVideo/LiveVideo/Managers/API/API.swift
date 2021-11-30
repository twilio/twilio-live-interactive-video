//
//  Copyright (C) 2021 Twilio, Inc.
//

import Alamofire
import Foundation

class API: ObservableObject {
    var backendURL: String!
    private let session = Session()
    private let jsonEncoder = JSONEncoder(keyEncodingStrategy: .convertToSnakeCase)
    private let jsonDecoder = JSONDecoder(keyDecodingStrategy: .convertFromSnakeCase)

    func request<Request: APIRequest>(
        _ request: Request,
        completion: ((Result<Request.Response, Error>) -> Void)? = nil
    ) {
        session.request(
            backendURL + "/" + request.path,
            method: .post, // Twilio Functions does not care about method
            parameters: request.parameters,
            encoder: JSONParameterEncoder(encoder: jsonEncoder),
            headers: [.authorization("passcode")]
        )
        .validate()
        .responseDecodable(of: request.responseType, decoder: jsonDecoder) { [weak self] response in
            guard let self = self else { return }
            
            switch response.result {
            case let .success(response):
                completion?(.success(response))
            case let .failure(error):
                guard
                    let data = response.data,
                    let errorResponse = try? self.jsonDecoder.decode(APIErrorResponse.self, from: data)
                else {
                    completion?(.failure(error))
                    return
                }

                completion?(.failure(LiveVideoError.backendError(message: errorResponse.error.explanation)))
            }
        }
    }
}
