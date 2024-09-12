"use strict";

export const unsafeByteOffsetBeforeLine = (buffer) => (line) => {
    let offset = 0;

    let currentLine = line + 1;
    while (currentLine > 1) {
        if (buffer[offset] === 10) {
            currentLine -= 1;
        }
        offset += 1;
    }

    return offset;
};

export const unsafeGetByteLength = (buffer) => {
    return buffer.byteLength;
};

export const unsafeGetLineStr = (source) => (line) => {
    let currentLine = 0;
    let currentIndex = 0;
    while (currentLine < line) {
        if (source[currentIndex] == "\n") {
            currentLine += 1;
        }
        currentIndex += 1;
    }
    return source.slice(currentIndex, source.indexOf("\n", currentIndex));
};
