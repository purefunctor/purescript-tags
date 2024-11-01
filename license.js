#!/usr/bin/env node
import glob from "glob";
import { createWriteStream, createReadStream } from "fs";
import { sep } from "path";
import { Readable } from "stream";
import MultiStream from "multistream";

let output = createWriteStream("./dist/LICENSE-purs", { flags: "w+" });
let licenses = (() => {
  let files = glob.sync(".spago/**/LICENSE");
  let tail = files.pop();

  let copyLicense = (newline) => (license) => {
    let [_s, _p, name, _l] = license.split(sep);
    return [
      Readable.from(`LICENSE - ${decodeURIComponent(name)}\n\n`),
      createReadStream(license, "utf-8"),
      Readable.from(newline ? "\n" : ""),
    ];
  };

  return files.flatMap(copyLicense(true)).concat(copyLicense(false)(tail));
})();

new MultiStream(licenses).pipe(output);
