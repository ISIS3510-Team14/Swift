//
//  RequestModel.swift
//  Request
//
//  Created by Herrera Alba Eduardo Jose on 27/09/24.
//

import Foundation
import UIKit



// Define the structures to represent the JSON body
struct MessageContent: Encodable {
    let type: String
    let text: String?
    let image_url: ImageURLContent?
}

struct ImageURLContent: Encodable {
    let url: String
}

struct Message: Encodable {
    let role: String
    let content: [MessageContent]
}

struct RequestBody: Encodable {
    let messages: [Message]
    let max_tokens: Int
}



// Estructuras para desempaquetar el JSON
struct ChatResponse: Codable {
    let choices: [Choice]
}

struct Choice: Codable {
    let contentFilterResults: ContentFilterResults
    let finishReason: String
    let index: Int
    let message: MessageResponse
    
    enum CodingKeys: String, CodingKey {
        case contentFilterResults = "content_filter_results"
        case finishReason = "finish_reason"
        case index, message
    }
}

struct ContentFilterResults: Codable {
    let hate, selfHarm, sexual, violence: FilterResult
    
    enum CodingKeys: String, CodingKey {
        case hate, selfHarm = "self_harm", sexual, violence
    }
}

struct FilterResult: Codable {
    let filtered: Bool
    let severity: String
}

struct MessageResponse: Codable {
    let content: String
    let role: String
}
