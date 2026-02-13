{
description = "Flutter 3.29.x";
inputs = {
  nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  flake-utils.url = "github:numtide/flake-utils";
};
outputs = { self, nixpkgs, flake-utils }:
  flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs {
        inherit system;
        config = {
          android_sdk.accept_license = true;
          allowUnfree = true;
        };
      };
      buildToolsVersion = "34.0.0";
      androidComposition = pkgs.androidenv.composeAndroidPackages {
        buildToolsVersions = [ buildToolsVersion "28.0.3" ];
        platformVersions = [ "36" "28" ];
        abiVersions = [ "x86_64" ];
        extraLicenses = [
          "android-googletv-license"
          "android-sdk-arm-dbt-license"
          "android-sdk-license"
          "android-sdk-preview-license"
          "google-gdk-license"
          "intel-android-extra-license"
          "intel-android-sysimage-license"
          "mips-android-sysimage-license"
        ];
      };
      androidSdk = androidComposition.androidsdk;
    in
    {
      devShell =
        with pkgs; mkShell rec {
          ANDROID_HOME = "${androidSdk}/libexec/android-sdk";
          buildInputs = [
            flutter
            androidSdk # The customized SDK that we've made above
            jdk17
          ];
        };
    });
}