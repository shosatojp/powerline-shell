use super::builder::*;
use git2::{Branch, Repository};

pub mod colors {
    pub const RED: &str = "5;203";
    pub const PINK: &str = "5;161";
    pub const PURPLE: &str = "5;127";
    pub const DEEP_PURPLE: &str = "5;61";
    pub const INDIGO: &str = "5;61";
    pub const BLUE: &str = "5;33";
    pub const LIGHT_BLUE: &str = "5;39";
    pub const CYAN: &str = "5;38";
    pub const TEAL: &str = "5;30";
    pub const GREEN: &str = "5;71";
    pub const LIGHT_GREEN: &str = "5;107";
    pub const LIME: &str = "5;107";
    pub const YELLOW: &str = "5;221";
    pub const AMBER: &str = "5;214";
    pub const ORANGE: &str = "5;208";
    pub const DEEP_ORANGE: &str = "5;202";
    pub const BROWN: &str = "5;";
    pub const GREY: &str = "5;247";
    pub const BLUE_GREY: &str = "5;66";
    pub const WHITE: &str = "5;15";
    pub const BLACK: &str = "5;0";
    pub fn forground(color: &str) -> String {
        return format!("\x1b[38;{}m", color);
    }

    pub fn background(color: &str) -> String {
        return format!("\x1b[48;{}m", color);
    }

    pub fn resetbackground() -> String {
        return String::from("\x1b[49;24m");
    }

    pub fn resetcolor() -> String {
        return String::from("\x1b[0m");
    }
}

pub mod symbols {
    pub const SYMBOL_RIGHT: char = '\u{e0b0}';
    pub const SYMBOL_RIGHT_ALT: char = '\u{e0b1}';
    pub const SYMBOL_GIT_UNPUSHED: char = '↑';
    pub const SYMBOL_GIT_BRANCH: char = '\u{e0a0}';
    pub const SYMBOL_GIT_CHANGED: char = '\x2a';
    pub const SYMBOL_GIT_STAGED: char = '\x2b';
}

pub trait PartialPrompt {
    fn construct(&self, level: LENGTH_LEVEL, mode: BuildMode) -> PromptStringBuilder;
}

pub fn get_branch_name(repo: &Repository) -> String {
    let branch = Branch::wrap(repo.head().unwrap());
    return match branch.name() {
        Ok(name) => format!(" {}", name.unwrap()),
        Err(_) => String::from(""),
    };
}

pub fn build_path_str(home_src: &str, path_src: &str, level: LENGTH_LEVEL) -> String {
    let home = home_src.as_bytes();
    let home_len = home.len();
    let path = path_src.as_bytes();
    let mut piecies: Vec<String> = vec![];

    let mut slice_start = 0;

    for i in 0..home_len {
        if path[i] != home[i] {
            break;
        }
        if i + 1 == home_len {
            piecies.push("~".to_string());
            slice_start = i + 1;
        }
    }
    match level {
        LENGTH_LEVEL::LONG => {
            for piece in path_src[slice_start..].split('/') {
                if piece.len() > 0 {
                    piecies.push(piece.to_string());
                }
            }
            return piecies.join(format!(" {} ", symbols::SYMBOL_RIGHT_ALT).as_str());
        }
        LENGTH_LEVEL::MEDIUM => {
            let splits = path_src[slice_start..].split('/').collect::<Vec<&str>>();
            for piece in splits.iter() {
                if piece.len() > 0 {
                    if &piece == &splits.last().unwrap() {
                        piecies.push(piece.to_string());
                    } else {
                        piecies.push(piece.chars().nth(0).unwrap().to_string());
                    }
                }
            }
            return piecies.join(format!("/").as_str());
        }
        LENGTH_LEVEL::SHORT => {
            return path_src[slice_start..]
                .split('/')
                .last()
                .unwrap()
                .to_string();
        }
    }
}

#[derive(PartialOrd, PartialEq, Copy, Clone)]
pub enum LENGTH_LEVEL {
    LONG = 2,
    MEDIUM = 1,
    SHORT = 0,
}

pub fn count_git_status(repo: &Repository) -> (u32, u32) {
    let staged_mask = 0b11111;
    let changed_mask = 0b11111 << 7;

    let mut changed = 0;
    let mut staged = 0;
    repo.statuses(Option::None)
        .unwrap()
        .iter()
        .for_each(|status| {
            let bits = &status.status().bits();
            changed += std::cmp::min(bits & changed_mask, 1);
            staged += std::cmp::min(bits & staged_mask, 1);
            return ();
        });

    return (changed, staged);
}

pub fn count_unpushed(repo: &Repository, branch: &Branch) -> Result<u32, &'static str> {
    let mut rw = repo.revwalk().or(Err("could not get revwalk"))?;
    rw.push_head().or(Err("could not push head"))?;
    let upstream = branch.upstream().or(Err("could not get upstream"))?;
    let oid = upstream
        .into_reference()
        .target()
        .ok_or("could not get oid")?;
    rw.hide(oid).or(Err("could not hide upstream oid"))?;

    return Ok(rw.count() as u32);
}
