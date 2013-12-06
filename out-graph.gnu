#!/usr/bin/gnuplot

# wxt
set terminal wxt enhanced font 'Verdana,10' persist 

set ylabel 'Número de Pacotes Descartados'
set xlabel 'Tempo(s)'
set border linewidth 1.5
set style line 1 lc rgb '#800000' lt 1 lw 3
set style line 2 lc rgb '#ff0000' lt 1 lw 2
set style line 3 lc rgb '#ff4500' lt 1 lw 2
set style line 4 lc rgb '#ffa500' lt 1 lw 1
set style function lines
set xtics 0.5
set grid
set datafile separator ","

plot 'out-ex2-w=20-q=10.tr.csv'  w lp ls 1 t 'w=20;q=10' ,\
     'out-ex2-w=20-q=30.tr.csv'  w lp ls 2 t 'w=20;q=30', \
     'out-ex2-w=40-q=10.tr.csv'  w lp ls 3 t 'w=40;q=10', \
     'out-ex2-w=40-q=30.tr.csv'  w lp ls 4 t 'w=40;q=30'

