pub mod cli;
pub mod serial;
pub mod vex_device;

use crate::{cli::cli, vex_device::detect_devices};

fn main() {
	let args = cli().get_matches();

	if let Some(_matches) = args.subcommand_matches("list") {
		println!("{:#?}", detect_devices());
	}
}
