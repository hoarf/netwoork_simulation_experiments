#
# Valter Roesler
# UFRGS - Instituto de Informática
# 
##############################################
# TESTE: MOSTRAR ADAPTACAO TCP com UDP 
#         Rodar g.bat e usar gnuplot.
##############################################
set taxaudp 1500kbps ;# Taxa do UDP. Usar 500kbps, 100kbps e 1800kbps
set run_nam 0

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

#Cria arquivos de saida
set f [open out.tr w]
$ns trace-all $f
set nf [open out.nam w]
$ns namtrace-all $nf

#Determina cores para os fluxos
$ns color 0 Blue
$ns color 1 Red

#Cria a topologia
set n0 [$ns node]
set n1 [$ns node]

$ns duplex-link $n0 $n1 2Mb 5ms DropTail
$ns duplex-link-op $n0 $n1 orient right
$ns duplex-link-op $n0 $n1 queuePos 0.5
$ns queue-limit $n0 $n1 20

#Cria trafego 0
set tcp0 [new Agent/TCP/FullTcp]
$tcp0 set fid_ 0
$tcp0 set window_ 10
puts [$tcp0 set window_]
set sink0 [new Agent/TCP/FullTcp]
$ns attach-agent $n0 $tcp0
$ns attach-agent $n1 $sink0
$ns connect $tcp0 $sink0
$sink0 listen

set ftp0 [new Application/FTP]
$ftp0 attach-agent $tcp0

#Cria trafego 1 - UDP
set udp0 [new Agent/UDP]
set udpsink [new Agent/Null]
$udp0 set fid_ 1
$ns attach-agent $n0 $udp0
$ns attach-agent $n1 $udpsink
$ns connect $udp0 $udpsink

set cbr0 [new Application/Traffic/CBR]
$cbr0 set packetSize_ 1000
$cbr0 set rate_ $taxaudp
$cbr0 attach-agent $udp0

#Escalonamento de trafego
$ns at 0.0 "avisaprog"
$ns at 0.5 "$ftp0 start"
$ns at 2.0 "$cbr0 start"
$ns at 6.0 "$cbr0 stop"
$ns at 8.0 "finish"

#Procedimento de finalizacao
proc finish {} {
    global ns nf f run_nam
    $ns flush-trace
    close $nf
    close $f

    if {$run_nam} {
      puts "running nam..."
      exec nam out.nam
    }
    exit 0
}

$ns run
