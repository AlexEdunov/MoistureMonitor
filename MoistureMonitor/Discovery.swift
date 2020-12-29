import Foundation
import CoreBluetooth

class Discovery: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    private var centralManager: CBCentralManager?
    private var connectingPeripheral: CBPeripheral?
    private var queue = DispatchQueue(label: "com.ae.MoistureMonitor.Discovery")

    var connectivityStateUpdated: ((Bool) -> Void)?
    var valueUpdated: ((UInt8) -> Void)?

    override init() {
        super.init()

        centralManager = CBCentralManager(delegate: self, queue: queue)
    }

    func startScan() {
        guard let centralManager = centralManager else { return }

        centralManager.scanForPeripherals(withServices: [CBUUID(string: "098D")],
                                          options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
    }

    func stopScan() {
        guard let centralManager = centralManager else { return }

        centralManager.stopScan()
    }

    func connect(peripheral: CBPeripheral) {
        guard let centralManager = centralManager else { return }

        peripheral.delegate = self
        centralManager.connect(peripheral, options: nil)

        connectingPeripheral = peripheral
    }

    func disconnect(peripheral: CBPeripheral) {
        guard let centralManager = centralManager else { return }

        centralManager.cancelPeripheralConnection(peripheral)
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if case CBManagerState.poweredOn = central.state {
            startScan()
        }
    }

    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any],
                        rssi RSSI: NSNumber) {

        stopScan()
        connect(peripheral: peripheral)
    }

    func centralManager(_ central: CBCentralManager,
                        didConnect peripheral: CBPeripheral) {

        DispatchQueue.main.async { [unowned self] in
            self.connectivityStateUpdated?(true)
        }

        peripheral.discoverServices(nil)
    }

    func peripheral(_ peripheral: CBPeripheral,
                    didDiscoverServices error: Error?) {

        guard let services = peripheral.services else { return }

        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }

    func peripheral(_ peripheral: CBPeripheral,
                    didDiscoverCharacteristicsFor service: CBService,
                    error: Error?) {

        guard
            let characteristics = service.characteristics,
            let moistureCharacteristic = characteristics.first(where: { $0.uuid.uuidString.contains("098E") })
        else { return }

        peripheral.setNotifyValue(true, for: moistureCharacteristic)
    }

    public func peripheral(_ peripheral: CBPeripheral,
                           didUpdateValueFor characteristic: CBCharacteristic,
                           error: Error?) {

        guard
            let dataValue = characteristic.value,
            let value = UInt8(data: dataValue)
        else { return }

        DispatchQueue.main.async { [unowned self] in
            self.valueUpdated?(value)
        }
    }

    func centralManager(_ central: CBCentralManager,
                        didDisconnectPeripheral peripheral: CBPeripheral,
                        error: Error?) {

        connectingPeripheral = nil
        startScan()

        DispatchQueue.main.async { [unowned self] in
            self.connectivityStateUpdated?(false)
        }
    }
}

private extension UInt8 {
    init?(data: Data) {
        self = data.withUnsafeBytes { $0.load(as: Self.self) }
    }
}
