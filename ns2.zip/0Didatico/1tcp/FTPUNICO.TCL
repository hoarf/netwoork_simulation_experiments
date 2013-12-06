#
# Valter Roesler
# UFRGS - Instituto de Informática
# 
######################################################################################
# TESTE1: MOSTRAR FUNCIONAMENTO DO TCP: Slow-start, congestion window, etc.
#
# TESTE2: MOSTRAR GRAFICO TCP (fluxo unico): perdas, como tcp estabiliza. Rodar g.bat
#         e usar gnuplot
#
# TESTE3: MOSTRAR ADAPTACAO TCP (dois fluxos): tirar comentarios do segundo fluxo tcp.
#         Rodar g.bat e usar gnuplot.
#
# TESTE4: MOSTRAR EFEITO RTT (DELAY X BW): Voltar para fluxo unico e aumentar delay
#         para 250ms (link de satelite).
######################################################################################
set ativatcp2 1 ;# 0: desativa TCP2; 1: ativa TCP2
set delay 10ms  ;# 10ms ou 250ms

proc create-connection-fulltcp {n_src n_dst fid} {
  set ns [Simulator instance]
  
  set src [new Agent/TCP/FullTcp]
  set sink [new Agent/TCP/FullTcp]
  $src set fid_ $fid
  $sink set fid_ $fid
  $ns attach-agent $n_src $src
  $ns attach-agent $n_dst $sink
  $ns connect $src $sink
  $sink listen
  return $src
}

proc avisaprog {} {
#Get an instance of the simulator
  set ns [Simulator instance]
  set now [$ns now]
  set tempo $now
  puts $now
  set tempo [expr $tempo+1]
  $ns at $tempo avisaprog
}

set ns [new Simulator]

$ns color 0 blue
$ns color 1 red

set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]

set f [open out.tr w]
$ns trace-all $f
set nf [open out.nam w]
$ns namtrace-all $nf

$ns duplex-link $n0 $n1 1Mb $delay DropTail
$ns duplex-link $n2 $n0 1Mb $delay DropTail
$ns queue-limit $n0 $n1 10

$ns duplex-link-op $n0 $n1 orient right
$ns duplex-link-op $n2 $n0 orient right-down
$ns duplex-link-op $n0 $n1 queuePos 0.5

set tcp1 [create-connection-fulltcp $n0 $n1 0]
set ftp1 [$tcp1 attach-app FTP]
$tcp1 set window_ 20
puts [$tcp1 set window_]

if {$ativatcp2} {
  set tcp2 [create-connection-fulltcp $n0 $n1 1]
  set ftp2 [$tcp2 attach-app FTP]
}

$ns at 0.0 "avisaprog"
$ns at 0.1 "$ftp1 start"
if {$ativatcp2} {
  $ns at 0.1 "$ftp2 start"
}
$ns at 8.0 "$ftp1 stop"
if {$ativatcp2} {
  $ns at 9.0 "$ftp2 stop"
}
$ns at 10.0 "finish"

proc finish {} {
    global ns f 
    global nf
    $ns flush-trace
    close $f
    close $nf

    puts "running nam..."
    exec nam out.nam
    exit 0
}

$ns run