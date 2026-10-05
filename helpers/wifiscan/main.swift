import Foundation
import CoreWLAN
import CoreLocation

// Scans nearby Wi-Fi and writes "ssid\trssi\tsecure" lines to /tmp/sketchybar_wifi_scan.txt
let out = "/tmp/sketchybar_wifi_scan.txt"

final class Scanner: NSObject, CLLocationManagerDelegate {
    let lm = CLLocationManager()
    func start() {
        lm.delegate = self
        let s = lm.authorizationStatus
        if s == .notDetermined { lm.requestWhenInUseAuthorization() } else { scan(s) }
    }
    func locationManagerDidChangeAuthorization(_ m: CLLocationManager) {
        let s = m.authorizationStatus
        if s != .notDetermined { scan(s) }
    }
    func scan(_ s: CLAuthorizationStatus) {
        var lines: [String] = []
        if s == .denied || s == .restricted { lines.append("#DENIED") }
        if let iface = CWWiFiClient.shared().interface() {
            if let nets = try? iface.scanForNetworks(withName: nil) {
                var best: [String: (Int, Bool)] = [:]
                for n in nets {
                    guard let ssid = n.ssid, !ssid.isEmpty else { continue }
                    let secure = !n.supportsSecurity(.none)
                    if let b = best[ssid], b.0 >= n.rssiValue { continue }
                    best[ssid] = (n.rssiValue, secure)
                }
                for (k, v) in best.sorted(by: { $0.value.0 > $1.value.0 }) {
                    lines.append("\(k)\t\(v.0)\t\(v.1 ? 1 : 0)")
                }
            }
        }
        try? lines.joined(separator: "\n").write(toFile: out, atomically: true, encoding: .utf8)
        exit(0)
    }
}
let sc = Scanner()
sc.start()
DispatchQueue.main.asyncAfter(deadline: .now() + 60) { exit(1) }
RunLoop.main.run()
