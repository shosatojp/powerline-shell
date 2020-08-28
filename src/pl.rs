#![allow(dead_code)]
#![allow(non_camel_case_types)]
#![allow(unused_variables)]
#![allow(unused_imports)]

use git2::{Branch, Repository};
mod util;
use util::colors::*;
use util::symbols::*;
use util::*;
mod args;
use args::*;
mod path;
use path::*;
mod builder;
use builder::*;
mod userhost;
use userhost::*;
mod git;
use git::*;
mod ssh;
use ssh::*;
mod prompt;
use clap::ArgMatches;
use prompt::*;
mod out;
use out::*;

fn main() {
    let matches: ArgMatches = get_arg_matches();

    // arguments
    let pwd = matches.value_of("pwd").unwrap().to_string();
    let home = matches.value_of("home").unwrap().to_string();

    let width: u32 = match matches.value_of("width").unwrap().parse() {
        Ok(width) => width,
        Err(_) => return,
    };
    let prev_error: u8 = match matches.value_of("error").unwrap().parse() {
        Ok(e) => e,
        Err(_) => return,
    };

    // def colors
    let fg = WHITE;
    let bg_ssh = DEEP_PURPLE;
    let bg_user_hostname = INDIGO;
    let bg_path = TEAL;
    let bg_git = DEEP_ORANGE;
    let bg_prompt = if prev_error > 0 { PINK } else { CYAN };

    // partial prompt builders
    let segment_ssh: Box<dyn PromptSegment> = Box::new(Ssh::new(fg, bg_ssh));
    let segment_userhostname: Box<dyn PromptSegment> =
        Box::new(UserHostname::new(fg, bg_user_hostname));
    let segment_path: Box<dyn PromptSegment> = Box::new(Path::new(fg, bg_path, &home, &pwd));
    let segment_git: Box<dyn PromptSegment> = Box::new(Git::new(fg, bg_git, pwd.as_str()));
    let prompt = Prompt::new(fg, bg_prompt, prev_error);

    // profiles
    let profiles: Vec<Vec<(&Box<dyn PromptSegment>, LENGTH_LEVEL)>> = vec![
        vec![
            (&segment_ssh, LENGTH_LEVEL::LONG),
            (&segment_userhostname, LENGTH_LEVEL::LONG),
            (&segment_path, LENGTH_LEVEL::LONG),
            (&segment_git, LENGTH_LEVEL::LONG),
        ],
        vec![
            (&segment_ssh, LENGTH_LEVEL::LONG),
            (&segment_userhostname, LENGTH_LEVEL::LONG),
            (&segment_path, LENGTH_LEVEL::MEDIUM),
            (&segment_git, LENGTH_LEVEL::LONG),
        ],
        vec![
            (&segment_ssh, LENGTH_LEVEL::LONG),
            (&segment_userhostname, LENGTH_LEVEL::LONG),
            (&segment_path, LENGTH_LEVEL::LONG),
            (&segment_git, LENGTH_LEVEL::LONG),
        ],
        vec![
            (&segment_ssh, LENGTH_LEVEL::LONG),
            (&segment_userhostname, LENGTH_LEVEL::LONG),
            (&segment_path, LENGTH_LEVEL::SHORT),
            (&segment_git, LENGTH_LEVEL::LONG),
        ],
        vec![
            (&segment_ssh, LENGTH_LEVEL::MEDIUM),
            (&segment_userhostname, LENGTH_LEVEL::LONG),
            (&segment_path, LENGTH_LEVEL::SHORT),
            (&segment_git, LENGTH_LEVEL::MEDIUM),
        ],
        vec![
            (&segment_ssh, LENGTH_LEVEL::MEDIUM),
            (&segment_userhostname, LENGTH_LEVEL::MEDIUM),
            (&segment_path, LENGTH_LEVEL::SHORT),
            (&segment_git, LENGTH_LEVEL::MEDIUM),
        ],
        vec![
            (&segment_ssh, LENGTH_LEVEL::SHORT),
            (&segment_userhostname, LENGTH_LEVEL::SHORT),
            (&segment_path, LENGTH_LEVEL::SHORT),
            (&segment_git, LENGTH_LEVEL::MEDIUM),
        ],
        vec![
            (&segment_ssh, LENGTH_LEVEL::SHORT),
            (&segment_userhostname, LENGTH_LEVEL::SHORT),
            (&segment_path, LENGTH_LEVEL::SHORT),
            (&segment_git, LENGTH_LEVEL::MEDIUM),
        ],
    ];

    out(width, &profiles, &prompt);
}
