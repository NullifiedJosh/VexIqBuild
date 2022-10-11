use serialport;

#[derive(Debug, Clone)]
pub struct UnknownUsbDevice {
	pub port_name: String,
	pub vid: u16,
	pub pid: u16,
	pub serial_number: Option<String>,
	pub manufacturer: Option<String>,
	pub product: Option<String>,
}

pub fn detect_devices() -> Vec<UnknownUsbDevice> {
	let ports = serialport::available_ports().unwrap();
	let mut devices: Vec<UnknownUsbDevice> = vec![];

	for port in ports {
		let usb = match port.port_type {
			serialport::SerialPortType::UsbPort(d) => d,
			_ => continue
		};
		
		// Only use cu
		if !port.port_name.contains("/cu") {
			continue;
		}
		
		devices.push(UnknownUsbDevice {
			port_name: port.port_name,
			vid: usb.vid,
			pid: usb.pid,
			serial_number: usb.serial_number,
			manufacturer: usb.manufacturer,
			product: usb.product,
		});
	}

	return devices;
}