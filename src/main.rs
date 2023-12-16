use std::{error::Error, io, fs::OpenOptions, path::Path, process};
use chrono::prelude::*;
use csv::WriterBuilder;
use serde::Serialize;
use joblog::win::foo;

#[derive(Serialize)]
struct Row {
    time: String,
    #[serde(rename = "project name")]
    project_name: String,
    comments: String,
}

fn main() {
    let mut project_name = String::new();
    let mut add_comments = String::new();
    let now: DateTime<Local> = Local::now();
    let now: String = now.to_string();
    
    println!("Input current project name:");
    io::stdin()
        .read_line(&mut project_name)
        .expect("Failed to read line");

    println!("Input additional comments: ");
    io::stdin()
        .read_line(&mut add_comments)
        .expect("Failed to read line");

    if let Err(err) = write_record(now,project_name,add_comments) {
        println!("{}", err);
        process::exit(1);
    } 
}

fn build_record(now: String, project_name: String, add_comments: String) -> Row {
    Row {
        time: now,
        project_name: project_name,
        comments: add_comments,
    }
}

fn write_record(now: String, project_name: String, add_comments: String) -> Result<(), Box<dyn Error>> {

    if !Path::new("joblog.csv").is_file() {
        let file = OpenOptions::new()
            .write(true)
            .create(true)
            .open("joblog.csv")
            .unwrap();
        let mut wtr = WriterBuilder::new()
            .has_headers(true)
            .from_writer(file);
        wtr.serialize(build_record(now,project_name,add_comments))?;
        wtr.flush()?;
    } else {
        let file = OpenOptions::new()
            .write(true)
            .create(true)
            .append(true)
            .open("joblog.csv")
            .unwrap();
        let mut wtr = WriterBuilder::new()
            .has_headers(false)
            .from_writer(file);
        wtr.serialize(build_record(now,project_name,add_comments))?;
        wtr.flush()?;
    }
    
    Ok(())
}
