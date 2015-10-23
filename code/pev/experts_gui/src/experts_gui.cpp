// vi: ts=4 sw=4 et ai aw

#include "experts_gui.h"
#include "ui_mainwindow.h"
#include <iostream>

using namespace std;

static int width = 800, height = 600;

int main(int argc, char **argv) {
    // Start the application
    QApplication app(argc, argv);

    // Show the main window
    QRect screen_size = QApplication::desktop()->availableGeometry();
    if (width > screen_size.width()) width = screen_size.width();
    if (height > screen_size.height()) height = screen_size.height();
    MainWindow main_window;
    main_window.resize(width, height);
    main_window.show();

    // Start the event loop
    int ret_code = app.exec();
    return ret_code;
}

MainWindow::MainWindow(QWidget *parent) :
    QMainWindow(parent),
    ui(new Ui::MainWindow)
{
    ui->setupUi(this);

    connect(ui->addTech, SIGNAL(clicked()), this, SLOT(onAddTech()));
    connect(ui->saveTech, SIGNAL(clicked()), this, SLOT(onSaveAllTech()));
    connect(ui->evaluate, SIGNAL(clicked()), this, SLOT(onEvaluate()));
}

MainWindow::~MainWindow() {
    delete ui;
}

void MainWindow::onAddTech() {
    QMdiSubWindow *subwnd = ui->techMdiArea->addSubWindow(new EvBar);
    subwnd->show();
}

void MainWindow::onSaveAllTech() {

}

void MainWindow::onEvaluate() {

}
