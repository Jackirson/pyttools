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

using namespace std;

/** \brief Main window of the application.
 **/
class MainWindow : public QMainWindow {
    Q_OBJECT

    private:
        /** Pointer to the mdi area object which holds all the subwindows of the
         ** application.
         **/
        QMdiArea *mdiarea;

    private slots:
        /** Called when the "Learning -> New Database" menu item
         ** is selected. This method creates a new database view.
         **/
        void actionNewDatabase();

        /** Called when the "Learning -> Open Database" menu item
         ** is selected. This method creates a new database view and tells its
         ** constructor to load a database from a disk file.
         ** If an exception is caught while opening the database,
         ** this method deletes the created database view and nothing is added
         ** to the mdi area.
         **/
        void actionOpenDatabase();

        /** Called when the "Learning -> Generator" menu item
         ** is selected. This method creates a new generator view.
         ** If an exception is caught while opening the database,
         ** this method deletes the created generator view and nothing is added
         ** to the mdi area.
         **/
        void actionGenerator();

        /** Called when the "Look&feel -> Cascade Windows" menu item
         ** is selected.
         **/
        void actionCascadeWindows();

        /** Called when the "Look&feel -> Tile Windows" menu item
         ** is selected.
         **/
        void actionTileWindows();

        /** Called when the "Look&feel -> Tabbed View" menu item
         ** is selected.
         **/
        void actionTabbedView();

        void actionFBRecognizer();

    protected:
        /** Called when the user attempts to close the main window.
         ** This method tries to close the subwindows of the application.
         ** If all the subwindows
         ** are closed, it terminates the application.
         **/
        virtual void closeEvent(QCloseEvent *event);

    public:
        /** Constructs the main window object.
         **/
        MainWindow();

        /** Returns pointer to the mdi area object which holds all the subwindows
         ** of the application. This method is used by
         ** the subwindows when they construct and add themselves to the mdi area.
         **/
        QMdiArea *getMdiArea();
};

#endif

