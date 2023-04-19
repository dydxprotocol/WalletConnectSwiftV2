import Foundation
import WebKit

final class Web3InboxClientFactory {

    static func create(
        chatClient: ChatClient,
        pushClient: WalletPushClient,
        account: Account,
        onSign: @escaping SigningCallback
    ) -> Web3InboxClient {
        let host = hostUrlString(account: account)
        let logger = ConsoleLogger(suffix: "📬")
        let webviewSubscriber = WebViewRequestSubscriber(logger: logger)
        let webView = WebViewFactory(host: host, webviewSubscriber: webviewSubscriber).create()
        let chatWebViewProxy = WebViewProxy(webView: webView, scriptFormatter: ChatWebViewScriptFormatter())
        let pushWebViewProxy = WebViewProxy(webView: webView, scriptFormatter: PushWebViewScriptFormatter())

        let clientProxy = ChatClientProxy(client: chatClient, onSign: onSign)
        let clientSubscriber = ChatClientRequestSubscriber(chatClient: chatClient, logger: logger)

        let pushClientProxy = PushClientProxy(client: pushClient, onSign: onSign)
        let pushClientSubscriber = PushClientRequestSubscriber(client: pushClient, logger: logger)

        return Web3InboxClient(
            webView: webView,
            account: account,
            logger: ConsoleLogger(),
            chatClientProxy: clientProxy,
            clientSubscriber: clientSubscriber,
            chatWebviewProxy: chatWebViewProxy,
            pushWebviewProxy: pushWebViewProxy,
            webviewSubscriber: webviewSubscriber,
            pushClientProxy: pushClientProxy,
            pushClientSubscriber: pushClientSubscriber
        )
    }

    private static func hostUrlString(account: Account) -> String {
        return "https://web3inbox-dev-hidden.vercel.app/?chatProvider=ios&account=\(account.address)"
    }
}
