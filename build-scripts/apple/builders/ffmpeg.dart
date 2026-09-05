import '../../common/common.dart';
import '../models/apple_arch.dart';
import '../models/apple_build_context.dart';
import '../models/apple_framework.dart';
import '../models/apple_library_builder.dart';

class FFmpegBuilder extends AppleLibraryBuilder {

  const new() : super(Library.ffmpeg);

  @override
  List<AppleFramework> get frameworks => [
    AppleFramework(
      name: "Avcodec",
      staticLib: "libavcodec",
      sharedLib: "libavcodec",
      includeEntries: ["libavcodec"],
      deniedHeaders: {
        "libavcodec/d3d11va.h",
        "libavcodec/dxva2.h",
        "libavcodec/vdpau.h",
        "libavcodec/qsv.h",
        "libavcodec/mediacodec.h",
        "libavcodec/jni.h",
      },
    ),
    AppleFramework(
      name: "Avutil",
      staticLib: "libavutil",
      sharedLib: "libavutil",
      includeEntries: ["libavutil"],
      deniedHeaders: {
        "libavutil/hwcontext_amf.h",
        "libavutil/hwcontext_cuda.h",
        "libavutil/hwcontext_d3d11va.h",
        "libavutil/hwcontext_d3d12va.h",
        "libavutil/hwcontext_drm.h",
        "libavutil/hwcontext_dxva2.h",
        "libavutil/hwcontext_mediacodec.h",
        "libavutil/hwcontext_oh.h",
        "libavutil/hwcontext_opencl.h",
        "libavutil/hwcontext_qsv.h",
        "libavutil/hwcontext_vaapi.h",
        "libavutil/hwcontext_vdpau.h",
      },
    ),
    AppleFramework(
        name: "Avformat",
        staticLib: "libavformat",
        sharedLib: "libavformat",
        includeEntries: ["libavformat"],
    ),
    AppleFramework(
        name: "Swresample",
        staticLib: "libswresample",
        sharedLib: "libswresample",
        includeEntries: ["libswresample"],
    ),
    AppleFramework(
        name: "Swscale",
        staticLib: "libswscale",
        sharedLib: "libswscale",
        includeEntries: ["libswscale"],
    ),
    AppleFramework(
        name: "Avfilter",
        staticLib: "libavfilter",
        sharedLib: "libavfilter",
        includeEntries: ["libavfilter"],
    ),
  ];

  List<String> get libraries => [
    "--enable-videotoolbox",
    "--enable-avfoundation",
    "--enable-mbedtls",
    "--enable-vulkan",
    "--enable-libdav1d",
    "--enable-lcms2",
    "--enable-iconv",
    "--enable-libass",
    "--enable-libplacebo",
    "--enable-libshaderc",
    "--enable-libfribidi",
    "--enable-libfreetype",
    "--enable-libharfbuzz",
  ];

  List<String> get filters => [
    "--enable-filter=libplacebo",
    "--enable-filter=subtitles",
    "--enable-filter=ass",
    "--enable-filter=crop",
    "--enable-filter=aformat", "--enable-filter=amix", "--enable-filter=anull",
    "--enable-filter=aresample",
    "--enable-filter=areverse", "--enable-filter=asetrate", "--enable-filter=atempo",
    "--enable-filter=atrim",
    "--enable-filter=bwdif", "--enable-filter=delogo",
    "--enable-filter=equalizer", "--enable-filter=estdif",
    "--enable-filter=firequalizer", "--enable-filter=format", "--enable-filter=fps",
    "--enable-filter=hflip", "--enable-filter=hwdownload", "--enable-filter=hwmap",
    "--enable-filter=hwupload",
    "--enable-filter=idet", "--enable-filter=lenscorrection", "--enable-filter=lut*",
    "--enable-filter=negate", "--enable-filter=null",
    "--enable-filter=overlay",
    "--enable-filter=palettegen", "--enable-filter=paletteuse", "--enable-filter=pan",
    "--enable-filter=rotate",
    "--enable-filter=scale", "--enable-filter=setpts", "--enable-filter=superequalizer",
    "--enable-filter=transpose", "--enable-filter=trim",
    "--enable-filter=vflip", "--enable-filter=volume", "--enable-filter=loudnorm",
    "--enable-filter=w3fdif",
    "--enable-filter=yadif",
    "--enable-filter=avgblur_vulkan", "--enable-filter=blend_vulkan",
    "--enable-filter=bwdif_vulkan",
    "--enable-filter=chromaber_vulkan", "--enable-filter=flip_vulkan",
    "--enable-filter=gblur_vulkan",
    "--enable-filter=hflip_vulkan", "--enable-filter=nlmeans_vulkan",
    "--enable-filter=overlay_vulkan",
    "--enable-filter=vflip_vulkan", "--enable-filter=xfade_vulkan",
  ];

