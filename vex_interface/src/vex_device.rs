use crate::serial;

const VEX_PID: [u16; 3] = [3, 512, 528];
const VEX_VID: [u16; 1] = [10376];

use serialport;

enum VexDeviceType {
	BrainV1,
	BrainV2,
	ControlerV2
}
// struct that extends the serialport::SerialPortInfo
struct VexUsbDevice {
	port_name: String,
	vid: u16,
	pid: u16,
	serial_number: Option<String>,
	manufacturer: Option<String>,
	product: Option<String>,
	device_type: VexDeviceType
}

pub fn detect_devices() -> Vec<serial::UnknownUsbDevice> {
	let devices = serial::detect_devices();
	let mut vex_devices: Vec<serial::UnknownUsbDevice> = vec![];

	for device in devices {
		// Check device pid and vid
		if !VEX_PID.contains(&device.pid) || !VEX_VID.contains(&device.vid) {
			continue;
		}

		let mut port = match serialport::new(&device.port_name, 115200)
			.timeout(std::time::Duration::from_millis(100))
			.open() {
				Ok(port) => port,
				Err(_) => continue
			};

		port.write(&[201, 54, 184, 71, 86, 46, 10, 114, 111, 98, 111, 116, 110, 97, 109, 101, 0, 51, 114]).unwrap();

		let mut buf: [u8; 32] = [0; 32];
		port.read_exact(&mut buf).ok();

		println!("Reading from port {:?}", buf);

		vex_devices.push(device);
	}

	return vex_devices;
}