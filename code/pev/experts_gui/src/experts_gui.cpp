// vi: ts=4 sw=4 et ai aw

#include "experts_gui.h"
#include "evaluation_data.h"
#include "ui_mainwindow.h"
#include "stack-c.h"
#include "call_scilab.h"
#include <iostream>
#include <fstream>
#include <stdio.h>

using namespace std;

static int width = 800, height = 600;
char tempfile[] = "/tmp/ExpertsGui.dat";

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

    // Scilab INITIALIZATION
#ifdef _MSC_VER
    if (StartScilab(NULL, NULL, 0) == FALSE)
#else
    if (StartScilab(getenv("SCI"), NULL, 0) == FALSE)
#endif
    {
        fprintf(stderr,"Error while calling StartScilab\n");
        return -1;
    }
    // TODO (kiraboris): why the hell is this path hard-coded?
    string scicommand = string("cd ") + app.applicationDirPath().toUtf8().data() + "/../..";
    if (SendScilabJob((char *)scicommand.c_str())) {
        cerr << "Scilab error" << endl;
        return -1;
    }
    if (SendScilabJob((char *)"exec('loader.sce');")) {
        cerr << "Scilab error" << endl;
        return -1;
    }

    // Start the event loop
    int ret_code = app.exec();

    // Scilab TERMINATION
    if (TerminateScilab(NULL) == FALSE) {
        fprintf(stderr,"Error while calling TerminateScilab\n");
        return -2;
    }

    return ret_code;
}

MainWindow::MainWindow(QWidget *parent) :
    QMainWindow(parent),
    ui(new Ui::MainWindow)
{
    ui->setupUi(this);

    connect(ui->techMdiArea,SIGNAL(subWindowActivated(QMdiSubWindow*)),
            this,SLOT(onActiveTechChanged(QMdiSubWindow*)));
    connect(ui->addTech, SIGNAL(clicked()), this, SLOT(onAddTech()));
    connect(ui->saveTech, SIGNAL(clicked()), this, SLOT(onSaveAllTech()));
    connect(ui->saveOneTech, SIGNAL(clicked()), this, SLOT(onSaveSingleTech()));
    connect(ui->evaluate, SIGNAL(clicked()), this, SLOT(onEvaluate()));
}

MainWindow::~MainWindow() {
    delete ui;
}

void MainWindow::onActiveTechChanged(QMdiSubWindow* win)
{
    if(win != NULL)
    {
      cout << "Active tech is " <<
              dynamic_cast<TechEvWindow *>((win)->widget())->getNumber() << endl;
    }
    else
    {
      cout<< "No active window" << endl;
    }
}

void MainWindow::onAddTech() {
    int smallestUnusedNumber = 1;

    QList<QMdiSubWindow *> lst = ui->techMdiArea->subWindowList();
    QList<QMdiSubWindow *>::iterator it;
    for (it = lst.begin(); it != lst.end(); it++) {
        int number = dynamic_cast<TechEvWindow *>((*it)->widget())->getNumber();
        if( smallestUnusedNumber == number )
                ++smallestUnusedNumber;
    }

    QMdiSubWindow *subwnd = ui->techMdiArea->addSubWindow(new TechEvWindow(smallestUnusedNumber));
    subwnd->show();
}

void MainWindow::onSaveAllTech() {
    saveToStream(-1, cout);
}

void MainWindow::onSaveSingleTech() {
    int nTechToSave = -1;
    QList<QMdiSubWindow *> lst = ui->techMdiArea->subWindowList();
    QList<QMdiSubWindow *>::iterator it;
    for (it = lst.begin(); it != lst.end(); it++) {
        //dynamic_cast<TechEvWindow *>((*it)->widget())->activateWindow();
        if( 0 )
            nTechToSave = dynamic_cast<TechEvWindow *>((*it)->widget())->getNumber();
    }
    cout << "There are " << nTechToSave << endl;
}

// saveToFile: outputs given tech or all techs (ntech= -1)
//              to pstream via operator<<
// returns count of saved techs
int MainWindow::saveToStream(int ntech, ostream &pstream)
{
    QList<QMdiSubWindow *> lst = ui->techMdiArea->subWindowList();
    QList<QMdiSubWindow *>::iterator it;

    int maxNumber = lst.length();
    vector<TechEval> sortedTechs(maxNumber);

    for (it = lst.begin(); it != lst.end(); it++) {
        int number =  dynamic_cast<TechEvWindow *>((*it)->widget())->getNumber();
        sortedTechs.at(number-1) =  // that's vector<Eval>::operator=
                 dynamic_cast<TechEvWindow *>((*it)->widget())->getData();
    }

    if( ntech < 0 )             // save all
    {
       for (int i=0; i < maxNumber; ++i)
          pstream << sortedTechs[i];
       return maxNumber;
    }
    else if(ntech < maxNumber)  // save single
    {
       pstream << sortedTechs[ntech];
       return 1;
    }
    else
    {
       cerr << "Out of bounds";
       return 0;
    }

}

void MainWindow::onEvaluate() {

    ofstream of(tempfile, ios::trunc);

    of << "qParam= 16 (parameters per 1 object)" << endl;
    of << "y = 1/3000*( 0.25*(x(1)+0.1*x(3)*x(4)+x(5)+0.5*(x(2)+x(6))) + 0.05*(x(7)+x(9))*x(8) + 0.5*(x(10)+0.5*(x(11)+x(12))) ) * x(13)*x(16)*0.5*(x(14)+x(15))" << endl;
    of << "The above lines are intended for 'ptSelect( filename )'. See file select.sce for help. The line below is a separator and must begin with an asterix." << endl;
    of << "*******************************************" << endl;

    int numTechs = saveToStream(-1, of);
    of.close();

    if (!numTechs) return;

    cout << endl;
    cout << "==============================" << endl;
    cout << "Evaluating " << numTechs << " technologies" << endl;
    cout << "==============================" << endl;

    string scicommand = string("[sel, ploser] = pevSelectF('") + tempfile + "');";
    if (SendScilabJob((char *)scicommand.c_str())) {
        cerr << "Scilab error" << endl;
        return;
    }
    if (SendScilabJob((char *)"pevPrintResult(sel);")) {
        cerr << "Scilab error" << endl;
        return;
    }

    cout << "==============================" << endl;
}
