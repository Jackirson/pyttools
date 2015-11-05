#include "settings.h"
#include "ui_settings.h"

SettingsDialog::SettingsDialog(QWidget *parent) :
    QDialog(parent),
    ui(new Ui::SettingsDialog)
{
    ui->setupUi(this);
    setWindowModality(Qt::WindowModal);

    connect(ui->pushDouble, SIGNAL(clicked()), this, SLOT(clickPushDouble()));
    connect(ui->pushSingle, SIGNAL(clicked()), this, SLOT(clickPushSingle()));
    connect(ui->pushRosatom, SIGNAL(clicked()), this, SLOT(clickPushRosatom()));
}

SettingsDialog::~SettingsDialog()    {
    delete ui;
}

std::string  SettingsDialog::getQualFun() {
    return ui->editFun->toPlainText().toUtf8().data();
}

int     SettingsDialog::getQPARAM()  {
    return ui->spinQPARAM->value();
}

int     SettingsDialog::getQLEVEL()  {
    return ui->spinQLEVEL->value();
}

void SettingsDialog::clickPushRosatom() {
    ui->editFun->clear();
    ui->editFun->appendPlainText("y = 1/3000*( 0.25*(x(1)+0.1*x(3)*x(4)+x(5)+0.5*(x(2)+x(6))) + 0.05*(x(7)+x(9))*x(8) + 0.5*(x(10)+0.5*(x(11)+x(12))) ) * x(13)*x(16)*0.5*(x(14)+x(15))");
    ui->spinQPARAM->setValue(16);
}

void SettingsDialog::clickPushSingle() {
    ui->editFun->clear();
    ui->editFun->appendPlainText("y = x(1)");
    ui->spinQPARAM->setValue(1);
}

void SettingsDialog::clickPushDouble() {
    ui->editFun->clear();
    ui->editFun->appendPlainText("y = 0.05*(x(1)+x(2))*x(3)");
    ui->spinQPARAM->setValue(3);
}
