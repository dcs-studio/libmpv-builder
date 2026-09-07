// swift-tools-version:5.9

import PackageDescription

let package = Package(
  name: "MpvKit",
  platforms: [.macOS(.v12), .iOS(.v15)],
  products: [
    .library(
      name: "MpvKit",
      targets: ["_MpvKit"]
    ),
  ],
  targets: [
    .target(
      name: "_MpvKit",
      dependencies: [
        "Unibreak",
        "Freetype",
        "Fribidi",
        "Harfbuzz",
        "Ass",
        "MoltenVK",
        "Shaderc",
        "Dav1d",
        "Lcms2",
        "Dovi",
        "Placebo",
        "Mbedtls",
        "Mbedx509",
        "Mbedcrypto",
        "Avcodec",
        "Avutil",
        "Avformat",
        "Swresample",
        "Swscale",
        "Avfilter",
        "Uchardet",
        "Mpv",
      ],
      path: "Sources/_MpvKit",
      linkerSettings: [
        .linkedFramework("AVFoundation"),
        .linkedFramework("AudioToolbox"),
        .linkedFramework("CoreAudio"),
        .linkedFramework("CoreFoundation"),
        .linkedFramework("CoreMedia"),
        .linkedFramework("CoreVideo"),
        .linkedFramework("Metal"),
        .linkedFramework("VideoToolbox"),
        .linkedLibrary("bz2"),
        .linkedLibrary("iconv"),
        .linkedLibrary("z"),
        .linkedLibrary("c++"),
      ]
    ),
    .binaryTarget(
      name: "Unibreak",
      url: "https://github.com/dcs-studio/libmpv-builder/releases/download/v0.41.0-1/Unibreak.xcframework.zip",
      checksum: "1dab73ac7558abacafcc3dd8e3eb8023bd733b6e68b180e900628ad9aa33d33f"
    ),
    .binaryTarget(
      name: "Freetype",
      url: "https://github.com/dcs-studio/libmpv-builder/releases/download/v0.41.0-1/Freetype.xcframework.zip",
      checksum: "366eb06d670d6de986197419b71e5eb901892ed594f0c82dc1c616abe2c7510e"
    ),
    .binaryTarget(
      name: "Fribidi",
      url: "https://github.com/dcs-studio/libmpv-builder/releases/download/v0.41.0-1/Fribidi.xcframework.zip",
      checksum: "92e864b1c3bea3119c76520e99c286cb3c050657b549ac3bae048c3866dce402"
    ),
    .binaryTarget(
      name: "Harfbuzz",
      url: "https://github.com/dcs-studio/libmpv-builder/releases/download/v0.41.0-1/Harfbuzz.xcframework.zip",
      checksum: "8fe2bdb0e003aef0af54e637eb3d07de5a0e404b43e8904066e7221656ad0969"
    ),
    .binaryTarget(
      name: "Ass",
      url: "https://github.com/dcs-studio/libmpv-builder/releases/download/v0.41.0-1/Ass.xcframework.zip",
      checksum: "67420970e73fc018f436a502efc0fe9392b05d4eca3d4c273762efbfdbae7108"
    ),
    .binaryTarget(
      name: "MoltenVK",
      url: "https://github.com/dcs-studio/libmpv-builder/releases/download/v0.41.0-1/MoltenVK.xcframework.zip",
      checksum: "4e6dfaae14e5fd1d103ccf6c5fdb54afe1d2d4c1dbae98e75265f856022b19e9"
    ),
    .binaryTarget(
      name: "Shaderc",
      url: "https://github.com/dcs-studio/libmpv-builder/releases/download/v0.41.0-1/Shaderc.xcframework.zip",
      checksum: "25ab12bf10f7adfb55e9a7e205acde080f826dd3b58e09e9578283c2833443e2"
    ),
    .binaryTarget(
      name: "Dav1d",
      url: "https://github.com/dcs-studio/libmpv-builder/releases/download/v0.41.0-1/Dav1d.xcframework.zip",
      checksum: "42d25d3d91dc9bee613cc517baf58955e1daa6f5a16b90fed74656f89f079f1d"
    ),
    .binaryTarget(
      name: "Lcms2",
      url: "https://github.com/dcs-studio/libmpv-builder/releases/download/v0.41.0-1/Lcms2.xcframework.zip",
      checksum: "0eb18126c04c38c5292ab258ca77e406d388e613c3d338375b64ce46cd128067"
    ),
    .binaryTarget(
      name: "Dovi",
      url: "https://github.com/dcs-studio/libmpv-builder/releases/download/v0.41.0-1/Dovi.xcframework.zip",
      checksum: "fadd02ad33876e9697cc92dbe4d24d1b4da25083b816bafb09a2951e3833bd23"
    ),
    .binaryTarget(
      name: "Placebo",
      url: "https://github.com/dcs-studio/libmpv-builder/releases/download/v0.41.0-1/Placebo.xcframework.zip",
      checksum: "c8c306146b248b9d939e163dea1403cdee426b821b75dfde09ed29aa58a5d379"
    ),
    .binaryTarget(
      name: "Mbedtls",
      url: "https://github.com/dcs-studio/libmpv-builder/releases/download/v0.41.0-1/Mbedtls.xcframework.zip",
      checksum: "ab2641c60423be5a31b4c4d5e6f533b7b8e312c6c750099549c315c6b0a9d670"
    ),
    .binaryTarget(
      name: "Mbedx509",
      url: "https://github.com/dcs-studio/libmpv-builder/releases/download/v0.41.0-1/Mbedx509.xcframework.zip",
      checksum: "5a3e485cd2b8ce90bc3a118cac677836032e2c748a3374643b2869a425ad2078"
    ),
    .binaryTarget(
      name: "Mbedcrypto",
      url: "https://github.com/dcs-studio/libmpv-builder/releases/download/v0.41.0-1/Mbedcrypto.xcframework.zip",
      checksum: "25b8f2a1e1514d4af21527582a0027ce794d97915c78dbf73855bcfb24b4abff"
    ),
    .binaryTarget(
      name: "Avcodec",
      url: "https://github.com/dcs-studio/libmpv-builder/releases/download/v0.41.0-1/Avcodec.xcframework.zip",
      checksum: "15a5d1bc81e2adb03e1d678387fcc77e30bb4228bfba2428483af2dc63337e7e"
    ),
    .binaryTarget(
      name: "Avutil",
      url: "https://github.com/dcs-studio/libmpv-builder/releases/download/v0.41.0-1/Avutil.xcframework.zip",
      checksum: "d9e2844937022012bfa2f9e457013f62376fabc8ff34a4a631e60acea702ee72"
    ),
    .binaryTarget(
      name: "Avformat",
      url: "https://github.com/dcs-studio/libmpv-builder/releases/download/v0.41.0-1/Avformat.xcframework.zip",
      checksum: "acdce2910f95f93674eebb3872d8263d87b20e183480bfdc83abf0674606682b"
    ),
    .binaryTarget(
      name: "Swresample",
      url: "https://github.com/dcs-studio/libmpv-builder/releases/download/v0.41.0-1/Swresample.xcframework.zip",
      checksum: "2f2c40e494a32bed6db1aa3b221c8b7b4b1e8c842630ade0d296f6a2b67521a2"
    ),
    .binaryTarget(
      name: "Swscale",
      url: "https://github.com/dcs-studio/libmpv-builder/releases/download/v0.41.0-1/Swscale.xcframework.zip",
      checksum: "6b6d770f78cb35a8d9a3d626311765983710ba2b4f86652f64d73f443258cdd7"
    ),
    .binaryTarget(
      name: "Avfilter",
      url: "https://github.com/dcs-studio/libmpv-builder/releases/download/v0.41.0-1/Avfilter.xcframework.zip",
      checksum: "1b6b24ddc0a0e226723ea9ee00ff8e236f4e20f7617b307a06e02220f51b78a1"
    ),
    .binaryTarget(
      name: "Uchardet",
      url: "https://github.com/dcs-studio/libmpv-builder/releases/download/v0.41.0-1/Uchardet.xcframework.zip",
      checksum: "9a776433177edcbd9c2042c2ed7f5ec14d0a0a0cc96a682aa5dbc53a52bc6b60"
    ),
    .binaryTarget(
      name: "Mpv",
      url: "https://github.com/dcs-studio/libmpv-builder/releases/download/v0.41.0-1/Mpv.xcframework.zip",
      checksum: "c7904f3ce5448583150ba2f6c098be8e6dea5345b05279f62e99343c997d0950"
    ),
  ]
)
