#!/usr/bin/env bb
(require '[clojure.tools.cli :refer [parse-opts]])

(def cli-options
  ;; todo: is there a proper way to pass a path?
  [["-o" "--output Output" "Output file"
    :default "initramfs.cpio"]
  ["-p" "--port PORT" "Port number"
    :default 80
    :parse-fn #(Integer/parseInt %)
    :validate [#(< 0 % 0x10000) "Must be a number between 0 and 65536"]]
   ["-h" "--help"]])

(:options (parse-opts *command-line-args* cli-options))
