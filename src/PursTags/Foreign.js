"use strict";

exports.unsafeComputeByteOffsetJs = (buffer, line, column) => {
    let offset = 0;

    let currentLine = line + 1;
    while (currentLine > 1) {
        if (buffer[offset] === 10) {
            currentLine -= 1;
        }
        offset += 1;
    }

    let currentColumn = column + 1;
    while (currentColumn > 1) {
        offset += 1;
        currentColumn -= 1;
    }

    return offset + 1;
}

exports.unsafeGetByteLength = (source) => {
    let encoder = new TextEncoder();
    return encoder.encode(source).byteLength;
}

exports.unsafeGetLineStr = (source) => (line) => {
    let currentLine = 0;
    let currentIndex = 0;
    while (currentLine < line) {
        if (source[currentIndex] == "\n") {
            currentLine += 1;
        }
        currentIndex += 1;
    }
    return source.slice(currentIndex, source.indexOf("\n", currentIndex));
}
