// vi: ts=4 sw=4 et ai aw

#include "experts_gui.h"
#include "evaluation_data.h"
#include "ui_mainwindow.h"
#include "stack-c.h"
#include "call_scilab.h"
#include <iostream>
#include <fstream>
#include <sstream>
#include <stdio.h>

using namespace std;

static int width = 800, height = 600;

const int QPARAM = 16; // kiraboris: hard-coded
const int QLEVEL = 4;

const char *tempfile = tmpnam(NULL);

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
    // TODO (kiraboris): why is this path hard-coded?
    string sAppRoot = QApplication::applicationDirPath().toUtf8().data();
    string scicommand = string("cd ") + sAppRoot + "/../..";
    if (SendScilabJob((char *)scicommand.c_str())) {
        cerr << __FILE__ << ": " << __LINE__ << " " << "Scilab error" << endl;
        return -1;
    }
    if (SendScilabJob((char *)"exec('loader.sce');")) {
        cerr << __FILE__ << ": " << __LINE__ << " " << "Scilab error" << endl;
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
    mActiveTech = -1;

    // IO buttons
    connect(ui->techMdiArea,SIGNAL(subWindowActivated(QMdiSubWindow*)),
            this,SLOT(onActiveTechChanged(QMdiSubWindow*)));
    connect(ui->addTech, SIGNAL(clicked()), this, SLOT(onAddTech()));
    connect(ui->saveTech, SIGNAL(clicked()), this, SLOT(onSaveAllTech()));
    connect(ui->saveOneTech, SIGNAL(clicked()), this, SLOT(onSaveSingleTech()));
    connect(ui->loadTech, SIGNAL(clicked()), this, SLOT(onLoadTechFile()));

    // SCILAB buttons
    connect(ui->evaluate, SIGNAL(clicked()), this, SLOT(onEvaluate()));
}

MainWindow::~MainWindow() {
    delete ui;
}

