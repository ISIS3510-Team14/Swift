import Foundation
import UIKit


class RequestService {
    let apiEndpoint = APIConfig.apiEndpoint
    let apiKey = APIConfig.apiKey
    
    
     func sendRequest(prompt: String, photoBase64: String, completion: @escaping (String?) -> Void) {
                  
         print("sendRequest")
         let url_string = "https://\(apiEndpoint)/openai/deployments/gpt-4o/chat/completions?api-version=2024-02-01&api-key=\(apiKey)"
        guard let url = URL(string: url_string) else {
            print("Invalid URL")
            return
        }
         

        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
         
         
         // Create the message content
         let textContent = MessageContent(type: "text", text: prompt, image_url: nil)
         let imageURLContent = MessageContent(type: "image_url", text: nil, image_url: ImageURLContent(url: "data:image/png;base64,\(photoBase64)"))

         // Create the message
         let message = Message(role: "user", content: [textContent, imageURLContent])

         // Create the request body
         let requestBody = RequestBody(messages: [message], max_tokens: 100)

         // Encode the request body into JSON format and add it to the request
         do {
             let jsonData = try JSONEncoder().encode(requestBody)
             request.httpBody = jsonData // Set the HTTP body to the encoded JSON data
             
             // Make the request
             let task = URLSession.shared.dataTask(with: request) { data, response, error in
                 if let error = error {
                     print("Error making the request: \(error)")
                     return
                 }
                 
                 if let httpResponse = response as? HTTPURLResponse {
                     let statusCode = httpResponse.statusCode
                     if (200...299).contains(statusCode) {
                         //
                     } else {
                         print("Request failed, status code: \(statusCode)")
                     }
                 }
                 
                 if let data = data {
                     do {
                         // Decodifica la respuesta JSON
                         let chatResponse = try JSONDecoder().decode(ChatResponse.self, from: data)
                         
                         // Accede al contenido del mensaje
                         if let messageContent = chatResponse.choices.first?.message.content {
                             //print("Respuesta del asistente: \(messageContent)")
                             completion(messageContent)  // Llama a la función de completion con el contenido
                         }
                     } catch {
                         print("Error al decodificar la respuesta JSON: \(error)")
                     }
                 }
                 
                 
             }
             
             task.resume() // Start the request
         } catch {
             print("Error encoding JSON: \(error)")
         }
    print("fin sendRequest")
    } // fin sendRequest
}
