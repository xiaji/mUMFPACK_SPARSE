PROGRAM MAIN

!*****************************************************************************80
!
!! MAIN is the main program for SPARSE.
!
!  Discussion:
!
!    SPARSE tests the ST_IO, CC_IO, ST_TO_CC library & mUMFPACK module.
!
!  Licensing:
!
!    This code is distributed under the GNU LGPL license.
!
!  Modified:
!
!    05 November 2014
!
!  Author:
!
!    Wenjun Ji
!
  USE mUMFPACK
  IMPLICIT NONE
  INTEGER(KIND = 4), PARAMETER :: nst = 5
  REAL(KIND = 8), ALLOCATABLE :: acc(:), ast(:) 
  INTEGER(KIND = 4 ), ALLOCATABLE :: ccc(:), icc(:), ist(:), jst(:)
  INTEGER(KIND = 4) i_max, i_min, j_max, j_min, n, m, ncc, naa
  INTEGER i, j, OK
  REAL, DIMENSION(nst,nst) :: values
  DATA values / 2.0, 3.0, 0.0, 0.0, 0.0, 3.0, 0.0, -1.0, 0.0, 4.0, 0.0, 4.0, -3.0, 1.0, 2.0, &
    0.0, 0.0, 2.0, 0.0, 0.0, 0.0, 6.0, 0.0, 0.0, 1.0 /
  REAL(KIND = 8) :: b(nst) = [8.0, 45.0, -3.0, 3.0, 19.0], x(nst) = 0.0
  CHARACTER(LEN = 20) :: output_filename = "out.st"
  CHARACTER(LEN = 255) filename_acc
  CHARACTER(LEN = 255) filename_ccc
  CHARACTER(LEN = 255) filename_icc
  INTEGER :: fileidout = 20
  
  ! matrix triplets with allocatable components
  type(tCSC_di) :: A
  filename_acc = 'test_acc.txt'
  filename_ccc = 'test_ccc.txt'
  filename_icc = 'test_icc.txt'

  OPEN(file = output_filename, unit = fileidout, status = 'replace', iostat = OK)
  DO i = 1, nst
    DO j = 1, nst
      IF(values(i,j) /= 0.0) THEN
        WRITE(fileidout,'(2I5,F10.2)') i, j, values(i,j)
      END IF      
    END DO
  END DO
  CLOSE(fileidout)

  CALL st_header_read(output_filename, i_min, i_max, j_min, j_max, m, n, naa)

  CALL st_header_print(i_min, i_max, j_min, j_max, m, n, naa)

!
! Allocate space.
!
  ALLOCATE(ist(naa)) ! row index of nonzeros
  ALLOCATE(jst(naa)) ! column index of nonzeros
  ALLOCATE(ast(naa)) ! value of nonzeros
!
! Read the ST matrix.
!
  CALL st_data_read(output_filename, m, n, naa, ist, jst, ast)
!
! Get the CC size.
!
!  call st_sort_a ( m, n, naa, ist, jst, ast )
  
  CALL st_to_cc_size(naa, ist, jst, ncc)

  WRITE( *, '(a)' ) ''
  WRITE( *, '(a,i4)' ) '  Number of CC values = ', ncc !ncc is the number of nonzeros
!
! Create the CC indices.
!
  ALLOCATE(icc(1:ncc)) ! icc stores the row index of nonzeros
  ALLOCATE(ccc(1:n+1)) ! n is the size of matrix columns and ccc stores column information

  CALL st_to_cc_index(naa, ist, jst, ncc, n, icc, ccc)
!
! Create the CC values.
!
  ALLOCATE(acc(1:ncc)) ! acc stores the value of nonzeros

  CALL st_to_cc_values(naa, ist, jst, ast, ncc, n, icc, ccc, acc)
! Reason dec the value of icc and ccc:
! UMFPACK library written in C, the index of array in C starts at 0
  CALL i4vec_dec(ncc, icc) ! icc = icc - 1
  CALL i4vec_dec(n + 1, ccc) ! ccc = ccc - 1
  CALL cc_print(m, n, ncc, icc, ccc, acc, '  The CC matrix:')
!
! Write the CC matrix.
!
  CALL i4vec_write (filename_icc, ncc, icc)
  CALL i4vec_write (filename_ccc, n + 1, ccc)
  CALL r8vec_write (filename_acc, ncc, acc)
! CSC format
  PRINT '(a)',"High-level Fortran operator (.umfpack.), CSC allocatable operands"

! double-int (di)
  A = tCSC_di(ccc,icc,acc) !tCSC_di(column, row, nonzeros)
! solve the sparse matrix A*x = b 
  x = A .umfpack. b
  DO i = lbound(x,1),ubound(x,1)
    PRINT '(a,i0,a,f0.10)',"x (",i,") = ",x(i)
  END DO
!
! Free memory.
!  
  DEALLOCATE (acc)
  DEALLOCATE (ast)
  DEALLOCATE (ccc)
  DEALLOCATE (icc)
  DEALLOCATE (ist)
  DEALLOCATE (jst)

END

