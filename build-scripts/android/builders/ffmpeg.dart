import '../../common/common.dart';
import '../android.dart';

class FFmpegBuilder extends AndroidLibraryBuilder {

  const new() : super(library: Library.ffmpeg);

  @override
  void build({required AndroidBuildContext context}) {
    configure(
      context: context,
      environment: context.configureTaskEnv,
      arguments: [
        ...licensing,
        ...reset,
        ...libraries,
        ...output,
        ...sizeTuning,
        ...compatibility,
        ...externalLibraries,

        ...videoDecodersHardware,
        ...videoDecodersModern,
        ...videoDecodersLegacy,
        ...imageDecoders,
        ...audioDecoders,
        ...audioDecodersPcm,
        ...subtitleDecoders,

        ...demuxersContainers,
        ...demuxersStreaming,
        ...demuxersElementary,
        ...demuxersSubtitles,
        ...muxers,

        ...parsers,
        ...bitstreamFilters,
        ...protocols,
        ...filters,

        ...toolchain(context),
      ]
    );
    make(context);
  }

  // ---------------------------------------------------------------------------------------------
  // Licensing
  // ---------------------------------------------------------------------------------------------
  // GPL/non-free code is not needed by anything we enable, and keeping it out means the
  // resulting .so can ship under LGPLv3.

  List<String> get licensing => ["--disable-gpl", "--disable-nonfree", "--enable-version3"];

  // ---------------------------------------------------------------------------------------------
  // Reset — MUST come before every `--enable-*` below
  // ---------------------------------------------------------------------------------------------
  // `--disable-all`        : drops all codecs, formats, protocols, filters, libraries and programs.
  // `--disable-autodetect` : never link a system library just because it happens to be installed;
  //                          external libraries must be requested explicitly (see externalLibraries).

  List<String> get reset => ["--disable-all", "--disable-autodetect"];

  // ---------------------------------------------------------------------------------------------
  // Libraries — which libav* .so files we produce
  // ---------------------------------------------------------------------------------------------
  // avdevice is capture/playback device I/O (webcams, ALSA...). mpv is configured with
  // `-Dlibavdevice=disabled`, so it is dead weight here.

  List<String> get libraries => [
    "--enable-avcodec",     // decoders
    "--enable-avformat",    // containers, network demuxing
    "--enable-avfilter",    // required by mpv (deinterlace, autorotate, --vf/--af)
    "--enable-swscale",     // pixel format / size conversion
    "--enable-swresample",  // sample format / rate / channel conversion
    "--disable-avdevice",
  ];

  // ---------------------------------------------------------------------------------------------
  // Output
  // ---------------------------------------------------------------------------------------------

  List<String> get output => [
    "--enable-shared",
    "--disable-static",
    "--enable-pic",
    "--disable-programs",   // no ffmpeg/ffplay/ffprobe binaries
    "--disable-doc",
  ];


  // ---------------------------------------------------------------------------------------------
  // Size tuning
  // ---------------------------------------------------------------------------------------------
  // `--enable-small` : -Os plus smaller (runtime-generated) tables. This is the one option here
  //                    that costs decode throughput — it is a real trade against software
  //                    decoding speed, so drop it first if playback is CPU-bound.
  // `--disable-debug`: no DWARF debug info, and asserts compiled out.
  // The `--disable-*` lines after that are subsystems nothing we enable pulls in.
  //
  // NOT used: `--disable-runtime-cpudetect`. In FFmpeg 8.x CONFIG_RUNTIME_CPUDETECT is referenced
  // exactly once in the whole tree, in PowerPC code — on arm/arm64/x86 the flag does nothing.
  // Leaving it off keeps NEON + DOTPROD + I8MM compiled in and selected from HWCAP at runtime,
  // which is what makes software H.264/HEVC fast on arm64.

