import js from '@eslint/js';
import globals from 'globals';
import react from 'eslint-plugin-react';
import reactHooks from 'eslint-plugin-react-hooks';
import reactCompiler from 'eslint-plugin-react-compiler';
import prettier from 'eslint-plugin-prettier';
import eslintConfigPrettier from 'eslint-config-prettier';

export default [
  // Base Javascript configuration
  js.configs.recommended,
  
  // React files configuration
  {
    files: ['**/*.{jsx,tsx}'],
    
    plugins: {
      react,
      'react-hooks': reactHooks,
      'react-compiler': reactCompiler,
      prettier,
    },
    
    languageOptions: {
      ecmaVersion: 2022,
      sourceType: 'module',
      parserOptions: {
        ecmaFeatures: {
          jsx: true,
        },
      },
      globals: {
        ...globals.browser,
      },
    },
    
    settings: {
      react: {
        version: 'detect',
      },
    },
    
    rules: {
      ...react.configs.recommended.rules,
      ...react.configs['jsx-runtime'].rules,
      ...reactHooks.configs.recommended.rules,
      ...reactCompiler.configs.recommended.rules,
      ...eslintConfigPrettier.rules,
      'prettier/prettier': 'error',
      'react/no-deprecated': 'warn',
      'react/no-direct-mutation-state': 'error',
    },
  },
  
  // JavaScript/Rails files configuration (Stimulus, Turbo, jQuery)
  {
    files: ['**/*.{js,mjs,cjs}'],
    
    plugins: {
      prettier,
    },
    
    languageOptions: {
      ecmaVersion: 2022,
      sourceType: 'module',
      globals: {
        ...globals.node,
        ...globals.browser,
        ...globals.jquery,
        ...globals.jasmine,
        // Rails/Stimulus/Turbo specific globals
        Stimulus: 'readonly',
        Turbo: 'readonly',
        timeago: 'readonly',
        fixture: 'readonly',
        spyOnEvent: 'readonly',
      },
    },
    
    rules: {
      ...eslintConfigPrettier.rules,
      'prettier/prettier': 'error',
    },
  },
];