void MainWindow::onActiveTechChanged(QMdiSubWindow* win)
{
    if(win != NULL)
    {
      mActiveTech = dynamic_cast<TechEvWindow *>((win)->widget())->getNumber();
      ui->labelActiveTech->setText("Active tech: #" +
              QString::number(mActiveTech));
    }
    else
    {
      ui->labelActiveTech->setText("Active tech: none");\
      mActiveTech = -1; // !! FileSave dialog steals focus
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

    QMdiSubWindow *subwnd = ui->techMdiArea->addSubWindow(new
               TechEvWindow(smallestUnusedNumber, QPARAM, QLEVEL));
    subwnd->show();
}

void MainWindow::onSaveAllTech() {

    // TODO (kiraboris): as template/for evaluation differs from all/one
    if( ! ui->checkSaveCout->isChecked() )  {
        // then use file dialog
        QString filename = QFileDialog::getSaveFileName(this, "Save all techs for evaluation",
                       QApplication::applicationDirPath()+"/../data/sample.txt", "*.txt");
        if( filename.isEmpty() ) return;

         ofstream of(filename.toUtf8().data(), ios::trunc);
          writeHeaders(of);
       //  int nSaved = saveToStream(mActiveTech-1, of);
         int nSaved = saveToStream(-1, of);
         of << "*******************************************" << endl;
         of << "File contains " << nSaved << " technology entries, each 16 lines long.";
         of.close();

         cout << nSaved << " techs saved." << endl;
    }
    else    {
         int nSaved = saveToStream(-1, cout);
             // mActiveTech indexing from 1, ntech indexing from 0
            cout << nSaved << " techs saved." << endl;
    }
}

void MainWindow::onSaveSingleTech() {

    if( mActiveTech <= 0 ) return;
    int tnActiveTech = mActiveTech; // !! FileSave dialog steals focus

    if( ! ui->checkSaveCout->isChecked() )  {
        // then use file dialog
        QString filename = QFileDialog::getSaveFileName(this, "Save single tech as temlate:",
                       QApplication::applicationDirPath()+"/../data/sample.txt", "*.txt");
        if( filename.isEmpty() ) return;

         ofstream of(filename.toUtf8().data(), ios::trunc);
        //  writeHeaders(of);
         of << "Machine-generated file. Intended as technology TEMPLATE for UI only!" << endl;
         of << "*******************************************" << endl;
         int nSaved = saveToStream(tnActiveTech-1, of);
        // int nSaved = saveToStream(-1, of);
         of << "*******************************************" << endl;
         of << "File contains " << nSaved << " technology entries, each " << QPARAM << " lines long.";
         of.close();

         cout << nSaved << " techs saved." << endl;
    }
    else    {
         int nSaved = saveToStream(mActiveTech-1, cout);
             // mActiveTech indexing from 1, ntech indexing from 0
            cout << nSaved << " techs saved." << endl;
    }
}


void MainWindow::onLoadTechFile() {
    QString filename = QFileDialog::getOpenFileName(this, "Load tech data file:",
                   QApplication::applicationDirPath()+"/../data", "*.txt");
    if( filename.isEmpty() ) return;

    ifstream file(filename.toUtf8().data(), ios::in);
    if( ! file.is_open() ) return;

    string sbuf; string sdata;
    bool fInterpret = false; int qLines = 0;

    while( getline(file, sbuf) ) {
        // separator lines
        if( sbuf[0] == '*' && fInterpret ) {
            fInterpret = false;
            continue; // otherwise the tail check will switch on again
        }

        if( fInterpret ) {
          sdata += (sbuf += "\r\n");  // store to data stream
          ++qLines;
        }

        // separator lines
        if( sbuf[0] == '*' && !fInterpret )
            fInterpret = true;
    }

    if( qLines % QPARAM ) {
        cerr << "(Data lines read) % (lines per tech) not zero. File corrupt?" << endl;
        return;
    }

    if( !qLines ) {
        cout << "File contains no data (or no asterix)." << endl;
        return;
    }

    // **NOW reading data from file into new tech windows
    // opened tech windows will be now closed
    ui->techMdiArea->closeAllSubWindows();
    cout << "==============================" << endl;
    cout << "WARNING: a uniform scale with " << QLEVEL << " different values is assumed in file!" << endl;

    istringstream ssdata(sdata); TechEval teval;
    for(int i=0; i < qLines / QPARAM; ++i) {

        ssdata >> teval;
        QMdiSubWindow *subwnd =
                ui->techMdiArea->addSubWindow(new TechEvWindow(i+1, teval, QLEVEL));
        subwnd->show();
    }  // end of windows creation

    cout << "Loaded " << qLines / QPARAM << " entries." << endl;
    cout.flush();
    file.close();
}


// saveToFile: outputs given tech or all techs (ntech= -1)
//              to pstream via operator<<
// returns count of saved techs
// **this func and the next one actually belong to a Saver class
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
    else if(ntech < maxNumber && ntech >= 0)  // save single
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

// writes headers to data file for pevSelectF()
void MainWindow::writeHeaders(ostream &of) {
    of << "qParam= " << QPARAM << " (parameters per 1 object)" << endl;
    of << "y = 1/3000*( 0.25*(x(1)+0.1*x(3)*x(4)+x(5)+0.5*(x(2)+x(6))) + 0.05*(x(7)+x(9))*x(8) + 0.5*(x(10)+0.5*(x(11)+x(12))) ) * x(13)*x(16)*0.5*(x(14)+x(15))" << endl;
    of << "Machine-generated file. The above is intended for 'pevSelectF( filename )', see file select.sce." << endl;
    of << "The next separator line must begin with an asterix." << endl;
    of << "*******************************************" << endl;
}

void MainWindow::onEvaluate() {

    ofstream of(tempfile, ios::trunc);
    writeHeaders(of);
    int numTechs = saveToStream(-1, of);
    of << "*******************************************" << endl;
    of << "File contains " << numTechs << " technology entries, each " << QPARAM << " lines long.";
    of.close();

    if (!numTechs) return;

    cout << endl;
    cout << "==============================" << endl;
    cout << "Evaluating " << numTechs << " technologies" << endl;
    cout << "==============================" << endl;

    string scicommand = string("[sel, ploser] = pevSelectF('") + tempfile + "');";
    if (SendScilabJob((char *)scicommand.c_str())) {
        cerr << __FILE__ << ": " << __LINE__ << " " << "Scilab error" << endl;
        return;
    }
    if (SendScilabJob((char *)"pevPrintResult(sel);")) {
        cerr << __FILE__ << ": " << __LINE__ << " " << "Scilab error" << endl;
        return;
    }

    cout << "==============================" << endl;
}
