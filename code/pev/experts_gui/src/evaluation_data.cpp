#include "evaluation_data.h"
#include "math.h"

Eval::Eval(int numLevels, int maxPoint) {
    this->numLevels = numLevels;
    this->maxPoint = 10; // TODO: implement maxPoint
    resize(this->maxPoint + 1);
}

double Eval::operator() (int i) {
    return (this->at(i)  % numLevels) / (double)(numLevels-1);
}

void Eval::unbracket(int i, double val) {
    // check boundaries
    if(val > 1) val = 1;
    if(val < 0) val = 0;

    this->at(i) = round( (val * (numLevels-1)) );
}


void Eval::change(int i) {
    if (!(*this)[i]) (*this)[i] = numLevels - 1;
    else (*this)[i]--;
}

int Eval::getNumLevels() {
    return numLevels;
}

int Eval::getMaxPoint() {
    return maxPoint;
}

ostream & operator<< (ostream &out, Eval &eval) {
    for (int i = 0; i <= eval.getMaxPoint(); i++) {
        out << eval(i) << " ";
    }
    return out;
}

istream & operator>> (istream &in,  Eval &eval) {
    double val = -1;
    // kiraboris: maxPoint may also be defined here using std::getline(), then std::istringstream
    for (int i = 0; i <= eval.getMaxPoint(); i++) {
        in >> val; eval.unbracket(i, val);
    }
    return in;
}

TechEval::TechEval(int numParameters, int numLevels, int maxPoint) {
    resize(numParameters);
    for (int i = 0; i < numParameters; i++) {
        (*this)[i] = Eval(numLevels, maxPoint);
    }
}

double TechEval::operator() (int i, int j) {
    return (*this)[i](j);
}

ostream & operator<< (ostream &out, TechEval &teval) {
    for (int i = 0; i < teval.size(); i++) {
        out << teval[i];
        out << endl;
    }
    return out;
}

istream & operator>> (istream &in,  TechEval &teval) {
    for (int i = 0; i < teval.size(); i++) {
        in >> teval[i];
    }
    return in;
}