  List<String> get decoders => [
    "--enable-decoder=libdav1d",
    "--enable-decoder=dca",
    "--enable-decoder=dxv",
    "--enable-decoder=ffv1",
    "--enable-decoder=ffvhuff",
    "--enable-decoder=flv",
    "--enable-decoder=h263",
    "--enable-decoder=h263i",
    "--enable-decoder=h263p",
    "--enable-decoder=h264",
    "--enable-decoder=hap",
    "--enable-decoder=hevc",
    "--enable-decoder=huffyuv",
    "--enable-decoder=indeo5",
    "--enable-decoder=mjpeg",
    "--enable-decoder=mjpegb",
    "--enable-decoder=mpeg*",
    "--enable-decoder=mts2",
    "--enable-decoder=prores",
    "--enable-decoder=mpeg4",
    "--enable-decoder=mpegvideo",
    "--enable-decoder=rv10",
    "--enable-decoder=rv20",
    "--enable-decoder=rv30",
    "--enable-decoder=rv40",
    "--enable-decoder=snow",
    "--enable-decoder=svq3",
    "--enable-decoder=tscc",
    "--enable-decoder=txd",
    "--enable-decoder=wmv1",
    "--enable-decoder=wmv2",
    "--enable-decoder=wmv3",
    "--enable-decoder=vc1",
    "--enable-decoder=vp6",
    "--enable-decoder=vp6a",
    "--enable-decoder=vp6f",
    "--enable-decoder=vp7",
    "--enable-decoder=vp8",
    "--enable-decoder=vp9",

    "--enable-decoder=aac*",
    "--enable-decoder=ac3*",
    "--enable-decoder=adpcm*",
    "--enable-decoder=alac*",
    "--enable-decoder=amr*",
    "--enable-decoder=ape",
    "--enable-decoder=cook",
    "--enable-decoder=dca",
    "--enable-decoder=dolby_e",
    "--enable-decoder=eac3*",
    "--enable-decoder=flac",
    "--enable-decoder=mp1*",
    "--enable-decoder=mp2*",
    "--enable-decoder=mp3*",
    "--enable-decoder=opus",
    "--enable-decoder=pcm*",
    "--enable-decoder=sonic",
    "--enable-decoder=truehd",
    "--enable-decoder=tta",
    "--enable-decoder=vorbis",
    "--enable-decoder=wma*",


    "--enable-decoder=ass",
    "--enable-decoder=ccaption",
    "--enable-decoder=dvbsub",
    "--enable-decoder=dvdsub",
    "--enable-decoder=mpl2",
    "--enable-decoder=movtext",
    "--enable-decoder=pgssub",
    "--enable-decoder=srt",
    "--enable-decoder=ssa",
    "--enable-decoder=subrip",
    "--enable-decoder=xsub",
    "--enable-decoder=webvtt",
  ];

  List<String> get encoders => [
    "--enable-encoder=aac",
    "--enable-encoder=alac",
    "--enable-encoder=flac",
    "--enable-encoder=pcm*",
    "--enable-encoder=movtext",
    "--enable-encoder=mpeg4",
    "--enable-encoder=h264_videotoolbox",
    "--enable-encoder=hevc_videotoolbox",
    "--enable-encoder=prores",
    "--enable-encoder=prores_videotoolbox",
  ];

  List<String> get demuxers => [
    "--enable-demuxer=aac",
    "--enable-demuxer=ac3",
    "--enable-demuxer=aiff",
    "--enable-demuxer=amr",
    "--enable-demuxer=ape",
    "--enable-demuxer=asf",
    "--enable-demuxer=ass",
    "--enable-demuxer=av1",
    "--enable-demuxer=avi",
    "--enable-demuxer=caf",
    "--enable-demuxer=concat",
    "--enable-demuxer=dash",
    "--enable-demuxer=data",
    "--enable-demuxer=dv",
    "--enable-demuxer=eac3",
    "--enable-demuxer=flac",
    "--enable-demuxer=flv",
    "--enable-demuxer=h264",
    "--enable-demuxer=hevc",
    "--enable-demuxer=hls",
    "--enable-demuxer=live_flv",
    "--enable-demuxer=loas",
    "--enable-demuxer=m4v",
  ];