  List<String> get sizeTuning => [
    "--enable-small",
    "--disable-debug",
    "--disable-dwt",        // wavelet transform (Dirac/VC-2/Snow)
    "--disable-faan",       // alternative float IDCT
    "--disable-lsp",        // line spectral pairs — only used by speech codecs (AMR), see audioDecoders
    "--disable-iamf",       // Immersive Audio Model and Formats
    "--disable-pixelutils",  // frame-difference helpers used by filters we do not build
  ];

  // ---------------------------------------------------------------------------------------------
  // Compatibility — cheap options that avoid hard playback failures
  // ---------------------------------------------------------------------------------------------
  // `--enable-gray`          : monochrome H.264/HEVC (B&W films, some anime encodes) refuses to
  //                            decode at all without it.
  // `--enable-swscale-alpha` : keeps alpha through swscale, used when blending bitmap subtitles.
  // `--enable-error-resilience`: keeps playing through corrupt torrent files / lossy IPTV.

  List<String> get compatibility => [
    "--enable-gray",
    "--enable-swscale-alpha",
    "--enable-error-resilience",
    "--enable-network",
    "--enable-pthreads",
    "--disable-w32threads",
    "--disable-os2threads",
  ];

  // ---------------------------------------------------------------------------------------------
  // External libraries
  // ---------------------------------------------------------------------------------------------
  // mediacodec + jni : Android hardware video decoding (mpv `--hwdec=mediacodec`).
  // mbedtls          : TLS, i.e. https:// and rtmps:// sources.
  // libdav1d         : the fast AV1 decoder (built by Dav1dBuilder, used when the device has no
  //                    AV1 hardware decoder).
  // zlib             : Matroska compressed tracks/attachments, compressed MP4 moov atoms and
  //                    gzip HTTP responses (very common for IPTV playlists). Ships with the NDK.

  List<String> get externalLibraries => [
    "--enable-mediacodec",
    "--enable-jni",
    "--enable-mbedtls",
    "--enable-libdav1d",
    "--enable-zlib",
  ];

  // ---------------------------------------------------------------------------------------------
  // Video decoders — hardware (MediaCodec)
  // ---------------------------------------------------------------------------------------------
  // These are thin wrappers around the Android decoder the device already ships. They are what
  // makes 4K HEVC/AV1 playable at all on a TV box, and they cost almost nothing in binary size.

  List<String> get videoDecodersHardware => [
    "--enable-decoder=h264_mediacodec",
    "--enable-decoder=hevc_mediacodec",
    "--enable-decoder=av1_mediacodec",
    "--enable-decoder=vp8_mediacodec",
    "--enable-decoder=vp9_mediacodec",
    "--enable-decoder=mpeg2_mediacodec",
    "--enable-decoder=mpeg4_mediacodec",
  ];


  // ---------------------------------------------------------------------------------------------
  // Video decoders — software fallback for current content
  // ---------------------------------------------------------------------------------------------
  // Used when MediaCodec refuses a stream (10-bit 4:2:2, unusual profiles, broken headers)
  // and on devices with no hardware support for the codec.
  //  h264/hevc      : the vast majority of releases (x264/x265).
  //  libdav1d       : AV1 (dav1d, not FFmpeg's slow native decoder).
  //  vp8/vp9        : WebM, and a lot of IPTV/web streams.
  //  mpeg2video     : DVD rips and SD DVB/IPTV channels.
  //  mpeg1video     : VCD-era files, some broadcast streams.

  List<String> get videoDecodersModern => [
    "--enable-decoder=h264",
    "--enable-decoder=hevc",
    "--enable-decoder=libdav1d",
    "--enable-decoder=vp8",
    "--enable-decoder=vp9",
    "--enable-decoder=mpeg1video",
    "--enable-decoder=mpeg2video",
  ];

  // ---------------------------------------------------------------------------------------------
  // Video decoders — legacy scene formats
  // ---------------------------------------------------------------------------------------------
  // Everything here is for old releases: DivX/XviD .avi, WMV, Blu-ray VC-1 remuxes, .flv, .ogv.
  // Delete this whole group if you only care about content from the last ~10 years.

