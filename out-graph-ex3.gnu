#!/usr/bin/gnuplot

# wxt
set terminal wxt enhanced font 'Verdana,10' persist 

set ylabel 'Banda(Mbps)'
set xlabel 'Tempo(s)'
set border linewidth 1.5
set style line 1 lc rgb '#800000' lt 1 lw 3
set style line 2 lc rgb '#ff0000' lt 1 lw 2
set style line 3 lc rgb '#ff4500' lt 1 lw 2
set style line 4 lc rgb '#00FF00' lt 1 lw 2
set style function lines
set xtics 1
set grid
set datafile separator ","

plot 'out-ex3-flow1.csv'  w lp ls 1 t 'fluxo T1->R1' ,\
     'out-ex3-flow2.csv'  w lp ls 2 t 'fluxo T2->R2', \
     'out-ex3-flow3.csv'  w lp ls 3 t 'fluxo T3->R3' ,\
     'out-ex3-flow4.csv'  w lp ls 4 t 'fluxo T4->R4 (UDP)'

