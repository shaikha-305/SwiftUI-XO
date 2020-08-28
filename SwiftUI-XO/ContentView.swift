//
//  ContentView.swift
//  SwiftUI-XO
//
//  Created by shaikha aljenaidel on 8/27/20.
//  Copyright © 2020 shaikha aljenaidel. All rights reserved.
//

import SwiftUI
import AVFoundation

enum Choice{
    case X, O, none
    
    var title: String{
        switch self{
        case .X: return "X"
        case .O: return "O"
        case .none: return ""
        }
    }
    
    mutating func toggle(){
        switch self{
        case .X: self = .O
        case .O: self = .X
        case .none: self = .none
        }
    }
}
struct Player {
    var enabled: Bool
    var title: Choice
}

class Env: ObservableObject{
    @Published var currentPlayer: Choice = .X
    @Published var fields: [[Player]] = Array<Array<Player>>(repeating: Array<Player>(repeating: Player(enabled: true, title: .none), count: 3), count: 3)
    @Published var winner: Choice = .none
    @Published var thereIsWinner: Bool = false
    
    private func checkWinner(choice: Choice) -> Choice{
        let r1 = fields[0][0].title == choice && fields[0][1].title == choice && fields[0][2].title == choice
        let r2 = fields[1][0].title == choice && fields[1][1].title == choice && fields[1][2].title == choice
        let r3 = fields[2][0].title == choice && fields[2][1].title == choice && fields[2][2].title == choice
        
        let c1 = fields[0][0].title == choice && fields[1][0].title == choice && fields[2][0].title == choice
        let c2 = fields[0][1].title == choice && fields[1][1].title == choice && fields[2][1].title == choice
        let c3 = fields[0][2].title == choice && fields[1][2].title == choice && fields[2][2].title == choice
        
        let d1 = fields[0][0].title == choice && fields[1][1].title == choice && fields[2][2].title == choice
        let d2 = fields[0][2].title == choice && fields[1][1].title == choice && fields[2][0].title == choice
        
        if r1 || r2 || r3 || c1 || c2 || c3 || d1 || d2{
            return choice
        }else {
            return .none
        }
    }
    
    func checkWinner(){
        winner = checkWinner(choice: currentPlayer)
        
        if winner != .none{
            thereIsWinner = true
        }
    }
}
struct ContentView: View {
    @EnvironmentObject var env: Env
    @State var iconName: Image = Image(systemName: "speaker.slash")
    @State private var sound = true
    @State var bgSound: AVAudioPlayer?
    var body: some View {
        
        ZStack{
            Image("XO-BG")
            XOGrid()
            ZStack{
                Image(systemName: sound ? "speaker.slash" : "speaker")
                    .resizable()
                    .frame(width: 35, height: 35)
                    .foregroundColor(.black)
                    .offset(x: 150, y: -370)
                    .onTapGesture {
                        self.sound.toggle()
                        if self.sound == false{
                            let path = Bundle.main.path(forResource: "backgroundSound.mp3", ofType:nil)!
                            let url = URL(fileURLWithPath: path)
                            
                            do {
                                self.bgSound = try AVAudioPlayer(contentsOf: url)
                                self.bgSound?.play()
                            } catch {
                                // couldn't load file :(
                            }
                        }else if self.sound == true{
                                let path = Bundle.main.path(forResource: "backgroundSound.mp3", ofType:nil)!
                                let url = URL(fileURLWithPath: path)
                                
                                do {
                                    self.bgSound = try AVAudioPlayer(contentsOf: url)
                                    self.bgSound?.stop()
                                } catch {
                                    // couldn't load file :(
                            }
                        }
                }
            }
        }.alert(isPresented: $env.thereIsWinner) { () -> Alert in
            Alert(title: Text("\(self.env.winner.title) Won!"), message: Text("tap restart if you want to play again!"), dismissButton: .default(Text("restart"), action: {
                self.env.fields = Array<Array<Player>>(repeating: Array<Player>(repeating: Player(enabled: true, title: .none), count: 3), count: 3)
                self.env.winner = .none
                self.env.thereIsWinner = false
                self.env.currentPlayer = .X
            }))
        }
    }
    }

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(Env())
    }
}


struct XOGrid: View {
    @EnvironmentObject var env: Env
    var body: some View {
        VStack(spacing: 10){
            Text("\(self.env.currentPlayer.title) turn")
                .bold()
                .font(.system(size: 60))
                .padding()
                .offset(x: 0, y: -100)
            ForEach(0 ..< 3, id: \.self){ c in
                HStack(spacing: 10){
                    ForEach(0 ..< 3, id: \.self){ r in
                        XOButton(c: c, r: r)
                    }
                }
            }
        }.offset(x: 0, y: -60)
    }
}

struct XOButton: View {
    @EnvironmentObject var env: Env
    @State var c: Int
    @State var r: Int
    
    var body: some View {
        
        Text(env.fields[c][r].title.title)
            .bold()
            .foregroundColor(.white)
            .font(.system(size: 55))
            .frame(width: 80, height: 80)
            .background(Color(#colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 0.7908505722)))
            .cornerRadius(7)
            .onTapGesture {
                if self.env.fields[self.c][self.r].enabled {
                    self.env.fields[self.c][self.r].title = self.env.currentPlayer
                    self.env.checkWinner()
                    self.env.currentPlayer.toggle()
                    self.env.fields[self.c][self.r].enabled = false
                }
        }
    }
}
