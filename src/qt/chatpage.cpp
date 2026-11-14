#include "chatpage.h"

#include "walletmodel.h"
#include "guiutil.h"
#include "util.h"

#include <QDesktopServices>
#include <QLabel>
#include <QPushButton>
#include <QUrl>
#include <QVBoxLayout>

#ifdef USE_WEBKIT
#include "ui_chatpage.h"
#include "cookiejar.h"
#include "webview.h"
#endif

using namespace GUIUtil;

static const char* LITEDOGE_IRC_URL = "https://web.libera.chat/#litedoge";

// The chat used to be shown in an embedded QtWebKit browser. QtWebKit is no
// longer maintained (no security fixes, not available for Windows builds), so
// by default the page opens the chat in the user's own browser instead.
// Build with qmake USE_WEBKIT=1 to get the embedded browser back.
ChatPage::ChatPage(QWidget *parent) :
    QWidget(parent),
    ui(0),
    clientModel(0),
    walletModel(0)
{
#ifdef USE_WEBKIT
    ui = new Ui::ChatPage;
    ui->setupUi(this);

    CookieJar *chatJar = new CookieJar(this);
    ui->webView->page()->networkAccessManager()->setCookieJar(chatJar);

    ui->webView->page()->setLinkDelegationPolicy(QWebPage::DelegateAllLinks);
    connect(ui->webView->page()->networkAccessManager(), SIGNAL(sslErrors(QNetworkReply*, const QList<QSslError> & )), ui->webView, SLOT(sslErrorHandler(QNetworkReply*, const QList<QSslError> & )));
    connect(ui->webView->page(), SIGNAL(linkClicked(QUrl)), ui->webView, SLOT(myOpenUrl(QUrl)));
#else
    QVBoxLayout *layout = new QVBoxLayout(this);
    layout->addStretch(1);

    QLabel *title = new QLabel(tr("LiteDoge IRC"), this);
    QFont font = title->font();
    font.setPointSize(font.pointSize() * 3 / 2);
    font.setBold(true);
    title->setFont(font);
    title->setAlignment(Qt::AlignCenter);
    layout->addWidget(title);

    QLabel *text = new QLabel(tr("Chat with the LiteDoge community in the #litedoge channel on Libera Chat. "
                                 "The channel opens in your web browser."), this);
    text->setWordWrap(true);
    text->setAlignment(Qt::AlignCenter);
    layout->addWidget(text);

    QPushButton *open = new QPushButton(tr("Open #litedoge in the browser"), this);
    open->setSizePolicy(QSizePolicy::Maximum, QSizePolicy::Fixed);
    connect(open, SIGNAL(clicked()), this, SLOT(openChat()));
    layout->addWidget(open, 0, Qt::AlignHCenter);

    layout->addStretch(2);
#endif
}

ChatPage::~ChatPage()
{
#ifdef USE_WEBKIT
    delete ui;
#endif
}

void ChatPage::setModel(ClientModel *model)
{
    this->clientModel = model;
}

void ChatPage::setModel(WalletModel *model)
{
    this->walletModel = model;
#ifdef USE_WEBKIT
    ui->webView->load(QUrl(LITEDOGE_IRC_URL));
#endif
}

void ChatPage::openChat()
{
    QDesktopServices::openUrl(QUrl(LITEDOGE_IRC_URL));
}
