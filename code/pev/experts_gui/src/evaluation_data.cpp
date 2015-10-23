#include "evaluation_data.h"

SingleEv::SingleEv(int numLevels, int maxPoint) {
    this->numLevels = numLevels;
    this->maxPoint = 10; // TODO: implement maxPoint
    resize(this->maxPoint + 1);
}

double SingleEv::operator() (int i) {
    return ((*this)[i] % numLevels) / (double)(numLevels - 1);
}

void SingleEv::change(int i) {
    if (!(*this)[i]) (*this)[i] = numLevels - 1;
    else (*this)[i]--;
}

int SingleEv::getNumLevels() {
    return numLevels;
}

int SingleEv::getMaxPoint() {
    return maxPoint;
}

ostream & operator<< (ostream &out, SingleEv &eval) {
    for (int i = 0; i <= eval.getMaxPoint(); i++) {
        out << eval(i) << " ";
    }
    return out;
}
