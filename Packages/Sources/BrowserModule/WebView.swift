// © Agni Ilango
// SPDX-License-Identifier: MPL-2.0

import ComposableArchitecture
import SharedModels
import SwiftUI
import WebKit

public struct WebView: UIViewRepresentable {
    let tab: Tab
    var onPageLoadStart: () -> Void
    var onPageLoadContent: () -> Void
    var onPageLoadEnd: () -> Void
    var onMessage: (Tab, String) -> Void
    var onScroll: () -> Void
    var onScrollEnd: (Bool) -> Void

    let webView: WKWebView

    public init(
        tab: Tab,
        onPageLoadStart: @escaping () -> Void,
        onPageLoadContent: @escaping () -> Void,
        onPageLoadEnd: @escaping () -> Void,
        onMessage: @escaping (Tab, String) -> Void,
        onScroll: @escaping () -> Void,
        onScrollEnd: @escaping (Bool) -> Void
    ) {
        self.tab = tab
        self.webView = self.tab.webView
        self.onMessage = onMessage
        self.onPageLoadStart = onPageLoadStart
        self.onPageLoadContent = onPageLoadContent
        self.onPageLoadEnd = onPageLoadEnd
        self.onScroll = onScroll
        self.onScrollEnd = onScrollEnd
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    public func makeUIView(context: Context) -> WKWebView {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(context.coordinator, action: #selector(Coordinator.refreshWebView(sender:)), for: .valueChanged)
        webView.scrollView.refreshControl = refreshControl

        webView.configuration.userContentController.removeScriptMessageHandler(forName: "ARLayers")
        webView.configuration.userContentController.add(context.coordinator, name: "ARLayers")

        webView.navigationDelegate = context.coordinator
        webView.scrollView.delegate = context.coordinator

        return webView
    }

    public func updateUIView(_ uiView: WKWebView, context: Context) {}
}

public extension WebView {
    class Coordinator: NSObject, UIScrollViewDelegate, WKNavigationDelegate, WKScriptMessageHandler {
        var parent: WebView

        public init(_ webView: WebView) {
            self.parent = webView
        }

        @objc func refreshWebView(sender: UIRefreshControl) {
            parent.webView.reload()
            sender.endRefreshing()
        }

        public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            parent.onPageLoadStart()
        }

        public func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            parent.onPageLoadContent()
        }

        public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.onPageLoadEnd()
        }

        public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "ARLayers", let body = message.body as? String {
                parent.onMessage(parent.tab, body)
            }
        }

        public func scrollViewDidScroll(_ scrollView: UIScrollView) {
            if scrollView.contentSize.height > scrollView.bounds.size.height {
                parent.onScroll()
            }
        }

        public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
            parent.onScrollEnd(decelerate)
        }
    }
}
