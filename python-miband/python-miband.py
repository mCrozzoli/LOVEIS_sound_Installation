%pip install python-osc bluepy pycrypto

from bluepy.btle import Scanner, DefaultDelegate, BTLEDisconnectError
from MiBand2.base import MiBand2
import threading
from time import sleep
from pythonosc.udp_client import SimpleUDPClient

osc_receivers = [
    ("127.0.0.1", 57120)
]

osc_clients = [
    SimpleUDPClient(ip, port) for (ip, port) in osc_receivers
]

num_mibands = 2


class MIBandScanner(DefaultDelegate):

    def __init__(self):
        DefaultDelegate.__init__(self)
        self.mibands = set()

    def handleDiscovery(self, dev, isNewDev, isNewData):
        if isNewDev:
            for (adtype, desc, value) in dev.getScanData():
                if adtype == 9 and value == 'MI Band 2':
                    print(f"Discovered MI Band 2: {dev.addr}")
                    self.mibands.add(dev.addr)


class MiBandThread(threading.Thread):
    def __init__(self, mac, parent_thread):
        super(MiBandThread, self).__init__()
        miband = MiBand2(mac, debug=True)
        miband.setSecurityLevel(level="medium")
        is_init = miband.initialize()
        if is_init:
            print(f'[MiBand: {mac}] Initialized')
        else:
            print(f'[MiBand: {mac}] Error initializing')
        miband.authenticate()
        self.mac = mac
        self.miband = miband
        self.parent_thread = parent_thread

    def run(self):
        try:
            self.miband.start_heart_rate_realtime(lambda x: self.on_data(x))
        except BTLEDisconnectError:
            print(f'[MiBand: {self.mac}] Disconnected')
            self.parent_thread.add_to_reconnect_list(self.mac)
        except:
            print(f'[MiBand: {self.mac}] ERROR')
            self.parent_thread.add_to_reconnect_list(self.mac)

    def on_data(self, heart_rate):
        print(f'[MiBand: {self.mac}] heart rate = {heart_rate}')
        for client in osc_clients:
            client.send_message('/miband', [self.mac, heart_rate])


class MiBandScannerThread(threading.Thread):
    def __init__(self):
        super(MiBandScannerThread, self).__init__()
        self.miband_scanner = MIBandScanner()
        self.scanner = Scanner().withDelegate(self.miband_scanner)
        self.found_macs = set()
        self.miband_macs = set()
        self.reconnect_macs = set()

    def scan(self, scan_duration=5.0):
        print('[Scanner] Scanning for MiBands...')
        self.scanner.scan(scan_duration)
        for addr in self.miband_scanner.mibands:
            self.found_macs.add(addr)
        print(f'[Scanner] Found MiBands: {self.found_macs}')

    def try_connect(self, mac):
        try:
            thread = MiBandThread(mac, self)
            self.miband_macs.add(mac)
            if mac in self.reconnect_macs:
                self.reconnect_macs.remove(mac)
            return thread
        except:
            self.add_to_reconnect_list(mac)
            return None

    def add_to_reconnect_list(self, mac):
        if mac in self.miband_macs:
            self.miband_macs.remove(mac)
        self.reconnect_macs.add(mac)

    def run(self):
        self.scan()
        while len(self.found_macs) < num_mibands:
            print(
                f'[Scanner] not enough MiBands: {len(self.found_macs)} connected < {num_mibands} wanted')
            self.scan()
        threads = [self.try_connect(addr) for addr in self.found_macs]
        for t in threads:
            if t is not None:
                t.start()

        while True:
            reconnect_macs = self.reconnect_macs.copy()
            for addr in reconnect_macs:
                t = self.try_connect(addr)
                if t is not None:
                    t.start()
            sleep(1)


MiBandScannerThread().start()
