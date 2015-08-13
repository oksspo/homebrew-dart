require 'formula'

class Dart < Formula
  homepage 'https://www.dartlang.org/'

  version '1.11.3'
  if MacOS.prefer_64_bit?
    url 'https://storage.googleapis.com/dart-archive/channels/stable/release/1.11.3/sdk/dartsdk-macos-x64-release.zip'
    sha256 'd938cf2a6c27d0eb3f3827048083dfd54ce231d4369c33324e8f26701eae2970'
  else
    url 'https://storage.googleapis.com/dart-archive/channels/stable/release/1.11.3/sdk/dartsdk-macos-ia32-release.zip'
    sha256 'ad933e15b5a172aabd464e20b8a05873daad63f1cb1451d156247b6f9c3e1cff'
  end

  option 'with-content-shell', 'Download and install content_shell -- headless Dartium for testing'
  option 'with-dartium', 'Download and install Dartium -- Chromium with Dart'

  devel do
    version '1.12.0-dev.5.3'
    if MacOS.prefer_64_bit?
      url 'https://storage.googleapis.com/dart-archive/channels/dev/release/1.12.0-dev.5.3/sdk/dartsdk-macos-x64-release.zip'
      sha256 'ddb6679d1bd8c2dfc0cc35b91d61d9c3fe5beaa6a3d7df67868e39cf4a7e8c13'
    else
      url 'https://storage.googleapis.com/dart-archive/channels/dev/release/1.12.0-dev.5.3/sdk/dartsdk-macos-ia32-release.zip'
      sha256 'adf22715e64dd00f98db0c0060734dcb1ef22cfe3acc846da5002f77c48628e3'
    end

    resource 'content_shell' do
      version '1.12.0-dev.5.3'
      url 'https://storage.googleapis.com/dart-archive/channels/dev/release/1.12.0-dev.5.3/dartium/content_shell-macos-ia32-release.zip'
      sha256 '71076cdb569975fdcd413febf350f760dd6253e9081eeb1dd5bdb12970838ded'
    end

    resource 'dartium' do
      version '1.12.0-dev.5.3'
      url 'https://storage.googleapis.com/dart-archive/channels/dev/release/1.12.0-dev.5.3/dartium/dartium-macos-ia32-release.zip'
      sha256 'a534cadaea63b6f7ee0c533c159260d3480f3ed15cbf0755211eb6bd3016de47'
    end
  end

  resource 'content_shell' do
    version '1.11.3'
    url 'https://storage.googleapis.com/dart-archive/channels/stable/release/1.11.3/dartium/content_shell-macos-ia32-release.zip'
    sha256 '04199ec06dd3dc94ef219f1817a34cf6f4c9ec7650bd1f597fb5155ebd9abe94'
  end

  resource 'dartium' do
    version '1.11.3'
    url 'https://storage.googleapis.com/dart-archive/channels/stable/release/1.11.3/dartium/dartium-macos-ia32-release.zip'
    sha256 '10e14ccfcda7d70f82050795371f89c30e756d3bf53b113a9b869212ac76b03e'
  end

  def install
    libexec.install Dir['*']
    bin.install_symlink "#{libexec}/bin/dart"
    bin.write_exec_script Dir["#{libexec}/bin/{pub,docgen,dart?*}"]

    if build.with? 'dartium'
      dartium_binary = 'Chromium.app/Contents/MacOS/Chromium'
      prefix.install resource('dartium')
      (bin+"dartium").write shim_script dartium_binary
    end

    if build.with? 'content-shell'
      content_shell_binary = 'Content Shell.app/Contents/MacOS/Content Shell'
      prefix.install resource('content_shell')
      (bin+"content_shell").write shim_script content_shell_binary
    end
  end

  def shim_script target
    <<-EOS.undent
      #!/bin/bash
      exec "#{prefix}/#{target}" "$@"
    EOS
  end

  def caveats; <<-EOS.undent
    Please note the path to the Dart SDK:
      #{opt_libexec}

    --with-dartium:
      To use with IntelliJ, set the Dartium execute home to:
        #{opt_prefix}/Chromium.app
    EOS
  end

  test do
    (testpath/'sample.dart').write <<-EOS.undent
      void main() {
        print(r"test message");
      }
    EOS

    assert_equal "test message\n", shell_output("#{bin}/dart sample.dart")
  end
end
