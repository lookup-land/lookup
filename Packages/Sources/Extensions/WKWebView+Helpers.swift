// © Agni Ilango
// SPDX-License-Identifier: MPL-2.0

import SharedModels
import WebKit

enum WKWebViewError: Error {
    case runtimeError(String)
}

public extension WKWebView {
    func loadURL(url: URL?) {
        if let url = url {
            let request = URLRequest(url: url)
            load(request)
        }
    }

    func evaluateJavaScriptAsync(_ javaScriptString: String) async throws -> Any? {
        return try await withCheckedThrowingContinuation { continuation in
            evaluateJavaScript(javaScriptString) { result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: result)
                }
            }
        }
    }

    private func getFallbackFavicon() throws -> Favicon {
        var fallbackFavicon: Favicon?

        if let baseURL = url,
           let scheme = baseURL.scheme,
           let host = baseURL.host
        {
            let fallbackIcon = "\(scheme)://\(host)/favicon.ico"

            if let url = URL(string: fallbackIcon) {
                fallbackFavicon = Favicon(
                    url: url
                )
            }
        }

        guard let fallbackFavicon = fallbackFavicon else {
            throw WKWebViewError
                .runtimeError("Unable to generate fallback favicon")
        }

        return fallbackFavicon
    }

    func getFavicon() async throws -> Favicon {
        let fallbackFavicon = try getFallbackFavicon()

        guard let response = try? await evaluateJavaScriptAsync("""
            [...document.querySelectorAll(`
                link[rel~='icon'],
                link[rel='shortcut icon'],
                link[rel='apple-touch-icon']
            `)].sort((a, b) => {
                const aSize = Number(a.sizes.value.split("x")[0])
                const bSize = Number(b.sizes.value.split("x")[0])

                if (!Number.isNaN(aSize) && Number.isNaN(bSize)) {
                    return -1
                } else if (Number.isNaN(aSize) && !Number.isNaN(bSize)) {
                    return 1
                } else if (Number.isNaN(aSize) && Number.isNaN(bSize)) {
                    return 0
                } else if (aSize > bSize && aSize < 100) {
                    return -1
                } else if (bSize > aSize && bSize < 100) {
                    return 1
                } else {
                    return 0
                }
            })[0]?.href
        """) else {
            return fallbackFavicon
        }

        guard let iconURLString = response as? String,
              let iconURL = URL(string: iconURLString)
        else {
            return fallbackFavicon
        }

        return Favicon(url: iconURL)
    }

    func getTitle() async throws -> String? {
        guard let response = try? await evaluateJavaScriptAsync("document.title") else {
            return nil
        }

        guard let title = response as? String else {
            return nil
        }

        return title
    }

    func getThemeColor() async throws -> String? {
        guard let response = try? await evaluateJavaScriptAsync("""
            document
                .querySelector('meta[name="theme-color"]')
                .getAttribute("content")
        """) else {
            return nil
        }

        guard let themeColor = response as? String else {
            return nil
        }

        return themeColor
    }

    func getInitialBrowserVisibility() async throws -> InitialBrowserVisibility? {
        guard let response = try? await evaluateJavaScriptAsync("""
            document
                .querySelector('meta[name="ar-layers-initial-browser-visibility"]')
                .getAttribute("content")
        """) else {
            return nil
        }

        guard let response = response as? String,
              let initialBrowserVisibility = InitialBrowserVisibility(rawValue: response)
        else {
            return nil
        }

        return initialBrowserVisibility
    }

    func getHTMLMetadata() async throws -> HTMLMetadata {
        let favicon = try await getFavicon()
        let title = try await getTitle()
        let themeColor = try await getThemeColor()
        let initialBrowserVisibility = try await getInitialBrowserVisibility() ?? .visible

        return HTMLMetadata(
            favicon: favicon,
            title: title,
            themeColor: themeColor,
            initialBrowserVisibility: initialBrowserVisibility
        )
    }
}
