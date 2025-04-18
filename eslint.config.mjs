import js from "@eslint/js";
import globals from "globals";
import security from "eslint-plugin-security";
import { defineConfig } from "eslint/config";

export default defineConfig([
  {
    files: ["**/*.{js,mjs,cjs}"],
    plugins: {
      js,
      security,
    },
    languageOptions: {
      sourceType: "commonjs",
      globals: {
        ...globals.browser,
        jest: "readonly",
        describe: "readonly",
        test: "readonly",
        expect: "readonly",
        __dirname: "readonly",
      },
    },
    rules: {
      ...js.configs.recommended.rules,
      ...security.configs.recommended.rules,
    },
  },
]);



