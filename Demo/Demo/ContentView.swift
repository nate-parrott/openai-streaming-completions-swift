//
//  ContentView.swift
//  Demo
//
//  Created by nate parrott on 2/23/23.
//

import SwiftUI
import OpenAIStreamingCompletions

struct ContentView: View {
    @State private var prompt = "what is internet explorer"
    @State private var completion: StreamingCompletion?
    @State private var completedText: String = ""
    @AppStorage("key") private var key = ""

    var body: some View {
        Form {
            Section {
                TextField("API key", text: $key)
                TextField("Prompt to complete", text: $prompt, onCommit: complete)
                Button("Complete Text", action: complete)
                Button("Complete Chat", action: completeChat)
            }
            if let completion {
                Section {
                    CompletionView(completion: completion)
                }
            }
            if completedText != "" {
                Section {
                    Text(completedText)
                }
            }
        }
    }

    private func complete() {
        if key == "" { return }
        self.completion = try! OpenAIAPI(apiKey: key).completeStreaming(.init(prompt: prompt, max_tokens: 256))
    }

    private func completeChat() {
        if key == "" { return }
        let messages: [OpenAIAPI.Message] = [
            .init(role: .system, content: "You are a helpful assistant. Answer in one sentence if possible."),
            .init(role: .user, content: prompt)
        ]
//        Task {
//            do {
//                self.completedText = try await OpenAIAPI(apiKey: key).completeChat(.init(messages: messages))
//            } catch {
//                self.completedText = "Error: \(error)"
//            }
//        }
        self.completion = try! OpenAIAPI(apiKey: key).completeChatStreamingWithObservableObject(.init(messages: messages))
    }
}

private struct CompletionView: View {
    @ObservedObject var completion: StreamingCompletion

    var body: some View {
        Group {
            Text("\(completion.text)")
                .multilineTextAlignment(.leading)
                .lineLimit(nil)
        }
        switch completion.status {
        case .error: Text("Errror")
        case .complete: Text("Complete")
        case .loading: Text("Loading")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
