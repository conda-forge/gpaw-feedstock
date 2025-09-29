#!/bin/bash
# customize.py example found at: https://gitlab.com/gpaw/gpaw/blob/master/customize.py
cat <<EOF> siteconfig.py
compiler = '${CC}'
has_mpi = '$mpi' != 'nompi'
library_dirs += ['${PREFIX}/lib']

scalapack = has_mpi
fftw = True
elpa = True
blas = True
xc = True
vdwxc = has_mpi

if has_mpi:
    mpi = True
    define_macros += [("GPAW_ASYNC", '1')]
    define_macros += [("GPAW_MPI2", '1')]

if fftw:
    libraries += ['fftw3_omp', 'fftw3']

if elpa:
    if has_mpi:
        libraries += ['elpa_openmp', 'elpa']
    else:
        libraries += ['elpa_onenode_openmp', 'elpa_onenode']
    include_dirs += ['${PREFIX}/include/elpa_openmp', '${PREFIX}/include/elpa']

if scalapack:
    libraries += ['scalapack']
    define_macros += [('GPAW_NO_UNDERSCORE_CSCALAPACK', '1')]
    
if blas:
    libraries += ['blas', 'lapack']
    define_macros += [('GPAW_NO_UNDERSCORE_CBLACS', '1')]

if xc:
    libraries += ['xc']
    
if vdwxc:
    libvdwxc = True
    libraries += ['vdwxc']

extra_compile_args += ['-fopenmp', '-fopenmp-simd']
extra_link_args += ['-fopenmp', '-fopenmp-simd']
EOF

# Necessary for OpenMPI cross-compilation (aarch64 at least)
# Diabling LTO is also necessary under aarch64 at the moment:
# can be disabled as soon as everything compiles without it.
if [[ "$CONDA_BUILD_CROSS_COMPILATION" == "1" ]]; then
  # This is only used by open-mpi's mpicc
  # ignored in other cases
  export OMPI_CC=$CC
  export OMPI_CXX=$CXX
  export OMPI_FC=$FC
  export OPAL_PREFIX=$PREFIX
  
  export CFLAGS="$CFLAGS -fno-lto -Wl,-fno-lto"
  export CPPFLAGS="$CPPFLAGS -fno-lto -Wl,-fno-lto"
fi

unset CC
python setup.py build_ext
python -m pip install . --no-deps