  List<String> get muxers => [
    "--enable-muxer=flac",
    "--enable-muxer=dash",
    "--enable-muxer=hevc",
    "--enable-muxer=m4v",
    "--enable-muxer=matroska",
    "--enable-muxer=mov",
    "--enable-muxer=mp4",
    "--enable-muxer=mpegts",
    "--enable-muxer=webm*",
  ];

  List<String> get components => [
    "--enable-pthreads",
    "--enable-network",
    "--disable-avdevice",
    "--enable-avcodec",
    "--enable-avformat",
    "--enable-swresample",
    "--enable-swscale",
    "--enable-avfilter",
  ];

  List<String> get protocols => [
    "--enable-protocol=file",
    "--enable-protocol=fd",
    "--enable-protocol=data",
    "--enable-protocol=http",
    "--enable-protocol=https",
    "--enable-protocol=httpproxy",
    "--enable-protocol=rtmp",
    "--enable-protocol=rtmps",
    "--enable-protocol=tcp",
    "--enable-protocol=udp",
    "--enable-protocol=ftp",
  ];


  @override
  void build({required AppleBuildContext context}) {
    final arch = switch (context.target.arch) {
      AppleArch.x86_64 => "x86_64",
      AppleArch.arm64 => "aarch64",
    };
    final sysroot = context.target.platform.sdkPath;
    final targetFlags = "-arch ${context.target.arch.clangArch} -isysroot $sysroot -target ${context.target.clangTarget} ${context.target.minVersionFlag}";
    final extraCFlags = "$targetFlags -fPIC -I${context.prefixDir.resolveDir("include").absolutePath}";
    final extraLdFlags = "$targetFlags -L${context.prefixDir.resolveDir("lib").absolutePath}";
    patchVideotoolbox(context);
    configure(
      context: context,
      environment: context.configureTaskEnv,
      arguments: [
        "--disable-everything",
        "--disable-programs",
        "--disable-gpl", "--disable-nonfree", "--enable-version3",
        ...components,
        ...libraries,
        ...filters,
        ...encoders, ...decoders,
        ...muxers, ...demuxers,
        ...protocols,
        "--enable-bsfs", //bitstream filters
        "--enable-hwaccel=videotoolbox",

        "--disable-small",
        "--disable-gray",
        "--enable-swscale-alpha",
        "--enable-runtime-cpudetect",
        "--disable-autodetect",
        ... context.buildShared ? ["--enable-shared", "--disable-static"] : ["--enable-static", "--disable-shared"],
        "--disable-doc",
        "--disable-htmlpages",
        "--disable-manpages",
        "--disable-podpages",
        "--disable-txtpages",
        "--arch=$arch",
        "--enable-cross-compile",
        "--target-os=darwin",
        "--cc=/usr/bin/clang",
        "--cxx=/usr/bin/clang++",
        "--as=/usr/bin/clang",
        "--nm=${context.target.platform.toolPath("nm")}",
        "--ar=${context.target.platform.toolPath("ar")}",
        "--strip=${context.target.platform.toolPath("strip")}",
        "--ranlib=${context.target.platform.toolPath("ranlib")}",
        "--pkg-config=pkg-config",
        "--pkg-config-flags=--static",
        "--extra-cflags=$extraCFlags",
        "--extra-ldflags=$extraLdFlags",
        "--extra-libs=-ldovi -liconv",
        "--enable-pic",
        ...switch (context.target.arch) {
          AppleArch.x86_64 => ["--disable-asm", "--disable-neon"],
          AppleArch.arm64 => ["--enable-asm", "--enable-neon"],
        },
        "--enable-optimizations",
        "--disable-stripping",
      ],
    );
    make(context);
  }

  void patchVideotoolbox(AppleBuildContext context) {
    final vt = context.sourcesDir.resolveFile("libavcodec/videotoolbox.c");
    if ( !vt.existsSync() ) {
      throw "Cannot find file ${vt.absolutePath}";
    }
    final contents = vt.readAsStringSync()
      .replaceAll("kCVPixelBufferOpenGLESCompatibilityKey", "kCVPixelBufferMetalCompatibilityKey")
      .replaceAll("kCVPixelBufferIOSurfaceOpenGLTextureCompatibilityKey", "kCVPixelBufferMetalCompatibilityKey");
    vt.writeAsStringSync(contents, mode: FileMode.writeOnly);
  }


}