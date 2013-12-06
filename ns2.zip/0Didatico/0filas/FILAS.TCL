#
# Adaptado por: Valter Roesler
# UFRGS: Instituto de Informatica
# 
##############################################
# Topologia basica
##############################################
 # pkt=500B, bw=0,8Mbps                       
 # S0-----n(0)
 #          \ 1M
 #           \  Q=DropTail
 #            n(2)------------------n(3)
 #           /         1M
 #          / 1M
 # S1-----n(1)
 # pkt=500B, bw=0,8Mbps
 #
 #      +cbr1                              -cbr1
 #   +cbr0                                      -cbr0
 # +---------+---------+---------+---------+---------+
 # 0         1         2         3         4         5

##############################################
# Configuracoes locais
##############################################
set Tipofila DropTail   ;# usa fila droptail
set random   0          ;# saida randomica dos pacotes
#set Tipofila SFQ        ;# usa fila Stochastic Fair Queuing
set tampacote "500 500" ;# tamanho dos pacotes

###############################################
# ESTUDOS DE CASO
###############################################
# CASO1: DROPTAIL PACOTES IGUAIS RANDOM 0. Nao existe prioridades
#        Por acaso do destino fica empilhando na fila sempre com o azul no fim da fila 
#        (pois o vermelho chega instantes antes). Isso causa o descarte desigual dos
#        pacotes, provocando injustica.
#
# CASO2: DROPTAIL PACOTES IGUAIS RANDOM 1. Elimina problema anterior
#
# CASO3: SFQ PACOTES IGUAIS. Elimina um de cada fluxo.
#
# CASO4: DROPTAIL PACOTES DIFERENTES. Neste caso, entram na fila dois pacotes azuis e um vermelho,
#        porem, a saida eh de um azul e um vermelho, provocando maior trafego para o vermelho.
#

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
    exec nam out.nam &
    exit 0
}

#Define cores para os fluxos
$ns color 0 Blue
$ns color 1 Red

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

$ns duplex-link $n(0) $n(2) 1Mb 10ms $Tipofila
$ns duplex-link $n(1) $n(2) 1Mb 10ms $Tipofila
$ns duplex-link $n(2) $n(3) 1Mb 10ms $Tipofila 

$ns duplex-link-op $n(0) $n(2) orient right-down
$ns duplex-link-op $n(1) $n(2) orient right-up
$ns duplex-link-op $n(2) $n(3) orient right

# limita a fila em 20 pacotes e monitora a fila do nó 2
$ns queue-limit $n(2) $n(3) 20
$ns duplex-link-op $n(2) $n(3) queuePos 0.5

#Cria o Traffic sink, ou seja, o ponto de chegada do tráfego
set null [new Agent/Null]
$ns attach-agent $n(3) $null

# Cria agentes UDP com trafego CBR - transmissores de tráfego
for {set i 0} {$i<2} {incr i} {
  set udp($i) [new Agent/UDP]
  $ns attach-agent $n($i) $udp($i)
  $udp($i) set fid_ $i

  set cbr($i) [new Application/Traffic/CBR]
  $cbr($i) attach-agent $udp($i)
  $cbr($i) set packetSize_ [lindex $tampacote $i]
  $cbr($i) set rate_ 800k
  if {$random} {
    $cbr($i) set random_ 1
  }

  $ns connect $udp($i) $null
}

#Schedule events for the CBR agents
$ns at 0.1 "$cbr(0) start"
$ns at 0.5 "$cbr(1) start"
$ns at 4.0 "$cbr(1) stop"
$ns at 4.5 "$cbr(0) stop"
#Call the finish procedure after 5 seconds of simulation time
$ns at 5.0 "finish"

#Run the simulation
$ns run

