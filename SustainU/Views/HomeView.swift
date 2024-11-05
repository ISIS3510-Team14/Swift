//
//  HomeView.swift
//  SustainU
//
//  Created by Duarte Mantilla Ernesto Jose on 29/10/24.
//

import SwiftUI
import Auth0

struct HomeView: View {
    var userProfile: UserProfile

    
    @StateObject private var connectivityManager = ConnectivityManager.shared

    @ObservedObject private var viewModel = LoginViewModel.shared

    @State private var selectedTab: Int = 0
    @State private var isShowingProfile = false
    @StateObject private var collectionPointViewModel = CollectionPointViewModel()

    var body: some View {
            ZStack {
                Color.white.edgesIgnoringSafeArea(.all)

                TabView(selection: $selectedTab) {
                    // Home Tab
                    NavigationView {
                        ScrollView {
                            VStack {
                                // Use the modified TopBarView
                                TopBarView(profilePictureURL: viewModel.userProfile.picture, connectivityManager: connectivityManager) {
                                    isShowingProfile = true
                                }
                            
                            // Greeting with first name
                            let firstName = viewModel.userProfile.name.components(separatedBy: " ").first ?? viewModel.userProfile.name
                            Text("Hi, \(firstName)")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .padding(.top, 10)

                            // Record section
                            VStack(alignment: .leading) {
                                Text("Your record")
                                    .font(.headline)
                                    .padding(.bottom, 2)

                                HStack {
                                    VStack(alignment: .leading) {
                                        Text("68 Points")
                                            .font(.title)
                                            .fontWeight(.bold)

                                        Text("99 Days")
                                            .font(.subheadline)
                                            .foregroundColor(Color("blueLogoColor"))
                                    }
                                    Spacer()
                                }
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(15)
                            .padding(.horizontal)

                            // Options grid
                            VStack(spacing: 20) {
                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                                    // Map Button
                                    Button(action: {
                                        selectedTab = 1
                                    }) {
                                        VStack {
                                            Image("logoMap")
                                                .resizable()
                                                .renderingMode(.template)
                                                .frame(width: 40, height: 40)
                                            Text("See green points")
                                                .font(.headline)
                                                .foregroundColor(.black)
                                        }
                                    }

                                    // Scoreboard Button
                                    Button(action: {
                                        selectedTab = 4
                                    }) {
                                        VStack {
                                            Image("logoScoreboard")
                                                .resizable()
                                                .renderingMode(.template)
                                                .frame(width: 40, height: 40)
                                            Text("See Scoreboard")
                                                .font(.headline)
                                                .foregroundColor(.black)
                                        }
                                    }

                                    // Recycle Button
                                    Button(action: {
                                        selectedTab = 3
                                    }) {
                                        VStack {
                                            Image("logoRecycle")
                                                .resizable()
                                                .renderingMode(.template)
                                                .frame(width: 40, height: 40)
                                            Text("What can I recycle?")
                                                .font(.headline)
                                                .foregroundColor(.black)
                                        }
                                    }

                                    // History Button
                                    Button(action: {
                                        // Action for History
                                    }) {
                                        VStack {
                                            Image(systemName: "calendar")
                                                .resizable()
                                                .frame(width: 40, height: 40)
                                            Text("History")
                                                .font(.headline)
                                                .foregroundColor(.black)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                            .padding(.top, 20)

                            Spacer()

                            Text("Start recycling!")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.bottom, 10)

                            Button(action: {
                                selectedTab = 2
                            }) {
                                Text("Scan")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(width: 220, height: 60)
                                    .background(Color("greenLogoColor"))
                                    .cornerRadius(15)
                            }
                            .padding(.bottom, 40)
                        }
                    }
                    .navigationBarHidden(true)
                }
                .tabItem {
                    Image("logoHome")
                        .renderingMode(.template)
                    Text("Home")
                }
                .tag(0)

                // Map Tab
                ExpandableSearchView(collectionPointViewModel: collectionPointViewModel, profilePictureURL: viewModel.userProfile.picture)
                    .tabItem {
                        Image("logoMap")
                            .renderingMode(.template)
                        Text("Map")
                    }
                    .tag(1)
                    .onAppear {
                        collectionPointViewModel.incrementMapCount()
                    }


                CameraView(profilePictureURL: viewModel.userProfile.picture, selectedTab: $selectedTab)
                    .tabItem {
                        Image("logoCamera")
                            .renderingMode(.template)
                        Text("Camera")
                    }
                    .tag(2)

                // Recycle Tab
                Text("Recycle View")
                    .tabItem {
                        Image("logoRecycle")
                            .renderingMode(.template)
                        Text("Recycle")
                    }
                    .tag(3)

                // Scoreboard Tab
                Text("Scoreboard View")
                    .tabItem {
                        Image("logoScoreboard")
                            .renderingMode(.template)
                        Text("Scoreboard")
                    }
                    .tag(4)
            }
            .accentColor(Color("greenLogoColor"))
            .onAppear {
                UITabBar.appearance().backgroundColor = .white
                UITabBar.appearance().unselectedItemTintColor = .gray
            }

            // Present the ProfileView as a sheet
            .sheet(isPresented: $isShowingProfile) {
                ProfileView(userProfile: viewModel.userProfile)
            }
        }
    }
}
