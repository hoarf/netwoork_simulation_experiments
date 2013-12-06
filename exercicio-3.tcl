#
# Valter Roesler
# UFRGS - Instituto de Informática
# 
set delay 10ms  ;
set window_size 20 ;
set queue_size 10 ;
set udp_rate 300kbps;

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

set T1 [$ns node]
set T2 [$ns node]
set T3 [$ns node]
set T4 [$ns node]
set R1 [$ns node]
set R2 [$ns node]
set R3 [$ns node]
set R4 [$ns node]
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]

set f [open out-ex3.tr w]
$ns trace-all $f
set nf [open out-ex3.nam w]
$ns namtrace-all $nf

$ns duplex-link $T1 $n0 10Mb $delay DropTail
$ns duplex-link $T2 $n0 10Mb $delay DropTail
$ns duplex-link $T3 $n0 10Mb $delay DropTail
$ns duplex-link $T4 $n0 10Mb $delay DropTail
$ns duplex-link $n1 $R4 10Mb $delay DropTail
$ns duplex-link $n0 $n1 1Mb $delay DropTail
$ns duplex-link $n1 $n2 1Mb $delay DropTail
$ns duplex-link $n2 $n3 500Kb $delay DropTail
$ns duplex-link $n2 $R1 10Mb $delay DropTail
$ns duplex-link $n2 $R3 10Mb $delay DropTail
$ns duplex-link $n3 $R2 10Mb $delay DropTail
# $ns queue-limit $n1 $n2 $queue_size

$ns duplex-link-op $n0 $T1 orient up
$ns duplex-link-op $n0 $T2 orient up-left
$ns duplex-link-op $n0 $T3 orient down-left
$ns duplex-link-op $n0 $T4 orient down

$ns duplex-link-op $n0 $n1 orient right
$ns duplex-link-op $n1 $n2 orient right
$ns duplex-link-op $n2 $n3 orient right

$ns duplex-link-op $n1 $R4 orient up
$ns duplex-link-op $n2 $R3 orient up
$ns duplex-link-op $n2 $R1 orient down
$ns duplex-link-op $n3 $R2 orient up

set tcp1 [create-connection-fulltcp $T1 $R1 1]
set ftp1 [$tcp1 attach-app FTP]
$tcp1 set window_ $window_size
puts [$tcp1 set window_]

set tcp2 [create-connection-fulltcp $T2 $R2 2]
set ftp2 [$tcp2 attach-app FTP]
$tcp2 set window_ $window_size
puts [$tcp2 set window_]

set tcp3 [create-connection-fulltcp $T3 $R3 3]
set ftp3 [$tcp3 attach-app FTP]
$tcp3 set window_ $window_size
puts [$tcp3 set window_]

#Cria trafego 1 - UDP
set udp0 [new Agent/UDP]
set udpsink [new Agent/Null]
$udp0 set fid_ 4
$ns attach-agent $T4 $udp0
$ns attach-agent $R4 $udpsink
$ns connect $udp0 $udpsink

set cbr0 [new Application/Traffic/CBR]
$cbr0 set packetSize_ 1000
$cbr0 set rate_ $udp_rate
$cbr0 attach-agent $udp0

 $ns at 0.0 "avisaprog"
$ns at 0.1 "$ftp1 start"
$ns at 1.9 "$ftp2 start"
$ns at 2.9 "$ftp3 start"
$ns at 3.9 "$cbr0 start"
# $ns at 5.9 "$cbr0 stop"
$ns at 16.0 "finish"

proc finish {} {
    global ns f 
    global nf
    $ns flush-trace
    close $f
    close $nf
    puts "running nam..."
    exec nam out-ex3.nam
    exec python parser-ex3.py
    exit 0
}

$ns run