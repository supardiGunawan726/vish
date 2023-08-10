import * as fs from "fs";
import * as path from "path";
import { initializeApp } from "firebase-admin/app";
import * as functionsLogger from "firebase-functions/logger";

initializeApp();

const functionsName: string[] = [];
exportFunctions(__dirname);

function exportFunctions(dir: string) {
  const files = fs.readdirSync(dir);

  for (const file of files) {
    const filePath = path.resolve(dir, file);
    const stat = fs.statSync(filePath);

    if (stat.isDirectory()) {
      exportFunctions(filePath);
    }

    if (!file.match(/^[a-zA-Z]+\.(func){1}\.(ts|js)$/g)) continue;

    const relativeFilePath = filePath.replace(__dirname, ".");
    const functionName = file.replace(/\.(func){1}\.(ts|js)$/g, "");

    if (functionsName.includes(functionName)) {
      const errorMsg = `[Error]: duplicate function name. ${relativeFilePath}`;
      console.error(errorMsg);
      functionsLogger.error(errorMsg);
      throw Error(errorMsg);
    }

    const defaultExportedFunction = require(relativeFilePath).default;

    functionsName.push(functionName);
    if (defaultExportedFunction) {
      exports[functionName] = defaultExportedFunction;
    }
  }
}
