use clap::{Arg, Command, ValueHint};

fn brain() -> Arg {
	Arg::new("brain")
		.help("The ID for the brain; leave blank for default.")
		.long("brain")
		.short('b')
		.allow_negative_numbers(true)
		.default_value("-1")
}

fn program() -> Arg {
	Arg::new("program")
		.help("The path to the program to upload to the brain brain.")
		.long("program")
		.value_hint(ValueHint::FilePath)
		.short('p')
		.required(true)
}

fn slot() -> Arg {
	Arg::new("slot")
		.help("The slot to upload/run the program.")
		.long("slot")
		.short('s')
		.required(true)
}

pub fn cli() -> Command {
	Command::new("vexiqutility")
		.about("A CLI for running and uploading code to VEXIQ brains.")
		.version("0.1.0")
		.arg(
			Arg::new("verbose")
				.help("Prints more information about the brains.")
				.long("verbose")
				.short('v')
				.default_value("false")
				.value_hint(ValueHint::Other)
		)
		.subcommand(
			Command::new("list")
				.about("List all connected compatible vex devices.")
		)
		.subcommand(
			Command::new("upload")
				.about("Upload a command to the brain.")
				.arg(brain())
				.arg(program())
				.arg(slot())
		)
		.subcommand(
			Command::new("start")
				.about("Uploads and runs a program on the brain.")
				.arg(brain())
				.arg(program())
				.arg(slot())
		)
		.subcommand(
			Command::new("run")
				.about("Runs a program on the brain.")
				.arg(brain())
				.arg(slot())
		)
		.subcommand(
			Command::new("stop")
				.about("Stops a program on the brain.")
				.arg(brain())
		)
		.subcommand_required(true)
					
}