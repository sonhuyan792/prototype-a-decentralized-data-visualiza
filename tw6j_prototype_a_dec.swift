import SwiftUI
import Web3

// Configuration
struct Config {
    let nodeName: String = "Tw6j Prototype Node"
    let ethereumNetwork: String = "rinkeby"
    let contractAddress: String = "0x742d35Cc6634C0532925a3b844Bc454e4438f44e"
    let abi: [String] = [
        "function trackData(string memory _data) public",
        "function getData() public view returns (string memory)"
    ]
}

// Data Model
struct DataPoint: Identifiable {
    let id = UUID()
    var timestamp: Date
    var data: String
}

// Decentralized Tracker
class DecentralizedTracker {
    let web3: Web3
    let contract: Web3.Contract
    
    init() {
        web3 = Web3(rpcUrl: "https://\(Config().ethereumNetwork).infura.io/v3/YOUR_PROJECT_ID")
        contract = web3.contract(Config().contractAddress, abi: Config().abi)
    }
    
    func trackData(_ data: String) {
        contract.call("trackData", args: [data], options: [.gasLimit: 200000])
    }
    
    func getData() -> [DataPoint] {
        let response = contract.call("getData", args: [], options: [.gasLimit: 200000])
        let dataString = response.returnValue as? String ?? ""
        return dataString.components(separatedBy: ",").map { DataPoint(timestamp: Date(), data: $0) }
    }
}

// Data Visualization
struct DataVisualization: View {
    @StateObject var tracker = DecentralizedTracker()
    @State var dataPoints: [DataPoint] = []
    
    var body: some View {
        VStack {
            Button("Track Data") {
                tracker.trackData("Your data here!")
            }
            Button("Get Data") {
                dataPoints = tracker.getData()
            }
            List(dataPoints) { dataPoint in
                HStack {
                    Text(dataPoint.data)
                    Spacer()
                    Text(dataPoint.timestamp, style: .date)
                }
            }
        }
    }
}

@main
struct tw6j_prototype_a_dec: App {
    @StateObject var visualization = DataVisualization()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(visualization)
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var visualization: DataVisualization
    
    var body: some View {
        visualization
    }
}