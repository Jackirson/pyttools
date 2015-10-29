/** \file
 ** \brief Declares the class MainWindow wich is the main window of the
 ** application.
 **/

/** \mainpage
 ** ExpertsGui is an application ...
 ** TODO: Add description of the application here
 **/

#ifndef __EXPERTS_GUI_H__
#define __EXPERTS_GUI_H__

#include "QtIncludes.h"
#include "evaluation_gui.h"

using namespace std;

namespace Ui {
    class MainWindow;
}

class MainWindow : public QMainWindow
{
    Q_OBJECT

    public:
        explicit MainWindow(QWidget *parent = 0);
        ~MainWindow();

    private:
        Ui::MainWindow *ui;
        int saveToStream(int, ostream &);

    private slots:
        void onAddTech();
        void onSaveAllTech();
        void onEvaluate();
};

#endif // __EXPERTS_GUI_H__

