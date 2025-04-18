import js from "@eslint/js";
import globals from "globals";
import { defineConfig } from "eslint/config";

export default defineConfig([
  {
    files: ["**/*.{js,mjs,cjs}"],
    plugins: { js },
    extends: ["js/recommended"],
  },
  {
    files: ["**/*.js"],
    languageOptions: { sourceType: "commonjs" },
  },
  {
    files: ["**/*.{js,mjs,cjs}"],
    languageOptions: {
      globals: {
        ...globals.browser,  // For browser-related globals
        jest: "readonly",    // Add Jest globals
        describe: "readonly", 
        test: "readonly", 
        expect: "readonly", 
        __dirname: "readonly", // For Node.js globals
      },
    },
  },
]);
