//
//  ContentView.swift
//  WordScramble
//
//  Created by kirsty darbyshire on 23/10/2019.
//  Copyright © 2019 kirsty darbyshire. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    @State private var results = [String]()
    
    var score: Int {
        var score = 0
        for word in usedWords {
            score += word.count
        }
        return score
    }
    
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                TextField("Enter your word:", text: $newWord, onCommit: addNewWord)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .padding()
                List(usedWords, id: \.self) {
                    // implicit HStack here :D
                    Image(systemName: "\($0.count).circle")
                    Text($0)
                }
                Text("Score: \(score)")
                    .font(.headline)
                Spacer()
                Text("Previously on WordScramble")
                    .font(.caption)
                List(results, id: \.self) {
                    Text( $0)
                }
            }
            .navigationBarTitle(rootWord)
            .onAppear(perform: startGame)
            .alert(isPresented: $showingError) {
                Alert(title: Text(errorTitle), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
            .navigationBarItems(trailing: Button(action: startGame) {
                Text("New Word?")
            })
        }
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard answer.count > 0 else { return }
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "You've already added \(answer)!")
            return
        }
        guard isPossible(word: answer) else {
            wordError(title: "Word impossible", message: "You can't make \(answer) from these letters!")
            return
        }
        guard isReal(word: answer) else {
            wordError(title: "What did you say?", message: "I don't think \(answer) is a real word!")
            return
        }
        
        usedWords.insert(answer, at: 0)
        newWord = ""
    }
    
    func startGame() {
        if rootWord != "" {
            results.insert("\(rootWord): \(score)", at: 0)
            usedWords = [String]()
        }
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "synonyms"
                return
            }
        }
        fatalError("Something went wrong loading the words to play the game.")
    }
    
    func isOriginal(word: String) -> Bool {
        return !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        for letter in word {
            if let position = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: position)
            } else {
                return false
            }
        }
        return true
    }
    
    func isReal(word: String) -> Bool {
        if word == rootWord { return false }
        if word.count < 3 { return false }
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspeltrange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspeltrange.location == NSNotFound
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