  List<String> get videoDecodersLegacy => [
    "--enable-decoder=mpeg4",                                   // DivX / XviD
    "--enable-decoder=msmpeg4v1,msmpeg4v2,msmpeg4v3",           // MS MPEG-4 (DivX 3)
    "--enable-decoder=wmv1,wmv2,wmv3,vc1",                      // WMV + VC-1 (Blu-ray remuxes)
    "--enable-decoder=h263,h263i,h263p",
    "--enable-decoder=flv,vp6,vp6a,vp6f",                       // Flash video
    "--enable-decoder=theora",                                  // .ogv
  ];

  // ---------------------------------------------------------------------------------------------
  // Image decoders
  // ---------------------------------------------------------------------------------------------
  // Needed to display embedded cover art (MP3/FLAC/MKV attached pictures) and to open image
  // files directly in mpv. Also covers MJPEG IP-camera style streams.

  List<String> get imageDecoders => ["--enable-decoder=mjpeg,png,bmp,gif,webp"];

  // ---------------------------------------------------------------------------------------------
  // Audio decoders
  // ---------------------------------------------------------------------------------------------
  // AUDIO PASSTHROUGH NOTE: with mpv `--audio-spdif=ac3,eac3,dts-hd,truehd` the compressed
  // stream is sent untouched to the TV/AVR (mpv wraps it with the `spdif` muxer and hands the
  // IEC 61937 frames to Android AudioTrack). That path needs the `spdif` muxer plus the
  // ac3/dca/mlp/mpegaudio parsers, all enabled below. The decoders here are still required: mpv
  // falls back to decoding in software whenever the receiver refuses a format, so both halves
  // must exist. The spdif muxer covers AC3, EAC3, DTS, TrueHD/MLP, AAC and MP1/2/3 — which is
  // exactly the set mpv can emit, so passthrough coverage here is complete.
  //
  //  aac / aac_latm : MP4 and MPEG-TS (LATM is the IPTV variant).
  //  ac3 / eac3     : Dolby Digital / Dolby Digital Plus.
  //  dca            : DTS, DTS-HD, DTS:X.
  //  truehd / mlp   : Dolby TrueHD (and Atmos, which rides on TrueHD).
  //  mp1/mp2/mp3    : MPEG audio — mp2 is everywhere in DVB/IPTV.
  //  wmav*          : .wmv/.asf files.
  //
  // NOT included: AMR (amrnb/amrwb), the speech codec used by phone voice recordings and old
  // .3gp clips. It costs ~100 KB and appears in neither torrent releases nor IPTV. To add it,
  // enable "--enable-decoder=amrnb,amrwb" here, "--enable-demuxer=amr", "--enable-parser=amr",
  // and drop "--disable-lsp" from sizeTuning (AMR needs it, configure would silently skip the
  // decoders otherwise).

  List<String> get audioDecoders => [
    "--enable-decoder=aac,aac_latm",
    "--enable-decoder=ac3,eac3",
    "--enable-decoder=dca",
    "--enable-decoder=truehd,mlp",
    "--enable-decoder=mp1,mp2,mp3",
    "--enable-decoder=opus,vorbis",
    "--enable-decoder=flac,alac",
    "--enable-decoder=wmav1,wmav2,wmapro",
  ];

  // ---------------------------------------------------------------------------------------------
  // Audio decoders — uncompressed / lightly compressed
  // ---------------------------------------------------------------------------------------------
  // pcm_bluray / pcm_dvd are the LPCM tracks found in remuxes; the rest cover .wav/.avi/.mov.
  // These are all table-driven and cost very little.

  List<String> get audioDecodersPcm => [
    "--enable-decoder=pcm_s16le,pcm_s16be,pcm_s24le,pcm_s24be,pcm_s32le,pcm_u8,pcm_f32le",
    "--enable-decoder=pcm_alaw,pcm_mulaw,pcm_bluray,pcm_dvd",
    "--enable-decoder=adpcm_ima_wav,adpcm_ms,adpcm_swf",
  ];

