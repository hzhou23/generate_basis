***,Pd
memory,512,m

gthresh,twoint=1.e-12
gprint,basis,orbitals

angstrom
geometry={                 
1	! Number of atoms

Pd 0.0 0.0 0.0
}

!!! Initial guesses from BFD
f_par=[0.328400, 2.642509]
g_par=[0.540300, 2.377383]
h_par=[0.949800, 2.653401]
i_par=[2.005100, 2.500000]

proc opt_basis

!Calculate the exponents
N=4   ! Adjust to get enough exponents
do i=1,N
f_exp(i)=f_par(1)*f_par(2)^(i-1)
g_exp(i)=g_par(1)*g_par(2)^(i-1)
h_exp(i)=h_par(1)*h_par(2)^(i-1)
i_exp(i)=i_par(1)*i_par(2)^(i-1)
enddo

basis={
include, ecp.molpro
include, basis.molpro

f,Pd,f_exp(1),f_exp(2),f_exp(3),f_exp(4)
g,Pd,g_exp(1),g_exp(2),g_exp(3)
h,Pd,h_exp(1),h_exp(2)
i,Pd,i_exp(1)

}
{rhf
 start,atden
 print,orbitals=2
 wf,18,1,0
 occ,3,1,1,1,1,1,1,0
 closed,3,1,1,1,1,1,1,0
 sym,1,1,3,2
 natorb,ci,print
 orbital,4202.2
}
{rhf,nitord=1,maxit=0
 start,4202.2
 wf,18,1,0
 occ,3,1,1,1,1,1,1,0
 closed,3,1,1,1,1,1,1,0
 sym,1,1,3,2
}
data,rename,4202.2,4302.2

{uccsd(t);maxit,100;core}
eval=energy

endproc

{minimize,eval,f_par(1),f_par(2),g_par(1),g_par(2),h_par(1),h_par(2),i_par(1)
method,bfgs,proc=opt_basis,thresh=5e-5,vstep=1e-3
maxit,100}

