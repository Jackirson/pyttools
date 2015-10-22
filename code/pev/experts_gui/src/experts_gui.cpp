// vi: ts=4 sw=4 et ai aw

#include "symrec.h"

// #define __DEBUG__
#include "debug.h"

static int width = 800, height = 600;

int main(int argc, char **argv)
{
    DEBUG_ENTER;

    // Start the application
    QApplication app(argc, argv);

    // Show the main window
    QRect screen_size = QApplication::desktop()->availableGeometry();
    if (width > screen_size.width()) width = screen_size.width();
    if (height > screen_size.height()) height = screen_size.height();
    MainWindow *main_window = new MainWindow;
    main_window->resize(width, height);
    main_window->setWindowTitle(QString("SymRec - Handwritten Text Recognition Toolbox"));
    main_window->show();

    // Create the "Sample generation" menu item
    QMenu *hLearning = main_window->menuBar()->addMenu(QString("Sample generation"));
    QAction *hNewDatabase = hLearning->addAction(QString("New Database"));
    QObject::connect((QObject *)hNewDatabase, SIGNAL(triggered()),
                     (QObject *)main_window, SLOT(actionNewDatabase()));
    QAction *hOpenDatabase = hLearning->addAction(QString("Open Database"));
    QObject::connect((QObject *)hOpenDatabase, SIGNAL(triggered()),
                     (QObject *)main_window, SLOT(actionOpenDatabase()));
    
    QAction *generator = hLearning->addAction(QString("Generate sample"));
    QObject::connect((QObject *)generator, SIGNAL(triggered()),
                     (QObject *)main_window, SLOT(actionGenerator()));

#if 0
    // Create the "Recognition" menu item
    QMenu *hRecognition = main_window->menuBar()->addMenu(QString("Recognition"));
    QAction *hFBRecognizer = hRecognition->addAction(QString("Floating ball recognizer"));
    QObject::connect((QObject *)hFBRecognizer, SIGNAL(triggered()),
                     (QObject *)main_window, SLOT(actionFBRecognizer()));
#endif

    // Create the "Look&feel" menu item
    QMenu *hLookAndFeel = main_window->menuBar()->addMenu(QString("Look&&feel"));
    QAction *hCascadeWindows = hLookAndFeel->addAction(QString("Cascade Windows"));
    QObject::connect((QObject *)hCascadeWindows, SIGNAL(triggered()), (QObject *)main_window, SLOT(actionCascadeWindows()));
    QAction *hTileWindows = hLookAndFeel->addAction(QString("Tile Windows"));
    QObject::connect((QObject *)hTileWindows, SIGNAL(triggered()), (QObject *)main_window, SLOT(actionTileWindows()));
    QAction *hTabbedView = hLookAndFeel->addAction(QString("Tabbed View"));
    QObject::connect((QObject *)hTabbedView, SIGNAL(triggered()), (QObject *)main_window, SLOT(actionTabbedView()));

    // Start the event loop
    int ret_code = app.exec();
    DEBUG_RETURN(ret_code);
}

MainWindow::MainWindow() {
    DEBUG_ENTER;
    mdiarea = new QMdiArea(this);
    mdiarea->setViewMode(QMdiArea::TabbedView);
    mdiarea->setTabPosition(QTabWidget::West);
    mdiarea->setTabShape(QTabWidget::Triangular);
    setCentralWidget(mdiarea);
    DEBUG_EXIT;
}

void MainWindow::closeEvent(QCloseEvent *event) {
    DEBUG_ENTER;
    QList<QMdiSubWindow *> lst = mdiarea->subWindowList();
    QList<QMdiSubWindow *>::iterator it;
    bool closed = true;
    for (it = lst.begin(); it != lst.end(); it++) {
        closed = closed && (*it)->close();
    }
    if (closed) event->accept();
    else event->ignore();
    DEBUG_EXIT;
}

void MainWindow::actionNewDatabase() {
    DEBUG_ENTER;
    SRDatabaseView *view = new SRDatabaseView(this);
    view->show();
    DEBUG_EXIT;
}

void MainWindow::actionOpenDatabase() {
    DEBUG_ENTER;
    SRDatabaseView *view = 0;
    try {
        view = new SRDatabaseView(this, true);
    } catch (SRException &e) {
        delete view;
        if (e.level) {
            QMessageBox msg(QMessageBox::Critical, QString("Failed!"), QString(e.description.c_str()), QMessageBox::Ok, this);
            msg.exec();
        }
        DEBUG_EXIT;
    }
    view->show();
    DEBUG_EXIT;
}

void MainWindow::actionGenerator() {
    DEBUG_ENTER;
    SRGeneratorView *view = 0;
    try {
        view = new SRGeneratorView(this);
    } catch (SRException &e) {
        delete view;
        if (e.level) {
            QMessageBox msg(QMessageBox::Critical, QString("Failed!"), QString(e.description.c_str()), QMessageBox::Ok, this);
            msg.exec();
        }
        DEBUG_EXIT;
    }
    view->show();
    DEBUG_EXIT;
}

void MainWindow::actionFBRecognizer() {
    DEBUG_ENTER;
    RecognizerView *view = 0;
    try {
        view = new RecognizerView(this);
    } catch (SRException &e) {
        delete view;
        if (e.level) {
            QMessageBox msg(QMessageBox::Critical, QString("Failed!"), QString(e.description.c_str()), QMessageBox::Ok, this);
            msg.exec();
        }
        DEBUG_EXIT;
    }
    view->show();
    DEBUG_EXIT;
}

void MainWindow::actionCascadeWindows() {
    DEBUG_ENTER;
    mdiarea->setViewMode(QMdiArea::SubWindowView);
    mdiarea->cascadeSubWindows();
    DEBUG_EXIT;
}

void MainWindow::actionTileWindows() {
    DEBUG_ENTER;
    mdiarea->setViewMode(QMdiArea::SubWindowView);
    mdiarea->tileSubWindows();
    DEBUG_EXIT;
}

void MainWindow::actionTabbedView() {
    DEBUG_ENTER;
    mdiarea->setViewMode(QMdiArea::TabbedView);
    mdiarea->setTabPosition(QTabWidget::West);
    mdiarea->setTabShape(QTabWidget::Triangular);
    DEBUG_EXIT;
}

QMdiArea *MainWindow::getMdiArea() {
    DEBUG_ENTER;
    DEBUG_RETURN(mdiarea);
}

