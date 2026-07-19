package vn.hunghd.flutterdownloader;

import androidx.core.content.FileProvider;

/**
 * Compatibility shim to avoid startup crash when merged manifest references
 * DownloadedFileProvider but the downloader class is not packaged in release.
 */
public class DownloadedFileProvider extends FileProvider {
}
