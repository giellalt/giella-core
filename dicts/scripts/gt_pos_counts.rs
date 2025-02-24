#!/usr/bin/env -S cargo +nightly --color=always -Z script
---cargo
[package]
edition = "2021"
[profile.dev]
opt-level = 3
[dependencies]
serde = { version = "1", features = ["derive"] }
quick-xml = { version = "0.37.2", features = ["serialize"] }
itertools = "0.14"
tap = "1"
---

/*
 * gt_pos_counts.rs
 * run in a giellalt/dict-xxx-yyy directory, and print how many lemmas
 * are found of each pos in the src/ xml files. E.g. output for dict-nob-sme:
 * {"Num": 86, "V": 2348, "Phrase": 260, "Det": 21, "Po": 2, "Adv": 414, "A": 1758, "CC": 8, "CS": 14, "Pron": 88, "N": 21593, "Interj": 13, "total": 26657, "Pr": 52}
 */

use itertools::Itertools;
use serde::Deserialize;
use tap::prelude::*;

#[derive(Deserialize)]
struct Root {
    #[serde(rename = "e")]
    entries: Vec<Entry>,
}

#[derive(Deserialize)]
struct Entry {
    #[serde(rename = "lg")]
    lgs: Vec<LemmaGroup>,
}

#[derive(Deserialize)]
struct LemmaGroup {
    #[serde(rename = "l")]
    lemmas: Vec<Lemma>,
}

#[derive(Deserialize)]
struct Lemma {
    #[serde(rename = "@pos")]
    pos: String,
    #[serde(rename = "$text")]
    text: String,
}

pub fn main() {
    std::env::args()
        .skip(1)
        .next()
        .map(|p| std::path::PathBuf::from(&p))
        .unwrap_or(std::env::current_dir().expect("can get cwd"))
        .read_dir()
        .expect("can read src directory")
        .flat_map(|direntry_result| direntry_result)
        .flat_map(|direntry| std::fs::read_to_string(direntry.path()))
        .flat_map(|s| quick_xml::de::from_str::<Root>(&s))
        .flat_map(|root| root.entries)
        .flat_map(|entry| entry.lgs)
        .flat_map(|lg| lg.lemmas)
        .filter(|lemma| !lemma.text.contains("_"))
        .filter(|lemma| !lemma.text.is_empty())
        .map(|lemma| lemma.pos)
        .counts()
        .tap_mut(|d| { d.insert("total".to_string(), d.values().sum()); })
        .tap(|counts| println!("{counts:?}"));
}
