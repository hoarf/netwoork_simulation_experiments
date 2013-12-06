#
# Copyright (C) 2003
# Desenvolvido por: Valter Roesler (roesler@exatas.unisinos.br)
# Unisinos: Pesquisa em Redes de Alta Velocidade (PRAV)
# UFRGS: Instituto de Informatica
#
# Programa de uso livre, desde que mantidos os creditos ao autor.
#
##############################################
# Topologia basica
##############################################
 # pkt=500B, bw=$banda
 # S0-----n(0)
 #          \ 1M
 #           \  Q=DropTail
 #            n(2)------------------n(3)
 #           /         1M
 #          / 1M
 # S1-----n(1)
 #
 #

##############################################
# Configuracoes locais
##############################################
set Tipofila DropTail   ;# usa fila droptail
#set Tipofila SFQ        ;# usa fila Stochastic Fair Queuing
set banda 4Mb
set random   1          ;# saida randomica dos pacotes
set tampacote "500 500" ;# tamanho dos pacotes

#Create a simulator object
set ns [new Simulator]

#Define a 'finish' procedure
proc finish {} {
    global ns nf tf
    $ns flush-trace
    #Close the trace file
    close $nf
    close $tf
    #Execute nam on the trace file
    exec nam out.nam
    exit 0
}

#Define cores para os fluxos
$ns color 0 Blue
$ns color 1 Red
$ns color 2 green
$ns color 3 Orange
$ns color 4 Black
$ns color 5 Black
$ns color 6 Black
$ns color 7 Black
$ns color 8 Black
$ns color 9 Black

#Abre arquivo para "nam - network animator"
set nf [open out.nam w]
$ns namtrace-all $nf

#abre arquivo trace
set tf [open out.tr w]
$ns trace-all $tf

#Cria topologia
for {set i 0} {$i<4} {incr i} {
  set n($i) [$ns node]
}

$ns duplex-link $n(0) $n(2) $banda 1ms $Tipofila
$ns duplex-link $n(1) $n(2) $banda 1ms $Tipofila
$ns duplex-link $n(2) $n(3) $banda 1ms $Tipofila

$ns duplex-link-op $n(0) $n(2) orient right-down
$ns duplex-link-op $n(1) $n(2) orient right-up
$ns duplex-link-op $n(2) $n(3) orient right

# limita a fila em 20 pacotes e monitora a fila do nó 2
$ns queue-limit $n(2) $n(3) 10
$ns duplex-link-op $n(2) $n(3) queuePos 0.5

#Cria o Traffic sink, ou seja, o ponto de chegada do tráfego
set null [new Agent/Null]
$ns attach-agent $n(3) $null

# Cria agentes UDP com trafego CBR - transmissores de tráfego
for {set i 0} {$i<20} {incr i} {
  set udp($i) [new Agent/UDP]
  $ns attach-agent $n(0) $udp($i)
  $udp($i) set fid_ $i

  set cbr($i) [new Application/Traffic/CBR]
  $cbr($i) attach-agent $udp($i)
  $cbr($i) set packetSize_ [lindex $tampacote 0]
  $cbr($i) set rate_ 100k
  if {$random} {
    $cbr($i) set random_ 1
  }

  $ns connect $udp($i) $null
}

for {set i 20} {$i<40} {incr i} {
  set udp($i) [new Agent/UDP]
  $ns attach-agent $n(1) $udp($i)
  $udp($i) set fid_ $i

  set cbr($i) [new Application/Traffic/CBR]
  $cbr($i) attach-agent $udp($i)
  $cbr($i) set packetSize_ [lindex $tampacote 0]
  $cbr($i) set rate_ 100k
  if {$random} {
    $cbr($i) set random_ 1
  }

  $ns connect $udp($i) $null
}

#Schedule events for the CBR agents
for {set i 0} {$i<40} {incr i} {
  $ns at 0.0 "$cbr($i) start"
}
$ns at 20.0 "finish"

#Run the simulation
$ns run

