#!/usr/bin/env node
const glob = require("glob");
const fs = require("fs");
const path = require("path");
const stream = require("stream");
const MultiStream = require("multistream");

let output = fs.createWriteStream("./dist/LICENSE-purs", { flags: "w+" });
let licenses = (() => {
  let files = glob.sync(".spago/**/LICENSE");
  let tail = files.pop();

  let copyLicense = (newline) => (license) => {
    let [_s, _p, name, _l] = license.split(path.sep);
    return [
      stream.Readable.from(`LICENSE - ${decodeURIComponent(name)}\n\n`),
      fs.createReadStream(license, "utf-8"),
      stream.Readable.from(newline ? "\n" : ""),
    ];
  };

  return files.flatMap(copyLicense(true)).concat(copyLicense(false)(tail));
})();

new MultiStream(licenses).pipe(output);
