/*
 * Loki Random Number Generator
 * Copyright (c) 2017 Youssef Victor All rights reserved.
 *
 *      Function                        Result
 *      ------------------------------------------------------------------
 *
 *      TausStep                        Combined Tausworthe Generator or
 *                                      Linear Feedback Shift Register (LFSR)
 *                                      random number generator. This is a
 *                                      helper method for rng, which uses
 *                                      a hybrid approach combining LFSR with
 *                                      a Linear Congruential Generator (LCG)
 *                                      in order to produce random numbers with
 *                                      periods of well over 2^121
 *
 *      rand                            A pseudo-random number based on the
 *                                      method outlined in "Efficient
 *                                      pseudo-random number generation
 *                                      for monte-carlo simulations using
 *                                      graphic processors" by Siddhant
 *                                      Mohanty et al 2012.
 *
 */

#include <metal_stdlib>
using namespace metal;

//class Loki {
//private:
//    constant static unsigned int MODULUS    = 2147483647; /* DON'T CHANGE THIS VALUE                  */
//    constant static unsigned int MULTIPLIER = 48271;      /* DON'T CHANGE THIS VALUE                  */
//    constant static unsigned int STREAMS    = 256;        /* # of streams, DON'T CHANGE THIS VALUE    */
//    constant static unsigned int DEFAULT    = 123456789;  /* initial seed, use 0 < DEFAULT < MODULUS  */
//    
//    thread unsigned int seed[STREAMS]   = {DEFAULT};  /* current state of each stream   */
//    thread int  stream                 = 0;          /* stream index, 0 is the default */
//    
//public:
//    thread Loki(const int initial_seed, const int second_seed = 0, const int stream = 0);
//    thread float rand();
//};

#ifndef LOKI
#define LOKI


class Loki {
private:
    thread float seed;
    unsigned TausStep(const unsigned z, const int s1, const int s2, const int s3, const unsigned M);

public:
    thread Loki(const unsigned seed1, const unsigned seed2 = 1, const unsigned seed3 = 1);

    thread float rand();
};

#endif

