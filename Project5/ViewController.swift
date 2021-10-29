//
//  ViewController.swift
//  Project5
//
//  Created by Juan Felipe Zorrilla Ocampo on 30/09/21.
//

import UIKit

class ViewController: UITableViewController {
    // Define empty strings to store the initial words and the ones created by the user
    var allWords = [String]()
    var usedWords = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Define a plus button for the user to provide an answer calling a class method
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(startGame))
        // Load the words from a txt file located in filesystem
        // First we're getting and unwrapping the path location to the start.txt file
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            // Second, If we get a location path back then we can try to get the content of the start.txt file
            if let startWords = try? String(contentsOf: startWordsURL) {
                // Last, if we get the start.txt content back we will convert it from String to an Array of Strings using below method
                allWords = startWords.components(separatedBy: "\n")
            }
        }
        
        if allWords.isEmpty {
            allWords = ["silkworm"]
        }
        
        startGame()
        
    }
    // Below method will get called everytime we run the app again
    @objc func startGame() {
        // Set the title to be a new random element from the data source array
        title = allWords.randomElement()
        // Reset the TableViewController content
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]
        return cell
    }
    // Method will be called when user tap on the "plus" icon to provide an answer
    @objc func promptForAnswer() {
        // Create an Alert Controller and add a text field inside it
        let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        ac.addTextField()
        // Add the "Submit" option to the UIAlertController and its correspondent code to execute as a trailing closure
        // The closure weakly stores the self and ac to prevent strong references between the closure of the UIAlertController and the ViewController
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [weak self, weak ac] action in
            guard let answer = ac?.textFields?[0].text else { return }
            self?.submit(answer)
        }
        // Add the "Submit" option to the UIAlertController and present it on screen
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    
    func submit(_ answer: String) {
        // Avoid case sensitive in strings
        let lowerAnswer = answer.lowercased()
        
        // Nested if statements to validate the word is possible, the word hasn't been used yet, and the word is a real word
        if isPossible(word: lowerAnswer) {
            if isOriginal(word: lowerAnswer) {
                if isReal(word: lowerAnswer) {
                    usedWords.insert(answer, at: 0)
                    // Insert the new row with the word at the top of the UITableViewController
                    let indexPath = IndexPath(row: 0, section: 0)
                    tableView.insertRows(at: [indexPath], with: .automatic)
                    
                    return
                } else {
                    showErrorMessage(errorTitle: "Word not recognised", errorMessage: "You can't just make them up, you know!")
                }
            } else {
                showErrorMessage(errorTitle: "Word used already", errorMessage: "Be more original!")
            }
        } else {
            guard let title = title?.lowercased() else { return }
            showErrorMessage(errorTitle: "Word not possible", errorMessage: "You can't spell that word from \(title)")
        }
    }
    
    func isPossible(word: String) -> Bool {
        // Store the tempWord variable based on the title of the UITableViewController
        guard var tempWord = title?.lowercased() else { return true }
        // Loop trhough each letter of input word and check whether the letter exists or not and remove it from the tempWord var
        for letter in word {
            if let position = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: position)
            } else {
                return false
            }
        }
        // this line is reached only if every letter in the user's word was found in the start word no more than once
        return true
    }
    
    func isOriginal(word: String) -> Bool {
        return !usedWords.contains(word)
    }
    
    func isReal(word: String) -> Bool {
        if word.utf16.count < 3 {
            showErrorMessage(errorTitle: "Short word", errorMessage: "Word can't be lees than 3 letters")
            return false
        } else if word == title {
            showErrorMessage(errorTitle: "Repeated title", errorMessage: "Word can't be the same as the title")
            return false
        } else {
            let checker = UITextChecker()
            let range = NSRange(location: 0, length: word.utf16.count)
            let mispelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
            
            return mispelledRange.location == NSNotFound
        }
    }
    
    func showErrorMessage(errorTitle: String, errorMessage: String) {
        let ac = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
}

