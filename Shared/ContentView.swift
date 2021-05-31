//
//  ContentView.swift
//  Shared
//
//  Created by Firat Sülünkü on 31.05.21.
//

import SwiftUI

struct ContentView: View {
    @State var showSettings = false
    @State var isBusy = false
    
    @AppStorage("ESP_IP") var esp_ip: String = ""
    @AppStorage("Port") var esp_port: String = ""
    
    var body: some View {
        NavigationView {
            VStack
            {
                if esp_ip.isEmpty || esp_port.isEmpty
                {
                    changeSettings
                }
                else
                {
                    control
                }
            }
            .disabled(isBusy)
            .overlay(
                Group
                {
                    if isBusy
                    {
                        VStack
                        {
                            ProgressView()
                        }
                        .padding(30)
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(20)
                    }
                }
            )
            .navigationTitle(Text("Fernsteuerung"))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing)
                {
                    Button(action: {
                        showSettings.toggle()
                    }, label: {
                        Image(systemName: "gear")
                    })
                }
            }
            .sheet(isPresented: $showSettings)
            {
                SettingsView()
            }
        }
    }
    var changeSettings: some View
    {
        Text("Bitte die IP in den Einstellungen eingeben")
            .foregroundColor(.gray)
    }
    var control: some View
    {
        Group
        {
            Button(action: {
                openUrl("socket0Send")
            }, label: {
                Image(systemName: "power")
            })
            Button(action: {
                openUrl("socket1Send")
            }, label: {
                Image(systemName: "sun.max")
            })
            Button(action: {
                openUrl("socket2Send")
            }, label: {
                Image(systemName: "sun.min")
            })
            Button(action: {
                openUrl("socket3Send")
            }, label: {
                Image(systemName: "dial.max")
            })
        }
        .buttonStyle(FilledButton())
    }
    func openUrl(_ subdirectory: String)
    {
        var prefix = ""
        var suffix = ""
        switch esp_port {
            case "80":
                prefix = "http://"
            case "443":
                prefix = "https://"
            default:
                suffix = ":\(esp_port)"
                break
        }
        
        if let url = URL(string: "\(prefix)\(esp_ip)\(suffix)/\(subdirectory)")
        {
            isBusy = true
            DispatchQueue.main.async {
                let configuration = URLSessionConfiguration.default
                configuration.timeoutIntervalForRequest = TimeInterval(15)
                configuration.timeoutIntervalForResource = TimeInterval(15)
                let session = URLSession(configuration: configuration)
                
                let task = session.dataTask(with: url) {(data, response, error) in
                    isBusy = false
                    guard let data = data else { return }
                    print(String(data: data, encoding: .utf8)!)
                }
                
                task.resume()
            }
        }
    }
}

struct FilledButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
            .padding()
            .scaleEffect(configuration.isPressed ? 1.02 : 0.98)
            .font(.title)
            .background(configuration.isPressed ? Color.gray.opacity(0.3) : Color.white)
            .cornerRadius(100)
            .foregroundColor(configuration.isPressed ? .accentColor.opacity(0.8) : .accentColor)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.05)
    }
}

struct SettingsView: View
{
    @Environment(\.presentationMode) var presentationMode
    @State var espIp = ""
    @State var espPort = ""
    @AppStorage("ESP_IP") var esp_ip: String = ""
    @AppStorage("Port") var esp_port: String = ""

    var body: some View
    {
        NavigationView {
            Form
            {
                Section(header: Label("Verbindung", systemImage: "wifi"))
                {
                    HStack
                    {
                        Text("IP")
                        TextField("192.168.0.2", text: $espIp)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack
                    {
                        Text("Port")
                        TextField("80", text: $espPort)
                            .multilineTextAlignment(.trailing)
                    }
                }
            }
            .navigationTitle(Text("Einstellungen"))
            .onAppear
            {
                if !espIp.isEmpty
                {
                    espIp = esp_ip
                }
                if !espPort.isEmpty
                {
                    espPort = esp_port
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing)
                {
                    Button(action: {
                        if !espIp.isEmpty
                        {
                            esp_ip = espIp
                        }
                        if !espPort.isEmpty
                        {
                            esp_port = espPort
                        }
                        presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Text("Speichern")
                    })
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
        SettingsView()
    }
}
