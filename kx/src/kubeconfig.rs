use std::env;
use std::path::Path;
use std::process;

pub fn get_kubeconfig_file() -> String {
    let kubeconfig = env::var("KUBECONFIG").unwrap_or_else(|_| {
        match home::home_dir() {
            Some(home) => format!("{}/.kube/config", home.display()),
            None => {
                eprintln!("Cannot determine home directory.");
                process::exit(1);
            }
        }
    });

    if Path::new(&kubeconfig).exists() {
        kubeconfig
    } else {
        eprintln!("{} : kubeconfig file does not exist", kubeconfig);
        process::exit(1);
    }
}
