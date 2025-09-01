extern crate yaml_rust;
use std::fs;
use yaml_rust::YamlLoader;
use colored::Colorize;
use std::io::Write;
use std::process;

pub fn kx(kubeconfig: &str, kcontext: &str) {

    let read_kubeconfig = fs::read_to_string(kubeconfig)
        .expect("Failed to read KUBECONFIG file");
    let contexts = YamlLoader::load_from_str(&read_kubeconfig)
        .expect("KUBECONFIG file incorrect format");
    let context = &contexts[0];
    let current_context = context["current-context"].as_str().unwrap_or("");
    let all_contexts: Vec<_> = match context["contexts"].as_vec() {
        Some(v) => v.clone(),
        None => Vec::new(),
    };

    if kcontext.is_empty() {
        // get current context
        for context_name in &all_contexts {
            let name = context_name["name"].as_str().unwrap_or("");
            if name == current_context {
                println!("{}", name.green());
            } else {
                println!("{}", name);
            }
        }
    } else {
        // set current context
        let check_context_exists = all_contexts.iter().any(|context_name| {
            context_name["name"].as_str().unwrap_or("") == kcontext
        });

        if check_context_exists {
            let contents = fs::read_to_string(kubeconfig)
                .expect("Failed to read KUBECONFIG file");
            let mut value: serde_yaml::Value = serde_yaml::from_str(&contents).unwrap();
            let target = value.as_mapping_mut().unwrap();

            if target.contains_key("current-context") {
                *value.get_mut("current-context").unwrap() = kcontext.into();
            } else {
                target.insert("current-context".into(), kcontext.into());
            }

            let writer = serde_yaml::to_string(&value).unwrap();
            let mut file = std::fs::File::create(kubeconfig).expect("create failed");
            file.write_all(writer.as_bytes()).expect("write failed");
            println!("Switched context to \"{}\"", kcontext.green());
        } else {
            println!("error: no context exists with the name: \"{}\"", kcontext.red());
            process::exit(1);
        }
    }
}
