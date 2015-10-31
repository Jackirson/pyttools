#ifndef __EVALUATION_DATA_H__
#define __EVALUATION_DATA_H__

#include <vector>
#include <iostream>

using namespace std;

class Eval : public vector<unsigned int> {
    protected:
        int numLevels, maxPoint;

    public:
        Eval(int numLevels = 4, int maxPoint = 10);
        double operator() (int i);
        void  unbracket(int i, double val);

        void change(int i);
        int getNumLevels();
        int getMaxPoint();

        friend ostream & operator<< (ostream &out, Eval &eval);
        friend istream & operator>> (istream &in,  Eval &eval);

};

class TechEval : public vector<Eval> {
    public:
        TechEval(int numParameters = 16, int numLevels = 4, int maxPoint = 10);
        double operator() (int i, int j);

        friend ostream & operator<< (ostream &out, TechEval &teval);
        friend istream & operator>> (istream &in,  TechEval &teval);

};

#endif // __EVALUATION_DATA_H__