  // ---------------------------------------------------------------------------------------------
  // Subtitle decoders
  // ---------------------------------------------------------------------------------------------
  //  subrip/srt/ass/ssa/text : the text formats inside MKV and as sidecar files.
  //  movtext                 : MP4 subtitles.
  //  webvtt                  : HLS / web streams.
  //  dvdsub                  : VobSub — very common in DVD-sourced MKV rips.
  //  pgssub                  : Blu-ray bitmap subtitles (PGS/SUP).
  //  dvbsub                  : DVB bitmap subtitles, standard on IPTV.
  //  ccaption                : EIA-608/708 closed captions embedded in broadcast video.
  //  microdvd..stl           : the long tail of sidecar .sub/.txt formats.

  List<String> get subtitleDecoders => [
    "--enable-decoder=subrip,srt,ass,ssa,text,movtext,webvtt",
    "--enable-decoder=dvdsub,pgssub,dvbsub,xsub",
    "--enable-decoder=ccaption",
    "--enable-decoder=microdvd,mpl2,jacosub,sami,realtext,subviewer,subviewer1,vplayer,pjs,stl",
  ];

  // ---------------------------------------------------------------------------------------------
  // Demuxers — containers
  // ---------------------------------------------------------------------------------------------
  // A demuxer is what reads the file/stream and splits it into video/audio/subtitle tracks.
  //  matroska  : .mkv and .webm (same demuxer).
  //  mov       : .mp4, .m4v, .m4a, .mov, .3gp (same demuxer).
  //  mpegts    : .ts — the IPTV workhorse. mpegtsraw handles malformed ones.
  //  mpegps    : DVD .vob / .mpg.
  //  asf       : .wmv / .asf.
  //  ogg       : .ogg / .opus / .ogv.
  //  image2    : still images opened directly.

  List<String> get demuxersContainers => [
    "--enable-demuxer=matroska",
    "--enable-demuxer=mov",
    "--enable-demuxer=avi",
    "--enable-demuxer=mpegts,mpegtsraw,mpegps,mpegvideo",
    "--enable-demuxer=asf",
    "--enable-demuxer=flv,live_flv",
    "--enable-demuxer=ogg",
    "--enable-demuxer=wav,aiff",
    "--enable-demuxer=image2",
  ];

  // ---------------------------------------------------------------------------------------------
  // Demuxers — streaming
  // ---------------------------------------------------------------------------------------------
  // hls covers the overwhelming majority of IPTV (.m3u8). rtsp/rtp/sdp cover camera and
  // multicast style sources.
  //
  // NOTE: MPEG-DASH is deliberately absent — FFmpeg's dash demuxer requires libxml2, which
  // would mean shipping another shared library. HLS covers nearly all IPTV providers.

  List<String> get demuxersStreaming => [
    "--enable-demuxer=hls",
    "--enable-demuxer=webm_dash_manifest",
    "--enable-demuxer=rtsp,rtp,sdp",
  ];

  // ---------------------------------------------------------------------------------------------
  // Demuxers — raw elementary streams
  // ---------------------------------------------------------------------------------------------
  // For bare audio files (.mp3, .ac3, .dts...) and raw video dumps (.h264, .265, .obu).
  // The dtshd/truehd ones also matter for external audio tracks used with passthrough.

  List<String> get demuxersElementary => [
    "--enable-demuxer=mp3,aac,flac",
    "--enable-demuxer=ac3,eac3,dts,dtshd,truehd,mlp",
    "--enable-demuxer=h264,hevc,obu",
  ];

  // ---------------------------------------------------------------------------------------------
  // Demuxers — sidecar subtitle files
  // ---------------------------------------------------------------------------------------------
  // These are what let mpv load `Movie.srt` / `Movie.ass` / `Movie.idx+.sub` next to the video.
  // vobsub is the .idx/.sub pair; it needs the mpegps demuxer enabled above.

  List<String> get demuxersSubtitles => [
    "--enable-demuxer=srt,ass,webvtt,vobsub",
    "--enable-demuxer=microdvd,mpl2,jacosub,sami,realtext,subviewer,subviewer1,vplayer,pjs,stl,lrc",
  ];

