mUMFPACK_SPARSE
===============

# mUMFPACK Sparse Matrix Solver Example (Fortran 2003)

The mUMFPACK module provides a Fortran-2003 implementation of the full UMFPACK interface.

There are three parts in this program.
* Create Sparse Triplet (ST) Matrix File, using [ST_IO](http://people.sc.fsu.edu/~jburkardt/f_src/st_io/st_io.html) 
* Read the ST file and Converse it to Compressed Column (CC) format, using [ST_TO_CC](http://people.sc.fsu.edu/~jburkardt/f_src/st_to_cc/st_to_cc.html)
* [mUMFPACK](http://geo.mff.cuni.cz/~lh/Fortran/UMFPACK/README.html) provides a high-level operator .umfpack., just one line can solve the sparse matrix instead of using umf4sym, umf4num so that saving memory from creating arrays.

## Quickstart

### Dependancies 

To get started, you will need to install [suitesparse](http://faculty.cse.tamu.edu/davis/suitesparse.html). You can use [homebrew](http://brew.sh/) to install it in your Mac

    brew install suitesparse

### Compile

    gfortran umfpack.f90 sparse.f90 -lst_io -lst_to_cc -lcc_io -lumfpack -lamd -lcholmod -lcolamd -lsuitesparseconfig -lblas -o sparse
### Run

    $ ./sparse 
    Sparse Triplet (ST) header information:

    Minimum row index I_MIN =        1
    Maximum row index I_MAX =        5
    Minimum col index J_MIN =        1
    Maximum col index J_MAX =        5
    Number of rows        M =        5
    Number of columns     N =        5
    Number of nonzeros  NST =       12

    Number of CC values =   12

    The CC matrix:
      #     I     J         A
    ----  ----  ----  ----------------

      0     0     0     2.0000000
      1     1     0     3.0000000
      2     0     1     3.0000000
      3     2     1    -1.0000000
      4     4     1     4.0000000
      5     1     2     4.0000000
      6     2     2    -3.0000000
      7     3     2     1.0000000
      8     4     2     2.0000000
      9     2     3     2.0000000
     10     1     4     6.0000000
     11     4     4     1.0000000

    High-level Fortran operator (.umfpack.), CSC allocatable operands
    x (1) = 1.0000000000
    x (2) = 2.0000000000
    x (3) = 3.0000000000
    x (4) = 4.0000000000
    x (5) = 5.0000000000

