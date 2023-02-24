//
//  ContentView.swift
//  Demo
//
//  Created by nate parrott on 2/23/23.
//

import SwiftUI
import OpenAIStreamingCompletions

struct ContentView: View {
    @State private var prompt = "internet explorer is"
    @State private var completion: StreamingCompletion?

    var body: some View {
        ScrollView {
            VStack {
                TextField("Prompt to complete", text: $prompt, onCommit: complete)
                Button("Complete", action: complete)
                if let completion {
                    Divider()
                    CompletionView(completion: completion)
                        .padding(.top)
                }
                Spacer()
            }
            .padding(30)
        }
    }

    private func complete() {
        self.completion = try! OpenAIAPI(apiKey: "TODO").completeStreaming(.init(prompt: prompt, max_tokens: 256))
    }
}

private struct CompletionView: View {
    @ObservedObject var completion: StreamingCompletion

    var body: some View {
        VStack(alignment: .leading) {
            Text("\(completion.text)")
                .multilineTextAlignment(.leading)
                .lineLimit(nil)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