  // ---------------------------------------------------------------------------------------------
  // Muxers
  // ---------------------------------------------------------------------------------------------
  // A player normally needs none. `spdif` is the exception: it is what wraps AC3/DTS/TrueHD into
  // IEC 61937 frames for AUDIO PASSTHROUGH to a TV or AV receiver.
  //
  // Add "--enable-muxer=matroska,mp4" here if you ever want mpv's `--stream-record` /
  // `--record-file` to work (useful for IPTV timeshifting).

  List<String> get muxers => ["--enable-muxer=spdif"];

  // ---------------------------------------------------------------------------------------------
  // Parsers
  // ---------------------------------------------------------------------------------------------
  // A parser cuts a byte stream into frames and recovers timestamps. They are mandatory for
  // MPEG-TS/raw streams (IPTV), and the audio ones are also what passthrough relies on to find
  // frame boundaries without decoding.

  List<String> get parsers => [
    "--enable-parser=h264,hevc,av1,vp8,vp9,vc1",
    "--enable-parser=mpegvideo,mpeg4video,h263",
    "--enable-parser=aac,aac_latm,ac3,dca,mlp,mpegaudio,opus,vorbis,flac",
    "--enable-parser=dvbsub,dvdsub,dvd_nav",
    "--enable-parser=mjpeg,png,gif,webp,bmp",
  ];

  // ---------------------------------------------------------------------------------------------
  // Bitstream filters
  // ---------------------------------------------------------------------------------------------
  // Small stream rewriters applied between demuxer and decoder. mpv never calls av_bsf_* itself,
  // so only the ones FFmpeg applies internally are actually reachable:
  //  h264/hevc_mp4toannexb : declared by the *_mediacodec decoders, FFmpeg applies them
  //                          automatically. Hardware decoding breaks without them.
  //  aac_adtstoasc         : same, declared by aac_mediacodec; also ADTS AAC (from TS) into MP4 form.
  //  extract_extradata     : libavformat calls this by name at demux time to recover extradata
  //                          from the first packets of raw H.264/HEVC in MPEG-TS. Required.
  //
  // The three below are NOT reachable in this configuration and can be deleted:
  // remove_extradata and dca_core/truehd_core are only applied via an explicit `-bsf` on the
  // ffmpeg CLI, and pgs_frame_merge is selected by the matroska *muxer*, which we do not build.
  // (Passthrough does not need them: mpv drives it with the spdif muxer plus the ac3/dca/mlp
  // parsers, and reads the DTS profile itself to decide core-vs-HD.)

  List<String> get bitstreamFilters => [
    "--enable-bsf=h264_mp4toannexb,hevc_mp4toannexb",
    "--enable-bsf=aac_adtstoasc",
    "--enable-bsf=extract_extradata",
    "--enable-bsf=remove_extradata",
    "--enable-bsf=pgs_frame_merge",
    "--enable-bsf=dca_core,truehd_core",
  ];

  // ---------------------------------------------------------------------------------------------
  // Protocols
  // ---------------------------------------------------------------------------------------------
  //  android_content : content:// URIs from the Android file picker.
  //  file / fd / pipe / data : local playback.
  //  http(s) / httpproxy / tls : web and IPTV sources.
  //  crypto          : AES-128 encrypted HLS segments — many IPTV providers use this.
  //  tcp / udp / rtp : transports for the streaming demuxers.
  //  rtmp(s) / ftp   : occasional stream sources.

  List<String> get protocols => [
    "--enable-protocol=android_content",
    "--enable-protocol=file,fd,pipe,data",
    "--enable-protocol=http,https,httpproxy,tls",
    "--enable-protocol=crypto",
    "--enable-protocol=tcp,udp,rtp",
    "--enable-protocol=rtmp,rtmps,ftp",
  ];

