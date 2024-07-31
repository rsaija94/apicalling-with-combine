//
//  ContentView.swift
//  SwiftUiApiCallingWithCombine
//
//  Created by mind on 28/03/24.
//

import SwiftUI
import Combine

struct ContentView: View {
    @ObservedObject var movieListFetch = MovieListFetch()
    
    var body: some View {
        ScrollView{
        VStack {
                ForEach(movieListFetch.movies,id: \.id) { data in
                    HStack(spacing:0) {
                        VStack(spacing:0) {
                            AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/w200/\(data.poster_path!)"))
                                .frame(width: 150,height: 150).cornerRadius(20.0)
                            
                            
                            Spacer()
                        }.padding(.all,10)
                        
                        VStack(alignment:.leading,spacing:10) {
                            Text(data.title ?? "")
                                .fontWeight(.heavy)
                             
                            
                               
                            Text(data.release_date ?? "").fontWeight(.medium)
                            
                            
                            Text(data.overview ?? "").frame(height: .infinity)
                            
                            Spacer()
                        }.padding(.all,10)
                        
                        Spacer()
                    }
                    .background(.gray.opacity(0.2))
                    .cornerRadius(20)
                    .padding()
                    

                
                        
                }
            }
        .onAppear {
                movieListFetch.fetchMovies(movieRequest: MovieModelRequest(apiKey: "cabad2aec441a0507a3243203eab9d8"))
            }
        }
       
    }
}

#Preview {
    ContentView()
}
