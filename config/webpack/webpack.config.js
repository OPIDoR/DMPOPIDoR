const path = require("path");
const webpack = require("webpack");
const { EsbuildPlugin } = require("esbuild-loader");

const mode =
  process.env.NODE_ENV === "development" ? "development" : "production";

module.exports = {
  mode,
  devtool:
    mode === "development" ? "eval-cheap-module-source-map" : "source-map",
  module: {
    rules: [
      // Use esbuild to compile JavaScript & TypeScript
      {
        // Match `.js`, `.jsx`, `.ts` or `.tsx` files
        test: /\.[jt]sx?$/,
        loader: "esbuild-loader",
        options: {
          // JavaScript version to compile to
          target: "es2015",
        },
      },
      {
        test: /\.css$/i,
        use: ["style-loader", "css-loader"],
      },
      {
        test: /\.(png|jpe?g|gif|eot|woff2|woff|ttf|svg)$/i,
        type: "asset/resource",
      },
    ],
  },
  entry: {
    application: "./app/javascript/application.js",
  },
  optimization: {
    minimizer: [
      new EsbuildPlugin({
        target: "es2015",
      }),
    ],
  },
  output: {
    filename: "[name].js",
    sourceMapFilename: "[file].map",
    path: path.resolve(__dirname, "..", "..", "app/assets/builds"),
  },
  plugins: [
    new webpack.optimize.LimitChunkCountPlugin({
      maxChunks: 1,
    }),
    new webpack.ProvidePlugin({
      $: "jquery",
      jQuery: "jquery",
      "window.jQuery": "jquery",
      "global.jQuery": "jquery",
      React: "react",
      ReactDOM: "react-dom",
    }),
  ],
  resolve: {
    extensions: [".*", ".js", ".jsx"],
    alias: {
      react: path.resolve("./node_modules/react"),
    },
  },
};