  // ---------------------------------------------------------------------------------------------
  // Filters
  // ---------------------------------------------------------------------------------------------
  // A "filter" post-processes decoded frames. mpv does most of its work on the GPU via
  // libplacebo, so only a handful are actually reachable:
  //
  //  Group 1 — plumbing. libavfilter auto-inserts scale/format/aresample/aformat whenever two
  //            filters disagree on a format. Without them no filter graph can be built at all.
  //  Group 2 — inserted automatically by mpv:
  //            bwdif  -> `--deinterlace=yes`, essential for 1080i/576i IPTV channels (yadif is
  //                      kept as the cheaper fallback),
  //            rotate -> phone-recorded videos with a rotation flag,
  //            vflip  -> flipped-image sources.
  //  Group 3 — convenience filters reachable from `--vf=` / `--af=`. Safe to delete if you never
  //            type those options; together they are only a few KB.

  List<String> get filters => [
    "--enable-filter=scale,format,null,copy",
    "--enable-filter=aresample,aformat,anull",
    "--enable-filter=bwdif,yadif,rotate,vflip",
    "--enable-filter=crop,hflip,transpose",
    "--enable-filter=volume,pan,atempo,equalizer",
  ];

  // ---------------------------------------------------------------------------------------------
  // Toolchain
  // ---------------------------------------------------------------------------------------------
  // Unchanged cross-compilation setup.
  //
  // NOTE: x86/x86_64 build with --disable-asm, so software decoding there is far slower than it
  // could be. Those ABIs are emulator-only in practice, so it is left as-is.

  List<String> toolchain(AndroidBuildContext context) {
    final cpu = switch (context.abi) {
      AndroidAbi.arm32  => "armv7-a",
      AndroidAbi.arm64  => "armv8-a",
      AndroidAbi.x86    => "i686",
      AndroidAbi.x86_64 => "x86-64",
    };
    final arch = switch (context.abi) {
      AndroidAbi.arm32  => "arm",
      AndroidAbi.arm64  => "aarch64",
      AndroidAbi.x86    => "x86",
      AndroidAbi.x86_64 => "x86_64",
    };
    final extraCFlags = switch (context.abi) {
      AndroidAbi.arm32 => "-Wl,-z,max-page-size=16384 -fPIC -I${context.prefixDir.resolveDir("include").absolutePath} -mfpu=neon -march=armv7-a",
      AndroidAbi.arm64 || AndroidAbi.x86 || AndroidAbi.x86_64 => "-Wl,-z,max-page-size=16384 -fPIC -I${context.prefixDir.resolveDir("include").absolutePath}",
    };

    final extraLdFlags = "-Wl,-z,max-page-size=16384 -L${context.prefixDir.resolveDir("lib").absolutePath}";

    return [
      "--arch=$arch",
      "--cpu=$cpu",
      "--enable-cross-compile",
      "--target-os=android",
      "--nm=${CurrentHost.ndkToolchainsDirectory.resolveFile("llvm-nm").absolutePath}",
      "--ar=${CurrentHost.ndkToolchainsDirectory.resolveFile("llvm-ar").absolutePath}",
      "--cc=${CurrentHost.ndkToolchainsDirectory.resolveFile(context.abi.clang).absolutePath}",
      "--as=${CurrentHost.ndkToolchainsDirectory.resolveFile(context.abi.clang).absolutePath}",
      "--strip=${CurrentHost.ndkToolchainsDirectory.resolveFile("llvm-strip").absolutePath}",
      "--cxx=${CurrentHost.ndkToolchainsDirectory.resolveFile(context.abi.cpp).absolutePath}",
      "--pkg-config=pkg-config",
      "--pkg-config-flags=--static",
      "--ranlib=${CurrentHost.ndkToolchainsDirectory.resolveFile("llvm-ranlib").absolutePath}",
      "--extra-cflags=$extraCFlags",
      "--extra-ldflags=$extraLdFlags",
      ...switch (context.abi) {
        AndroidAbi.arm32 || AndroidAbi.arm64 => [],
        AndroidAbi.x86 || AndroidAbi.x86_64 => ["--disable-asm"],
      },
      "--enable-optimizations",
      "--disable-stripping",
    ];
  }

}